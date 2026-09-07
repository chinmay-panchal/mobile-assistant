import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('[AuthService] Attempting registration for email: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('[AuthService] Registration successful for: $email');
        }
        await _apiClient.saveTokens(data['access_token'], data['refresh_token']);
        return data;
      } else {
        if (kDebugMode) {
          print('[AuthService ERROR] Registration returned status ${response.statusCode}: ${response.body}');
        }
        throw Exception(data['detail'] ?? 'Registration failed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[AuthService EXCEPTION] Registration failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('[AuthService] Attempting login for email: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[AuthService] Login successful for: $email');
        }
        await _apiClient.saveTokens(data['access_token'], data['refresh_token']);
        return data;
      } else {
        if (kDebugMode) {
          print('[AuthService ERROR] Login returned status ${response.statusCode}: ${response.body}');
        }
        throw Exception(data['detail'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[AuthService EXCEPTION] Login failed: $e');
        print(stackTrace);
      }
      rethrow;
    }
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
          print('[AuthService WARNING] Logout request failed: $e');
        }
      }
    }
    await _apiClient.clearTokens();
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    if (kDebugMode) {
      print('[AuthService] Requesting forgot password OTP for: $email');
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
        throw Exception(data['detail'] ?? 'Failed to send password reset OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService EXCEPTION] forgotPassword failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    if (kDebugMode) {
      print('[AuthService] Verifying reset OTP for: $email');
    }
    try {
      final response = await _apiClient.post(
        '/auth/verify-reset-otp',
        body: {
          'email': email,
          'otp': otp,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['detail'] ?? 'Invalid OTP code');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService EXCEPTION] verifyResetOtp failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    if (kDebugMode) {
      print('[AuthService] Resetting password');
    }
    try {
      final response = await _apiClient.post(
        '/auth/reset-password',
        body: {
          'reset_token': resetToken,
          'new_password': newPassword,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['detail'] ?? 'Password reset failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService EXCEPTION] resetPassword failed: $e');
      }
      rethrow;
    }
  }
}
