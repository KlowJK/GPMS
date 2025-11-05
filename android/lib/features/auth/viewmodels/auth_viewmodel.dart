import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GPMS/shared/models/user_entity.dart';
import 'package:GPMS/features/auth/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  UserEntity? _user;

  bool get _isLoggedIn => _user != null;
  bool get isLoggedIn => _isLoggedIn;
  UserEntity? get user => _user;

  bool get isTeacher => _user?.role == 'GIANG_VIEN';
  bool get isStudent => _user?.role == 'SINH_VIEN';

  Future<void> login(String email, String password) async {
    final user = await AuthService.login(email, password);
    _user = user;
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
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
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await AuthService.logoutRemote(); // không critical nếu fail
    } catch (e) {
      if (kDebugMode) print('⚠️ Logout remote failed: $e');
    } finally {
      await AuthService.clearLocalSession();
      _user = null;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await AuthService.requestResetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  /// ĐẶT LẠI MẬT KHẨU MỚI
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await AuthService.resetPassword(token: token, newPassword: newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
