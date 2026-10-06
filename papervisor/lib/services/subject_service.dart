import 'dart:convert';
import '../services/api_client.dart';
import 'cache_service.dart';

class SubjectService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService.instance;

  /// Returns cached subjects for a workspace immediately if available
  Future<List<Map<String, dynamic>>?> getCachedSubjects(
    String workspaceId,
  ) async {
    return _cacheService.getSubjects(workspaceId);
  }

  /// Synchronous in-memory cached subjects check
  List<Map<String, dynamic>>? getCachedSubjectsSync(String workspaceId) {
    return _cacheService.getSubjectsSync(workspaceId);
  }

  Future<List<Map<String, dynamic>>> getSubjects(
    String workspaceId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/workspaces/$workspaceId/subjects',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheSubjects(workspaceId, list);
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load subjects');
      }
    } catch (e) {
      // Offline / network failure fallback to cache if available
      final cached = await _cacheService.getSubjects(workspaceId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException) {
        throw Exception('An unexpected server error occurred.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSubject(
    String workspaceId,
    String name,
    String code,
  ) async {
    final response = await _apiClient.post(
      '/workspaces/$workspaceId/subjects',
      body: {'name': name, 'code': code},
    );
    if (response.statusCode == 201) {
      await _cacheService.invalidateSubjects(workspaceId);
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

  Future<Map<String, dynamic>> updateSubject(
    String subjectId,
    String name,
  ) async {
    final response = await _apiClient.patch(
      '/subjects/$subjectId',
      body: {'name': name},
    );
    if (response.statusCode == 200) {
      await _cacheService.invalidateAllSubjects();
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
    } else {
      await _cacheService.invalidateAllSubjects();
    }
  }
}
