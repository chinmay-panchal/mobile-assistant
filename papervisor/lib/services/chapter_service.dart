import 'dart:convert';
import '../services/api_client.dart';
import 'cache_service.dart';

class ChapterService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService.instance;

  /// Returns cached chapters for a book immediately if available
  Future<List<Map<String, dynamic>>?> getCachedChapters(String bookId) async {
    return _cacheService.getChapters(bookId);
  }

  /// Synchronous in-memory cached chapters check
  List<Map<String, dynamic>>? getCachedChaptersSync(String bookId) {
    return _cacheService.getChaptersSync(bookId);
  }

  Future<List<Map<String, dynamic>>> getChapters(
    String bookId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get('/books/$bookId/chapters');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheChapters(bookId, list);
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load chapters');
      }
    } catch (e) {
      // Offline / network failure fallback to cache if available
      final cached = await _cacheService.getChapters(bookId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException) {
        throw Exception('An unexpected server error occurred.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createChapter(
    String bookId,
    int chapterNumber,
    String title, {
    int? startPage,
    int? endPage,
  }) async {
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
      await _cacheService.invalidateChapters(bookId);
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

  Future<Map<String, dynamic>> updateChapter(
    String chapterId,
    int chapterNumber,
    String title, {
    int? startPage,
    int? endPage,
  }) async {
    final body = <String, dynamic>{
      'chapter_number': chapterNumber,
      'name': title,
    };
    if (startPage != null) body['start_page'] = startPage;
    if (endPage != null) body['end_page'] = endPage;

    final response = await _apiClient.patch('/chapters/$chapterId', body: body);
    if (response.statusCode == 200) {
      await _cacheService.invalidateAllChapters();
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
    } else {
      await _cacheService.invalidateAllChapters();
    }
  }
}
