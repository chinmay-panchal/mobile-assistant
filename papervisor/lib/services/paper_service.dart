import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/utils/error_sanitizer.dart';
import 'api_client.dart';
import 'cache_service.dart';

class PaperService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService.instance;

  /// Returns cached papers for a subject asynchronously if available
  Future<List<Map<String, dynamic>>?> getCachedPapers(String subjectId) async {
    return _cacheService.getPapers(subjectId);
  }

  /// Synchronous in-memory cached papers check
  List<Map<String, dynamic>>? getCachedPapersSync(String subjectId) {
    return _cacheService.getPapersSync(subjectId);
  }

  /// Returns cached paper detail
  Future<Map<String, dynamic>?> getCachedPaperDetail(String paperId) async {
    return _cacheService.getPaperDetail(paperId);
  }

  /// Synchronous in-memory cached paper detail
  Map<String, dynamic>? getCachedPaperDetailSync(String paperId) {
    return _cacheService.getPaperDetailSync(paperId);
  }

  /// Updates a paper in all cached subject lists and detail caches (e.g. after editing JSON content or saving PDF)
  Future<void> updatePaperInCache(
    String paperId,
    Map<String, dynamic> updatedPaper,
  ) async {
    await _cacheService.updatePaperInCaches(paperId, updatedPaper);
  }

  /// Adds a newly generated paper directly into the subject's cached list
  Future<void> addCachedPaper(
    String subjectId,
    Map<String, dynamic> paper,
  ) async {
    await _cacheService.addCachedPaper(subjectId, paper);
  }

  Future<Map<String, dynamic>> generatePaper({
    required String bookId,
    required List<String> selectedChapterIds,
    required String generationMode,
    required int totalMarks,
    required String difficulty,
    required String title,
    required bool includeAnswers,
    String? topicFocus,
    String? referencePaperId,
    List<Map<String, dynamic>>? questionConfigs,
    String? className,
    int? timeAllowedMinutes,
    bool? enableNumericalPercentage,
    int? numericalPercentage,
    int? easyPercentage,
    int? mediumPercentage,
    int? hardPercentage,
    bool? enableChapterWeightage,
    Map<String, int>? chapterWeightages,
  }) async {
    final int validNumPct =
        (numericalPercentage != null && numericalPercentage >= 1)
        ? numericalPercentage
        : 1;

    final List<Map<String, dynamic>> chapterPayload = selectedChapterIds.map((
      id,
    ) {
      final item = <String, dynamic>{'chapter_id': id};
      if (enableChapterWeightage == true &&
          chapterWeightages != null &&
          chapterWeightages.containsKey(id)) {
        item['weightage_percentage'] = chapterWeightages[id];
      }
      return item;
    }).toList();

    final body = <String, dynamic>{
      'book_id': bookId,
      'selected_chapters': chapterPayload,
      'selected_chapter_ids': selectedChapterIds,
      'generation_mode': generationMode,
      'total_marks': totalMarks,
      'difficulty': difficulty,
      'easy_percentage': easyPercentage ?? 50,
      'medium_percentage': mediumPercentage ?? 25,
      'hard_percentage': hardPercentage ?? 25,
      'title': title,
      'include_answers': includeAnswers,
      'enable_numerical_percentage': enableNumericalPercentage ?? false,
      'numerical_percentage': validNumPct,
      if (topicFocus != null && topicFocus.isNotEmpty)
        'topic_focus': topicFocus,
      if (referencePaperId != null) 'reference_paper_id': referencePaperId,
      if (questionConfigs != null && questionConfigs.isNotEmpty)
        'question_configs': questionConfigs,
      if (className != null && className.isNotEmpty) 'class_name': className,
      if (timeAllowedMinutes != null)
        'time_allowed_minutes': timeAllowedMinutes,
      'chapter_weightages': chapterPayload,
    };

    final response = await _apiClient.post('/papers/generate', body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = response.body;
      if (kDebugMode) {
        //         print('=== FULL JSON RESPONSE START ===');
        for (int i = 0; i < resBody.length; i += 800) {
          //           print(resBody.substring(i, i + 800 > resBody.length ? resBody.length : i + 800));
        }
        //         print('=== FULL JSON RESPONSE END ===');
      }
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        final rawDetail = error['detail'] ?? 'Failed to generate paper';
        throw Exception(ErrorSanitizer.sanitize(rawDetail));
      } catch (e) {
        if (e is FormatException)
          throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }

  /// Uploads the generated PDF bytes for a paper.
  /// POST /api/v1/papers/{paperId}/save-pdf (multipart/form-data)
  /// Returns the updated paper object (includes pdf_url) and updates cache.
  Future<Map<String, dynamic>> savePaperPdf({
    required String paperId,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final token = await _apiClient.getAccessToken();
    final url = Uri.parse('${ApiClient.baseUrl}/papers/$paperId/save-pdf');

    final request = http.MultipartRequest('POST', url);
    request.headers['ngrok-skip-browser-warning'] = 'true';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', pdfBytes, filename: fileName),
    );

    if (kDebugMode) {
      //       print('[PaperService] Uploading PDF for paper $paperId → $url');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (kDebugMode) {
      //       print('[PaperService] Save PDF response [${response.statusCode}]: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final updatedPaper = jsonDecode(response.body);
      if (updatedPaper is Map<String, dynamic>) {
        await _cacheService.updatePaperInCaches(paperId, updatedPaper);
      }
      return updatedPaper;
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to save PDF');
      } catch (e) {
        if (e is FormatException)
          throw Exception('Unexpected server error while saving PDF.');
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> listPapersBySubject(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get('/subjects/$subjectId/papers');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cachePapers(subjectId, list);
        for (final p in list) {
          final pid = p['id']?.toString();
          if (pid != null && pid.isNotEmpty) {
            await _cacheService.cachePaperDetail(pid, p);
          }
        }
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load papers');
      }
    } catch (e) {
      final cached = await _cacheService.getPapers(subjectId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException)
        throw Exception('An unexpected server error occurred.');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaper(
    String paperId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get('/papers/$paperId');
      if (response.statusCode == 200) {
        final paper = jsonDecode(response.body);
        if (paper is Map<String, dynamic>) {
          await _cacheService.cachePaperDetail(paperId, paper);
        }
        return paper;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load paper details');
      }
    } catch (e) {
      final cached = await _cacheService.getPaperDetail(paperId);
      if (cached != null) {
        return cached;
      }
      if (e is FormatException)
        throw Exception('An unexpected server error occurred.');
      rethrow;
    }
  }

  Future<void> deletePaper(String paperId) async {
    final response = await _apiClient.delete('/papers/$paperId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete paper');
      } catch (e) {
        if (e is FormatException)
          throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
    await _cacheService.removePaperFromAllCaches(paperId);
  }
}
