import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GPMS/shared/models/user_entity.dart';
import 'package:GPMS/features/auth/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoggedIn => _user != null;
  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // Role checks
  bool get isTeacher => _user?.role == 'GIANG_VIEN';
  bool get isStudent => _user?.role == 'SINH_VIEN';

  /// Login with loading state
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await AuthService.login(email, password);
      _user = user;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user from storage with loading state
  Future<void> loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
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

      if (token != null && email != null && role != null && id != null) {
        _user = UserEntity(
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
      } else {
        _user = null;
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error loading user from storage: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout with loading state
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logoutRemote();
    } catch (e) {
      if (kDebugMode) print('⚠️ Logout remote failed: $e');
    } finally {
      await AuthService.clearLocalSession();
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.requestResetPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.resetPassword(token: token, newPassword: newPassword);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
