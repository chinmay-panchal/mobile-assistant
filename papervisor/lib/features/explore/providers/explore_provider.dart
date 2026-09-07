import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/pdf_search_service.dart';
import '../services/pdf_download_service.dart';
import '../services/llm_clarification_service.dart';
import '../repositories/past_downloads_repository.dart';

enum ExploreStatus { idle, loading, clarifying, success, error }

/// Provider that ties together search, download, persistence, and Gemini clarification
/// for the Explore feature. Registered globally in main.dart so download history survives.
class ExploreProvider extends ChangeNotifier {
  final PdfSearchService _searchService;
  final PdfDownloadService _downloadService;
  final PastDownloadsRepository _repository;
  final LLMClarificationService _llmClarificationService;

  ExploreProvider({
    PdfSearchService? searchService,
    PdfDownloadService? downloadService,
    PastDownloadsRepository? repository,
    LLMClarificationService? llmClarificationService,
  })  : _searchService = searchService ?? PdfSearchService(),
        _downloadService = downloadService ?? PdfDownloadService(),
        _repository = repository ?? PastDownloadsRepository(),
        _llmClarificationService = llmClarificationService ?? LLMClarificationService() {
    _loadDownloads();
  }

  ExploreStatus _status = ExploreStatus.idle;
  List<DownloadedPdf> _downloads = [];
  String? _errorMessage;
  
  ClarificationRequest? _clarificationRequest;
  String? _originalPrompt;
  int _searchGeneration = 0;

  ExploreStatus get status => _status;
  List<DownloadedPdf> get downloads => List.unmodifiable(_downloads);
  String? get errorMessage => _errorMessage;
  ClarificationRequest? get clarificationRequest => _clarificationRequest;
  String? get originalPrompt => _originalPrompt;

  /// Set to the most recently downloaded PDF so the screen can auto-open it.
  /// Cleared after being consumed (call [clearLastDownloaded]).
  DownloadedPdf? _lastDownloadedPdf;
  DownloadedPdf? get lastDownloadedPdf => _lastDownloadedPdf;
  void clearLastDownloaded() {
    _lastDownloadedPdf = null;
    // No notifyListeners — this is a consume-once field.
  }

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  Future<void> _loadDownloads() async {
    try {
      _downloads = await _repository.loadAll();
      notifyListeners();
    } catch (_) {
      // Non-fatal — start with an empty list if storage is unavailable.
    }
  }

  // ---------------------------------------------------------------------------
  // Search & Download
  // ---------------------------------------------------------------------------

  bool _isStale(int myGeneration, String prompt) {
    if (myGeneration != _searchGeneration) {
      debugPrint(
        '[ExploreProvider] Stale search (gen $myGeneration, current $_searchGeneration) — discarding result for the $prompt run',
      );
      return true;
    }
    return false;
  }

  /// Main entry point for a user prompt. Checks with Gemini if the prompt is
  /// ambiguous. If it is, moves to `clarifying` state. Otherwise, goes to download.
  Future<void> processPrompt(String prompt) async {
    final myGeneration = ++_searchGeneration;
    
    _status = ExploreStatus.loading;
    _errorMessage = null;
    _originalPrompt = prompt;
    _clarificationRequest = null;
    notifyListeners();

    try {
      final clarification = await _llmClarificationService.checkAmbiguity(prompt);
      if (_isStale(myGeneration, prompt)) return;
      
      if (clarification != null && clarification.isAmbiguous) {
        // We need clarification! Update state and wait for user input.
        _clarificationRequest = clarification;
        _status = ExploreStatus.clarifying;
        notifyListeners();
      } else {
        // Not ambiguous, or LLM failed (fallback to direct search)
        await _performSearchAndDownload(prompt, myGeneration);
      }
    } catch (e) {
      if (_isStale(myGeneration, prompt)) return;
      debugPrint('[ExploreProvider] processPrompt failed: $e');
      _status = ExploreStatus.error;
      _errorMessage = "Couldn't process that request.";
      notifyListeners();
    }
  }

