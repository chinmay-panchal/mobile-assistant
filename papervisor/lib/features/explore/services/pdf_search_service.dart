import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// A single search result returned by the Tavily API.
class PdfSearchResult {
  final String title;
  final String url;

  const PdfSearchResult({required this.title, required this.url});
}

/// Queries the Tavily Search API for PDF documents matching [prompt].
///
/// The API key is injected at compile time via
/// `--dart-define-from-file=env.json` and read with [String.fromEnvironment].
class PdfSearchService {
  static const _endpoint = 'https://api.tavily.com/search';
  static String get _apiKey => dotenv.env['TAVILY_API_KEY'] ?? '';

  /// Searches for PDFs related to [prompt].
  ///
  /// Returns up to 5 [PdfSearchResult]s (title + URL).
  /// Throws a descriptive [Exception] on non-200 responses or empty results.
  Future<List<PdfSearchResult>> search(
    String prompt, {
    bool isExpanded = false,
    int maxResults = 25,
  }) async {
    debugPrint('[PdfSearchService] API key present: ${_apiKey.isNotEmpty}');
    if (_apiKey.isEmpty) {
      throw Exception(
        'TAVILY_API_KEY is not set in the .env file.',
      );
    }

    debugPrint('[PdfSearchService] Searching: "$prompt" (isExpanded: $isExpanded, maxResults: $maxResults)');
    final promptLower = prompt.toLowerCase();
    final String extraFilters = (promptLower.contains('neet') && !promptLower.contains('pg'))
        ? ' -pg -ss -mds'
        : '';

    final String query;
    if (isExpanded) {
      // Relaxed query: drops strict filetype:pdf so portals like SelfStudys, PW, and AglaSem are returned
      query = '$prompt "question paper" OR "solved paper" OR "pyq" pdf download$extraFilters -syllabus -timetable -datesheet -brochure';
    } else {
      // Standard query: targets direct PDF files first
      query = '$prompt "question paper" OR "solved paper" OR "pyq"$extraFilters -student -batch -seats -counselling -allotment -notice -press -circular -syllabus -brochure -prospectus -timetable -datesheet filetype:pdf';
    }
    debugPrint('[PdfSearchService] Tavily search query: "$query"');

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'query': query,
        'search_depth': 'advanced',
        'max_results': maxResults,
      }),
    );

    debugPrint('[PdfSearchService] HTTP ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('[PdfSearchService] Error body: ${response.body}');
      throw Exception(
        'Tavily API error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawResults = data['results'] as List<dynamic>?;
    debugPrint('[PdfSearchService] Results count: ${rawResults?.length ?? 0}');

    if (rawResults == null || rawResults.isEmpty) {
      throw Exception('No results found for "$prompt".');
    }

    final results = rawResults.map((r) {
      final map = r as Map<String, dynamic>;
      return PdfSearchResult(
        title: (map['title'] as String? ?? '').trim(),
        url: (map['url'] as String? ?? '').trim(),
      );
    }).where((r) => r.url.isNotEmpty).toList();

    for (int i = 0; i < results.length && i < 5; i++) {
      debugPrint('[PdfSearchService] Result #${i + 1}: ${results[i].title} -> ${results[i].url}');
    }

    return results;
  }
}

