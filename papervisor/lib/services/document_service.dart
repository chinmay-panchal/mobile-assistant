import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';

class DocumentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String bookId,
    String? chapterId,
  }) async {
    final token = await _apiClient.getAccessToken();
    final uri = Uri.parse('${ApiClient.baseUrl}/documents/upload');

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['book_id'] = bookId;
    if (chapterId != null) {
      request.fields['chapter_id'] = chapterId;
    }

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 202 || response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to upload document');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> getDocumentStatus(String documentId) async {
    final response = await _apiClient.get('/documents/$documentId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch document status');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getDocumentsForBook(String bookId) async {
    final response = await _apiClient.get('/books/$bookId/documents');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch documents for book');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final response = await _apiClient.delete('/documents/$documentId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete document');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }
}