  /// Called when the user selects or types an option in the clarification UI.
  Future<void> submitClarification(String selectedOption) async {
    final myGeneration = ++_searchGeneration;
    if (_originalPrompt == null) return;

    // Instantly dismiss the popup and show loading state
    _status = ExploreStatus.loading;
    notifyListeners();

    final String updatedPrompt = selectedOption.trim().isNotEmpty
        ? await _llmClarificationService.synthesizePrompt(
            _originalPrompt!,
            _clarificationRequest?.question,
            selectedOption,
          )
        : _originalPrompt!;
    if (_isStale(myGeneration, updatedPrompt)) return;

    _originalPrompt = updatedPrompt;

    try {
      // Check if the updated prompt is STILL ambiguous (e.g. step 2 of 2)
      final clarification = await _llmClarificationService.checkAmbiguity(updatedPrompt);
      if (_isStale(myGeneration, updatedPrompt)) return;
      
      if (clarification != null && clarification.isAmbiguous) {
        _clarificationRequest = clarification;
        _status = ExploreStatus.clarifying;
        notifyListeners();
        return;
      }
    } catch (_) {
      if (_isStale(myGeneration, updatedPrompt)) return;
      // Non-fatal — proceed with search
    }

    _clarificationRequest = null;
    await _performSearchAndDownload(updatedPrompt, myGeneration);
  }

