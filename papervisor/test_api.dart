import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://localhost:8000/api/v1';
  
  // Try to register a test user
  final registerRes = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': 'Test User',
      'email': 'testuser2@example.com',
      'password': 'password123'
    }),
  );
  print('Register: ${registerRes.statusCode} ${registerRes.body}');
  
  // Login
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'testuser2@example.com',
      'password': 'password123'
    }),
  );
  print('Login: ${loginRes.statusCode} ${loginRes.body}');
  
  if (loginRes.statusCode == 200) {
    final token = jsonDecode(loginRes.body)['access_token'];
    
    // Create workspace
    final wsRes = await http.post(
      Uri.parse('$baseUrl/workspaces'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'name': 'Test Workspace', 'description': ''}),
    );
    print('Workspace: ${wsRes.statusCode} ${wsRes.body}');
    final wsId = jsonDecode(wsRes.body)['id'];

    // Create subject
    final subRes = await http.post(
      Uri.parse('$baseUrl/workspaces/$wsId/subjects'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'name': 'Test Subject', 'description': ''}),
    );
    print('Subject: ${subRes.statusCode} ${subRes.body}');
    final subId = jsonDecode(subRes.body)['id'];

    // Create book
    final bookRes = await http.post(
      Uri.parse('$baseUrl/subjects/$subId/books'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'name': 'Test Book', 'description': ''}),
    );
    print('Book: ${bookRes.statusCode} ${bookRes.body}');
    final bookId = jsonDecode(bookRes.body)['id'];

    // Get chapters
    final getChapRes = await http.get(
      Uri.parse('$baseUrl/books/$bookId/chapters'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Get Chapters: ${getChapRes.statusCode} ${getChapRes.body}');
  }
}
