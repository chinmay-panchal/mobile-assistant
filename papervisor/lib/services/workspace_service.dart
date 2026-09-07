import 'dart:convert';
import '../services/api_client.dart';

class WorkspaceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    final response = await _apiClient.get('/workspaces');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load workspaces');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> createWorkspace(String name) async {
    final response = await _apiClient.post('/workspaces', body: {'name': name});
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to create workspace');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> getWorkspace(String workspaceId) async {
    final response = await _apiClient.get('/workspaces/$workspaceId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch workspace');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> updateWorkspace(String workspaceId, String name) async {
    final response = await _apiClient.patch('/workspaces/$workspaceId', body: {'name': name});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update workspace');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    final response = await _apiClient.delete('/workspaces/$workspaceId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete workspace');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('An unexpected server error occurred.');
        }
        rethrow;
      }
    }
  }
}
