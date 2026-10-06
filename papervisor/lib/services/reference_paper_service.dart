import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'cache_service.dart';

class ReferencePaperService {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService.instance;

  /// Returns cached reference papers for a subject asynchronously if available
  Future<List<Map<String, dynamic>>?> getCachedReferencePapers(
    String subjectId,
  ) async {
    return _cacheService.getReferencePapers(subjectId);
  }

  /// Synchronous in-memory cached reference papers check
  List<Map<String, dynamic>>? getCachedReferencePapersSync(String subjectId) {
    return _cacheService.getReferencePapersSync(subjectId);
  }

  Future<Map<String, dynamic>> uploadReferencePaper({
    required String subjectId,
    required String title,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    int? year,
    String? examType,
  }) async {
    final token = await _apiClient.getAccessToken();
    final uri = Uri.parse(
      '${ApiClient.baseUrl}/subjects/$subjectId/reference-papers',
    );
    final request = http.MultipartRequest('POST', uri);
    request.headers['ngrok-skip-browser-warning'] = 'true';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    if (year != null) request.fields['year'] = year.toString();
    if (examType != null && examType.isNotEmpty)
      request.fields['exam_type'] = examType;
    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName ?? 'reference_paper.pdf',
        ),
      );
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    } else {
      throw Exception('Either filePath or fileBytes must be provided.');
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      if (result is Map<String, dynamic>) {
        await _cacheService.addCachedReferencePaper(subjectId, result);
      }
      return result;
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to upload reference paper');
      } catch (e) {
        if (e is FormatException)
          throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> listReferencePapers(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/subjects/$subjectId/reference-papers',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final list = data.cast<Map<String, dynamic>>();
        await _cacheService.cacheReferencePapers(subjectId, list);
        return list;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load reference papers');
      }
    } catch (e) {
      final cached = await _cacheService.getReferencePapers(subjectId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      if (e is FormatException)
        throw Exception('An unexpected server error occurred.');
      rethrow;
    }
  }

  Future<void> deleteReferencePaper(String paperId) async {
    final response = await _apiClient.delete('/reference-papers/$paperId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete reference paper');
      } catch (e) {
        if (e is FormatException)
          throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
    await _cacheService.removeReferencePaperFromAllCaches(paperId);
  }
}
