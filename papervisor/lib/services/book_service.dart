import 'dart:convert';
import '../services/api_client.dart';

class BookService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getBooks(String subjectId) async {
    final response = await _apiClient.get('/subjects/$subjectId/books');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load books');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> createBook(String subjectId, String name) async {
    final response = await _apiClient.post(
      '/subjects/$subjectId/books',
      body: {'name': name},
    );
    if (response.statusCode == 201) {
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
    }
  }
}
