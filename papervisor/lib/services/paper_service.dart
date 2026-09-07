import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class PaperService {
  final ApiClient _apiClient = ApiClient();

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
    final int validNumPct = (numericalPercentage != null && numericalPercentage >= 1) ? numericalPercentage : 1;

    final List<Map<String, dynamic>> chapterPayload = selectedChapterIds.map((id) {
      final item = <String, dynamic>{'chapter_id': id};
      if (enableChapterWeightage == true && chapterWeightages != null && chapterWeightages.containsKey(id)) {
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
      if (topicFocus != null && topicFocus.isNotEmpty) 'topic_focus': topicFocus,
      if (referencePaperId != null) 'reference_paper_id': referencePaperId,
      if (questionConfigs != null && questionConfigs.isNotEmpty) 'question_configs': questionConfigs,
      if (className != null && className.isNotEmpty) 'class_name': className,
      if (timeAllowedMinutes != null) 'time_allowed_minutes': timeAllowedMinutes,
      'chapter_weightages': chapterPayload,
    };

    final response = await _apiClient.post('/papers/generate', body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = response.body;
      if (kDebugMode) {
        print('=== FULL JSON RESPONSE START ===');
        for (int i = 0; i < resBody.length; i += 800) {
          print(resBody.substring(i, i + 800 > resBody.length ? resBody.length : i + 800));
        }
        print('=== FULL JSON RESPONSE END ===');
      }
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to generate paper');
      } catch (e) {
        if (e is FormatException) throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }

  /// Uploads the generated PDF bytes for a paper.
  /// POST /api/v1/papers/{paperId}/save-pdf (multipart/form-data)
  /// Returns the updated paper object (includes pdf_url).
  Future<Map<String, dynamic>> savePaperPdf({
    required String paperId,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final token = await _apiClient.getAccessToken();
    final url = Uri.parse('${ApiClient.baseUrl}/papers/$paperId/save-pdf');

    final request = http.MultipartRequest('POST', url);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: fileName,
      ),
    );

    if (kDebugMode) {
      print('[PaperService] Uploading PDF for paper $paperId → $url');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (kDebugMode) {
      print('[PaperService] Save PDF response [${response.statusCode}]: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to save PDF');
      } catch (e) {
        if (e is FormatException) throw Exception('Unexpected server error while saving PDF.');
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> listPapersBySubject(String subjectId) async {
    final response = await _apiClient.get('/subjects/$subjectId/papers');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load papers');
      } catch (e) {
        if (e is FormatException) throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }

  Future<void> deletePaper(String paperId) async {
    final response = await _apiClient.delete('/papers/$paperId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete paper');
      } catch (e) {
        if (e is FormatException) throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }
}
