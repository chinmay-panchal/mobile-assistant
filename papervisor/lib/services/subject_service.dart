import 'dart:convert';
import '../services/api_client.dart';

class SubjectService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getSubjects(String workspaceId) async {
    final response = await _apiClient.get('/workspaces/$workspaceId/subjects');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load subjects');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> createSubject(String workspaceId, String name, String code) async {
    final response = await _apiClient.post(
      '/workspaces/$workspaceId/subjects',
      body: {'name': name, 'code': code},
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to create subject');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> getSubject(String subjectId) async {
    final response = await _apiClient.get('/subjects/$subjectId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch subject');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> updateSubject(String subjectId, String name) async {
    final response = await _apiClient.patch(
      '/subjects/$subjectId',
      body: {'name': name},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update subject');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    final response = await _apiClient.delete('/subjects/$subjectId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete subject');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }
}
