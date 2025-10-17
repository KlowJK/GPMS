import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GPMS/shared/models/user_entity.dart';
import 'package:GPMS/core/constants/exception/custom_exception.dart';
import 'package:GPMS/core/constants/exception/error_code.dart';
import 'dart:io';

class AuthService {
  /// Base URL configuration
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    const useEmulator = true;
    if (useEmulator) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://192.168.1.10:8080';
    }
  }

  static const _authKeys = [
    'token',
    'typeToken',
    'expiresAt',
    'id',
    'fullName',
    'email',
    'role',
    'duongDanAvt',
    'teacherId',
    'studentId',
  ];

  /// Helper to clear all auth keys
  static Future<void> _clearAuthKeys(SharedPreferences prefs) async {
    for (final key in _authKeys) {
      await prefs.remove(key);
    }
  }

  static Future<UserEntity> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');

    if (kDebugMode) {
      print('🔐 Attempting login to: $uri');
      print('👤 email: $email');
      print('🔑 password length: ${password.length}');
    }

    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'matKhau': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📨 Response status: ${response.statusCode}');
        print('📦 Response body: ${response.body}');
        print('📋 Response headers: ${response.headers}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];
        if (result == null) {
          throw CustomException(ErrorCode.internalServerError);
        }

        final user = UserEntity.fromJson(result);

        final prefs = await SharedPreferences.getInstance();
        await _clearAuthKeys(prefs);
        await prefs.setString('token', user.token);
        await prefs.setString('typeToken', user.typeToken);
        await prefs.setString('expiresAt', user.expiresAt);
        await prefs.setInt('id', user.id);
        if (user.studentId != null)
          await prefs.setInt('studentId', user.studentId!);
        await prefs.setString('email', user.email);
        await prefs.setString('role', user.role);
        if (user.duongDanAvt != null)
          await prefs.setString('duongDanAvt', user.duongDanAvt!);
        if (user.teacherId != null)
          await prefs.setInt('teacherId', user.teacherId!);
        if (user.fullName != null)
          await prefs.setString('fullName', user.fullName!);

        if (kDebugMode) {
          print('✅ LOGIN SUCCESSFUL');
          print('🔑 Token received: ${user.token}');
          print('🔑 Token length: ${user.token.length}');
          print(
            '💾 Token saved to SharedPreferences: ${prefs.getString('token')}',
          );
        }
        return user;
      } else {
        // Map lỗi từ server -> ErrorCode
        ErrorCode errorCode;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is! Map<String, dynamic>) {
            if (kDebugMode) print('⚠️ Invalid JSON response: $errorData');
            throw Exception('Invalid response format');
          }
          errorCode = ErrorCode.fromResponse(errorData);
          if (kDebugMode) {
            print(
              'Parsed errorCode: ${errorCode.name}, field: ${errorCode.field}',
            );
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error parsing error response: $e');
          errorCode = ErrorCode.internalServerError;
        }
        throw CustomException(errorCode);
      }
    } on TimeoutException {
      throw (ErrorCode.internalServerError);
    } on SocketException catch (_) {
      throw CustomException(ErrorCode.internalServerError);
    } on http.ClientException catch (_) {
      throw CustomException(ErrorCode.internalServerError);
    } on CustomException {
      rethrow;
    } catch (e, st) {
      if (kDebugMode) print('❌ Unexpected login error: $e\n$st');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Get token from SharedPreferences
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (kDebugMode) {
        print('🔍 Retrieving token from SharedPreferences:');
        print('   - Token exists: [31m${token != null}[0m');
        print('   - Token length: ${token?.length ?? 0}');
        if (token == null || token.isEmpty) {
          print('❌ Token is null or empty!');
        } else {
          print(
            '   - Token first 20 chars: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          );
        }
        print('   - All SharedPreferences keys: ${prefs.getKeys()}');
      }
      if (token == null || token.isEmpty) {
        return null;
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token: $e');
      }
      return null;
    }
  }

  /// Get current user from SharedPreferences
  static Future<UserEntity?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (kDebugMode) {
        print('🔍 Retrieving current user from SharedPreferences:');
        for (var key in prefs.getKeys()) {
          final value = prefs.get(key);
          print('   - $key: $value (${value.runtimeType})');
        }
      }

      final token = prefs.getString('token');
      final typeToken = prefs.getString('typeToken');
      final expiresAt = prefs.getString('expiresAt');
      final id = prefs.getInt('id');
      final fullName = prefs.getString('fullName');
      final email = prefs.getString('email');
      final role = prefs.getString('role');
      final duongDanAvt = prefs.getString('duongDanAvt');
      final teacherId = prefs.getInt('teacherId');
      final studentId = prefs.getInt('studentId');

      if (token == null || email == null || role == null || id == null) {
        if (kDebugMode) {
          print('❌ Incomplete user data in SharedPreferences');
        }
        return null;
      }

      final user = UserEntity(
        token: token,
        typeToken: typeToken ?? '',
        expiresAt: expiresAt ?? '',
        id: id,
        fullName: fullName,
        email: email,
        role: role,
        duongDanAvt: duongDanAvt,
        teacherId: teacherId,
        studentId: studentId,
      );

      if (kDebugMode) {
        print('✅ Current user retrieved successfully');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting current user: $e');
      }
      return null;
    }
  }

  /// Logout with debug
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (kDebugMode) {
        print('🚪 Logging out - Clearing SharedPreferences');
        print('   - Current token: ${prefs.getString('token')}');
        print(
          '   - Current avatar: ${prefs.getString('profile_avatar_base64')}',
        );
      }

      await _clearAuthKeys(prefs);

      if (kDebugMode) {
        print('✅ Logout successful - Auth keys cleared');
        print('   - Token after clear: ${prefs.getString('token')}');
        print(
          '   - Avatar still exists: ${prefs.getString('profile_avatar_base64')}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during logout: $e');
      }
      rethrow;
    }
  }

  /// Verify token consistency in SharedPreferences
  static Future<bool> verifyTokenConsistency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final currentUser = await getCurrentUser();

      final isConsistent = savedToken == currentUser?.token;

      if (kDebugMode) {
        print('🔍 Token consistency check:');
        print('   - Saved token: $savedToken');
        print('   - User token: ${currentUser?.token}');
        print('   - Consistent: $isConsistent');
      }

      return isConsistent;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying token consistency: $e');
      }
      return false;
    }
  }
}
