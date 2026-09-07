import 'dart:convert';
import '../services/api_client.dart';

class ChapterService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getChapters(String bookId) async {
    final response = await _apiClient.get('/books/$bookId/chapters');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load chapters');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> createChapter(String bookId, int chapterNumber, String title, {int? startPage, int? endPage}) async {
    final body = <String, dynamic>{
      'chapter_number': chapterNumber,
      'name': title,
    };
    if (startPage != null) body['start_page'] = startPage;
    if (endPage != null) body['end_page'] = endPage;

    final response = await _apiClient.post(
      '/books/$bookId/chapters',
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to create chapter');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> getChapter(String chapterId) async {
    final response = await _apiClient.get('/chapters/$chapterId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch chapter');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> updateChapter(String chapterId, int chapterNumber, String title, {int? startPage, int? endPage}) async {
    final body = <String, dynamic>{
      'chapter_number': chapterNumber,
      'name': title,
    };
    if (startPage != null) body['start_page'] = startPage;
    if (endPage != null) body['end_page'] = endPage;

    final response = await _apiClient.patch(
      '/chapters/$chapterId',
      body: body,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update chapter');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<void> deleteChapter(String chapterId) async {
    final response = await _apiClient.delete('/chapters/$chapterId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete chapter');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }
}