  /// The search & download pipeline with Gemini query enhancement and candidate ranking.
  Future<void> _performSearchAndDownload(String prompt, int myGeneration) async {
    try {
      // Step 1: Query Enhancement via Gemini
      final enhancedQuery = await _llmClarificationService.enhancePrompt(prompt);
      if (_isStale(myGeneration, prompt)) return;

      // Step 2: Search Tavily for up to 10 candidates
      final rawResults = await _searchService.search(enhancedQuery);
      if (_isStale(myGeneration, prompt)) return;

      // Step 3: Evaluate & Rank Candidates using Gemini
      final rankedResults = await _llmClarificationService.evaluateAndRankCandidates(
        enhancedQuery,
        rawResults,
      );
      if (_isStale(myGeneration, prompt)) return;

      // Extract target year from prompt (e.g. 2025, 2024)
      final yearMatch = RegExp(r'(?<!\d)(19\d{2}|20\d{2})(?!\d)').firstMatch(prompt.toLowerCase());
      final String? targetYear = yearMatch?.group(1);

      // Step 4: Loop through ranked results, download the top valid PDF
      String? localPath;
      PdfSearchResult? successResult;
      final triedUrls = <String>{};

      for (int i = 0; i < rankedResults.length; i++) {
        final result = rankedResults[i];
        triedUrls.add(result.url);
        try {
          debugPrint('[ExploreProvider] Attempting candidate #${i + 1}/${rankedResults.length}: ${result.url}');
          localPath = await _downloadService.download(
            result.url,
            targetYear: targetYear,
            prompt: prompt,
            verifyContent: _llmClarificationService.verifyPdfCompleteness,
          );
          if (_isStale(myGeneration, prompt)) return;
          successResult = result;
          debugPrint('[ExploreProvider] Candidate #${i + 1} SUCCEEDED!');
          break; // Top valid PDF found — stop iterating.
        } on PdfValidationException catch (e) {
          if (_isStale(myGeneration, prompt)) return;
          debugPrint('[ExploreProvider] Candidate #${i + 1} rejected: ${e.message}');
        }
      }

      // Step 4b: If all candidates rejected, INCREASE SEARCH!
      if (localPath == null || successResult == null) {
        if (_isStale(myGeneration, prompt)) return;
        debugPrint('[ExploreProvider] All initial candidates rejected. Increasing search scope and relaxing filters...');

        try {
          final expandedResults = await _searchService.search(
            prompt,
            isExpanded: true,
            maxResults: 35,
          );
          if (_isStale(myGeneration, prompt)) return;

          // Filter out already tried URLs
          final newCandidates = expandedResults
              .where((r) => !triedUrls.contains(r.url))
              .toList();

          if (newCandidates.isNotEmpty) {
            final rankedExpanded = await _llmClarificationService.evaluateAndRankCandidates(
              prompt,
              newCandidates,
            );
            if (_isStale(myGeneration, prompt)) return;

            debugPrint('[ExploreProvider] Attempting ${rankedExpanded.length} expanded search candidates...');
            for (int i = 0; i < rankedExpanded.length; i++) {
              final result = rankedExpanded[i];
              triedUrls.add(result.url);
              try {
                debugPrint('[ExploreProvider] Attempting expanded candidate #${i + 1}/${rankedExpanded.length}: ${result.url}');
                localPath = await _downloadService.download(
                  result.url,
                  targetYear: targetYear,
                  prompt: prompt,
                  verifyContent: _llmClarificationService.verifyPdfCompleteness,
                );
                if (_isStale(myGeneration, prompt)) return;
                successResult = result;
                debugPrint('[ExploreProvider] Expanded candidate #${i + 1} SUCCEEDED!');
                break;
              } on PdfValidationException catch (e) {
                if (_isStale(myGeneration, prompt)) return;
                debugPrint('[ExploreProvider] Expanded candidate #${i + 1} rejected: ${e.message}');
              }
            }
          }
        } catch (e) {
          debugPrint('[ExploreProvider] Expanded search failed: $e');
        }
      }

      if (localPath == null || successResult == null) {
        if (_isStale(myGeneration, prompt)) return;
        // Every result failed PDF validation even after increased search.
        _status = ExploreStatus.error;
        _errorMessage =
            "Couldn't find a valid full paper PDF for that — try rephrasing";
        notifyListeners();
        return;
      }

      if (_isStale(myGeneration, prompt)) return;

      // Step 5: Persist and update in-memory list.
      final entry = DownloadedPdf(
        title: successResult.title.isNotEmpty
            ? successResult.title
            : prompt,
        sourceUrl: successResult.url,
        localPath: localPath,
        downloadedAt: DateTime.now(),
      );

      await _repository.add(entry);
      _downloads = [entry, ..._downloads];
      _lastDownloadedPdf = entry;
      _status = ExploreStatus.success;
      notifyListeners();
    } catch (e) {
      if (_isStale(myGeneration, prompt)) return;
      // Outer catch: search failure, network error, unexpected exception.
      debugPrint('[ExploreProvider] _performSearchAndDownload failed: $e');
      _status = ExploreStatus.error;
      _errorMessage =
          "Couldn't find a downloadable PDF for that — try rephrasing";
      notifyListeners();
    }
  }

  /// Removes [pdf] from history and deletes its local file.
  Future<void> removeDownload(DownloadedPdf pdf) async {
    try {
      await _repository.remove(pdf.localPath);
      final file = File(pdf.localPath);
      if (await file.exists()) await file.delete();
      _downloads = _downloads.where((d) => d.localPath != pdf.localPath).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[ExploreProvider] removeDownload failed: $e');
    }
  }

  /// Removes all downloads from history and deletes all local files.
  Future<void> removeAllDownloads() async {
    try {
      for (final pdf in _downloads) {
        final file = File(pdf.localPath);
        if (await file.exists()) await file.delete();
      }
      await _repository.clearAll();
      _downloads = [];
      notifyListeners();
    } catch (e) {
      debugPrint('[ExploreProvider] removeAllDownloads failed: $e');
    }
  }

  /// Resets status back to idle (e.g. after showing a success/error state).
  void resetStatus() {
    _status = ExploreStatus.idle;
    _errorMessage = null;
    _clarificationRequest = null;
    _originalPrompt = null;
    notifyListeners();
  }
}

