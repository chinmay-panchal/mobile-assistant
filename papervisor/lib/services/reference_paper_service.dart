import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ReferencePaperService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> uploadReferencePaper({
    required String subjectId,
    required String title,
    required String filePath,
    int? year,
    String? examType,
  }) async {
    final token = await _apiClient.getAccessToken();
    final uri = Uri.parse('${ApiClient.baseUrl}/subjects/$subjectId/reference-papers');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    if (year != null) request.fields['year'] = year.toString();
    if (examType != null && examType.isNotEmpty) request.fields['exam_type'] = examType;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to upload reference paper');
      } catch (e) {
        if (e is FormatException) throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> listReferencePapers(String subjectId) async {
    final response = await _apiClient.get('/subjects/$subjectId/reference-papers');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load reference papers');
      } catch (e) {
        if (e is FormatException) throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }

  Future<void> deleteReferencePaper(String paperId) async {
    final response = await _apiClient.delete('/reference-papers/$paperId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete reference paper');
      } catch (e) {
        if (e is FormatException) throw Exception('An unexpected server error occurred.');
        rethrow;
      }
    }
  }
}
