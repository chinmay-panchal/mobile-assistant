import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Using ADB reverse port forwarding (adb reverse tcp:8000 tcp:8000) for USB connected Android device / emulator
  // static const String baseUrl = 'http://192.168.1.71:8000/api/v1';
  static const String baseUrl = 'https://revisit-humongous-wiry.ngrok-free.dev/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static void Function()? onUnauthorized;
  static Future<bool>? _refreshTokenFuture;

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    if (kDebugMode) {
      print('[ApiClient] Tokens saved successfully.');
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    if (kDebugMode) {
      print('[ApiClient] Tokens cleared.');
    }
    onUnauthorized?.call();
  }

  Map<String, String> _headers(String? token, {bool isJson = true}) {
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _logResponse(String method, int statusCode, String body) {
    if (!kDebugMode) return;
    print('[ApiClient] $method Response [$statusCode] (length: ${body.length}) ->');
    for (int i = 0; i < body.length; i += 800) {
      print(body.substring(i, i + 800 > body.length ? body.length : i + 800));
    }
  }

  Future<http.Response> get(String endpoint) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('[ApiClient] GET Request -> $url');
    }

    try {
      var response = await http.get(url, headers: _headers(token));
      _logResponse('GET', response.statusCode, response.body);

      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await getAccessToken();
          response = await http.get(url, headers: _headers(newToken));
        }
      }
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[ApiClient ERROR] GET $url failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final token = requiresAuth ? await getAccessToken() : null;
    final url = Uri.parse('$baseUrl$endpoint');
    final payload = body != null ? jsonEncode(body) : null;

    if (kDebugMode) {
      print('[ApiClient] POST Request -> $url | Body: $payload');
    }

    try {
      var response = await http.post(
        url,
        headers: _headers(token),
        body: payload,
      );

      _logResponse('POST', response.statusCode, response.body);


      if (requiresAuth && response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await getAccessToken();
          response = await http.post(
            url,
            headers: _headers(newToken),
            body: payload,
          );
        }
      }
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[ApiClient ERROR] POST $url failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final payload = body != null ? jsonEncode(body) : null;

    if (kDebugMode) {
      print('[ApiClient] PUT Request -> $url | Body: $payload');
    }

    try {
      var response = await http.put(
        url,
        headers: _headers(token),
        body: payload,
      );

      _logResponse('PUT', response.statusCode, response.body);


      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await getAccessToken();
          response = await http.put(
            url,
            headers: _headers(newToken),
            body: payload,
          );
        }
      }
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[ApiClient ERROR] PUT $url failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final payload = body != null ? jsonEncode(body) : null;

    if (kDebugMode) {
      print('[ApiClient] PATCH Request -> $url | Body: $payload');
    }

    try {
      var response = await http.patch(
        url,
        headers: _headers(token),
        body: payload,
      );

      _logResponse('PATCH', response.statusCode, response.body);


      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await getAccessToken();
          response = await http.patch(
            url,
            headers: _headers(newToken),
            body: payload,
          );
        }
      }
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[ApiClient ERROR] PATCH $url failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');

    if (kDebugMode) {
      print('[ApiClient] DELETE Request -> $url');
    }

    try {
      var response = await http.delete(url, headers: _headers(token));

      _logResponse('DELETE', response.statusCode, response.body);


      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await getAccessToken();
          response = await http.delete(url, headers: _headers(newToken));
        }
      }
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[ApiClient ERROR] DELETE $url failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<bool> _refreshToken() async {
    if (_refreshTokenFuture != null) {
      if (kDebugMode) {
        print('[ApiClient] Token refresh already in progress. Awaiting existing refresh request...');
      }
      return await _refreshTokenFuture!;
    }

    _refreshTokenFuture = _performTokenRefresh();
    try {
      final result = await _refreshTokenFuture!;
      return result;
    } finally {
      _refreshTokenFuture = null;
    }
  }

  Future<bool> _performTokenRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final url = Uri.parse('$baseUrl/auth/refresh');
    if (kDebugMode) {
      print('[ApiClient] Attempting token refresh -> $url');
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      _logResponse('POST (Refresh Token)', response.statusCode, response.body);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access_token'], data['refresh_token']);
        return true;
      } else {
        await clearTokens();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ApiClient ERROR] Token refresh failed: $e');
      }
      await clearTokens();
      return false;
    }
  }
}
