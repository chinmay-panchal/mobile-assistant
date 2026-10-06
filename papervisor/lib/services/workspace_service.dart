import 'dart:convert';
import '../services/api_client.dart';

import 'cache_service.dart';

class WorkspaceService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService.instance;

  /// Returns cached workspaces immediately if available
  Future<List<Map<String, dynamic>>?> getCachedWorkspaces() async {
    return _cacheService.getWorkspaces();
  }

  /// Synchronous in-memory cached workspaces check
  List<Map<String, dynamic>>? getCachedWorkspacesSync() {
    return _cacheService.getWorkspacesSync();
  }

  Future<List<Map<String, dynamic>>> getWorkspaces({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get('/workspaces');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheWorkspaces(list);
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load workspaces');
      }
    } catch (e) {
      // Offline / network failure fallback to cache if available
      final cached = await _cacheService.getWorkspaces();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException) {
        throw Exception('An unexpected server error occurred.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createWorkspace(String name) async {
    final response = await _apiClient.post('/workspaces', body: {'name': name});
    if (response.statusCode == 201) {
      await _cacheService.invalidateWorkspaces();
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

  Future<Map<String, dynamic>> updateWorkspace(
    String workspaceId,
    String name,
  ) async {
    final response = await _apiClient.patch(
      '/workspaces/$workspaceId',
      body: {'name': name},
    );
    if (response.statusCode == 200) {
      await _cacheService.invalidateWorkspaces();
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
    } else {
      await _cacheService.invalidateWorkspaces();
    }
  }
}
