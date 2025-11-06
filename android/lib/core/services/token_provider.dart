import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Token Provider Service
///
/// Centralized token management cho dependency injection
/// Có thể mock cho testing
class TokenProvider {
  static const String _tokenKey = 'token';

  /// Get token từ SharedPreferences
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (kDebugMode) {
        print('🔍 TokenProvider.getToken()');
        print('   - Token exists: ${token != null}');
        if (token != null && token.isNotEmpty) {
          print('   - Token length: ${token.length}');
          print(
            '   - Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          );
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ TokenProvider.getToken() error: $e');
      }
      return null;
    }
  }

  /// Save token to SharedPreferences
  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(_tokenKey, token);

      if (kDebugMode) {
        print('💾 TokenProvider.saveToken()');
        print('   - Success: $result');
        print('   - Token length: ${token.length}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ TokenProvider.saveToken() error: $e');
      }
      return false;
    }
  }

  /// Clear token
  Future<bool> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_tokenKey);

      if (kDebugMode) {
        print('🗑️ TokenProvider.clearToken()');
        print('   - Success: $result');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ TokenProvider.clearToken() error: $e');
      }
      return false;
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<int> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;

      if (kDebugMode) {
        print('🔍 TokenProvider.getUserId()');
        print('   - User ID: $userId');
      }

      return userId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ TokenProvider.getUserId() error: $e');
      }
      return 0;
    }
  }
}
