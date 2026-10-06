import 'dart:convert';
import '../services/api_client.dart';
import 'cache_service.dart';

class BookService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService.instance;

  /// Returns cached books for a subject immediately if available
  Future<List<Map<String, dynamic>>?> getCachedBooks(String subjectId) async {
    return _cacheService.getBooks(subjectId);
  }

  /// Synchronous in-memory cached books check
  List<Map<String, dynamic>>? getCachedBooksSync(String subjectId) {
    return _cacheService.getBooksSync(subjectId);
  }

  /// Returns all cached books immediately if available
  Future<List<Map<String, dynamic>>?> getCachedAllBooks() async {
    return _cacheService.getAllBooks();
  }

  /// Synchronous in-memory all cached books check
  List<Map<String, dynamic>>? getCachedAllBooksSync() {
    return _cacheService.getAllBooksSync();
  }

  Future<List<Map<String, dynamic>>> getAllBooks({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get('/books');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheAllBooks(list);
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load books');
      }
    } catch (e) {
      // Offline / network failure fallback to cache if available
      final cached = await _cacheService.getAllBooks();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException) {
        throw Exception('An unexpected server error occurred.');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBooks(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get('/subjects/$subjectId/books');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheBooks(subjectId, list);
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load books');
      }
    } catch (e) {
      // Offline / network failure fallback to cache if available
      final cached = await _cacheService.getBooks(subjectId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException) {
        throw Exception('An unexpected server error occurred.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBook(String subjectId, String name) async {
    final response = await _apiClient.post(
      '/subjects/$subjectId/books',
      body: {'name': name},
    );
    if (response.statusCode == 201) {
      await _cacheService.invalidateBooks(subjectId);
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to create book');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> getBook(String bookId) async {
    final response = await _apiClient.get('/books/$bookId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch book');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> updateBook(String bookId, String name) async {
    final response = await _apiClient.patch(
      '/books/$bookId',
      body: {'name': name},
    );
    if (response.statusCode == 200) {
      await _cacheService.invalidateAllBooks();
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update book');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<void> deleteBook(String bookId) async {
    final response = await _apiClient.delete('/books/$bookId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete book');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    } else {
      await _cacheService.invalidateAllBooks();
    }
  }
}
