import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/utils/error_sanitizer.dart';
import '../services/api_client.dart';
import 'cache_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      //       print('[AuthService] Attempting registration for email: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: {'name': name, 'email': email, 'password': password},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (kDebugMode) {
          //           print('[AuthService] Registration successful for: $email');
        }
        await _apiClient.saveTokens(
          data['access_token'],
          data['refresh_token'],
          name: name,
          email: email,
        );
        return data;
      } else {
        if (kDebugMode) {
          //           print('[AuthService ERROR] Registration returned status ${response.statusCode}: ${response.body}');
        }
        throw Exception(
          ErrorSanitizer.sanitize(data['detail'] ?? 'Registration failed'),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        //         print('[AuthService EXCEPTION] Registration failed: $e');
        //         print(stackTrace);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      //       print('[AuthService] Attempting login for email: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          //           print('[AuthService] Login successful for: $email');
        }
        String? userName = data['name'] ?? data['user']?['name'];
        if (userName == null && data['access_token'] is String) {
          final payload = _decodeJwtPayload(data['access_token']);
          userName =
              payload['name'] ?? payload['sub_name'] ?? payload['user_name'];
        }

        if (kDebugMode) {
          //           print('[AuthService] User name resolved as: $userName');
        }

        await _apiClient.saveTokens(
          data['access_token'],
          data['refresh_token'],
          name: userName,
          email: email,
        );
        return data;
      } else {
        if (kDebugMode) {
          //           print('[AuthService ERROR] Login returned status ${response.statusCode}: ${response.body}');
        }
        throw Exception(
          ErrorSanitizer.sanitize(data['detail'] ?? 'Login failed'),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        //         print('[AuthService EXCEPTION] Login failed: $e');
        //         print(stackTrace);
      }
      rethrow;
    }
  }

  Future<Map<String, String>> getUserProfile() async {
    String? name = await _apiClient.getUserName();
    String? email = await _apiClient.getUserEmail();

    if (name == null || email == null) {
      final token = await _apiClient.getAccessToken();
      if (token != null) {
        final payload = _decodeJwtPayload(token);
        name ??= payload['name'] ?? payload['sub_name'] ?? payload['user_name'];
        email ??= payload['email'] ?? payload['sub'];
        if (name != null || email != null) {
          await _apiClient.saveUserInfo(name: name, email: email);
        }
      }
    }

    if (name == null || email == null) {
      try {
        final res = await _apiClient.get('/auth/me');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          name ??= data['name'] ?? data['user']?['name'];
          email ??= data['email'] ?? data['user']?['email'];
          await _apiClient.saveUserInfo(name: name, email: email);
        }
      } catch (_) {}
    }

    return {
      'name': name ?? 'Educator',
      'email': email ?? 'educator@papervisor.com',
    };
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final jsonStr = utf8.decode(base64Url.decode(normalized));
        return jsonDecode(jsonStr);
      }
    } catch (_) {}
    return {};
  }

  Future<void> deleteAccount() async {
    final userName = await _apiClient.getUserName();
    if (kDebugMode) {
      //       print('[AuthService] Attempting deleteAccount endpoint for user: $userName');
    }
    try {
      final res = await _apiClient.delete('/auth/delete-account');
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Failed with status ${res.statusCode}');
      }
    } catch (e) {
      //       if (kDebugMode) print('[AuthService] /auth/delete-account failed: $e');
      rethrow;
    }
    await logout();
  }

  Future<void> logout() async {
    final refreshToken = await _apiClient.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _apiClient.post(
          '/auth/logout',
          body: {'refresh_token': refreshToken},
          requiresAuth: true,
        );
      } catch (e) {
        if (kDebugMode) {
          //           print('[AuthService WARNING] Logout request failed: $e');
        }
      }
    }
    await _apiClient.clearTokens();
    await CacheService.instance.clearAll();
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    if (kDebugMode) {
      //       print('[AuthService] Requesting forgot password OTP for: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/forgot-password',
        body: {'email': email},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          ErrorSanitizer.sanitize(
            data['detail'] ?? 'Failed to send password reset OTP',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        //         print('[AuthService EXCEPTION] forgotPassword failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    if (kDebugMode) {
      //       print('[AuthService] Verifying reset OTP for: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/verify-reset-otp',
        body: {'email': email, 'otp': otp},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          ErrorSanitizer.sanitize(data['detail'] ?? 'Invalid OTP code'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        //         print('[AuthService EXCEPTION] verifyResetOtp failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    if (kDebugMode) {
      //       print('[AuthService] Resetting password');
    }
    try {
      final response = await _apiClient.post(
        '/auth/reset-password',
        body: {'reset_token': resetToken, 'new_password': newPassword},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          ErrorSanitizer.sanitize(data['detail'] ?? 'Password reset failed'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        //         print('[AuthService EXCEPTION] resetPassword failed: $e');
      }
      rethrow;
    }
  }
}
