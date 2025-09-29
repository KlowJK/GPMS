import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user_entity.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  UserEntity? _user;

  bool get isLoggedIn => _user != null;
  UserEntity? get user => _user;

  bool get isTeacher =>
      _user?.role == 'ROLE_TEACHER' || _user?.role == 'ROLE_GIANGVIEN';
  bool get isStudent =>
      _user?.role == 'ROLE_STUDENT' || _user?.role == 'ROLE_SINHVIEN';

  Future<void> login(String email, String password) async {
    try {
      final u = await AuthService.login(email, password);
      _user = u;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', u.token);
      await prefs.setString('email', u.email);
      await prefs.setString('role', u.role);

      await prefs.setInt('id', u.id);
      if (u.teacherId != null) {
        await prefs.setInt('teacherId', u.teacherId!);
      } else {
        await prefs.remove('teacherId');
      }
      if (u.studentId != null) {
        await prefs.setInt('studentId', u.studentId!);
      } else {
        await prefs.remove('studentId');
      }
      if (u.fullName != null) {
        await prefs.setString('fullName', u.fullName!);
      } else {
        await prefs.remove('fullName');
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final typeToken = prefs.getString('typeToken');
    final expiresAt = prefs.getString('expiresAt');
    final id = prefs.getInt('id'); // 👈 dùng 'id'
    final fullName = prefs.getString('fullName');
    final email = prefs.getString('email');
    final role = prefs.getString('role');
    final duongDanAvt = prefs.getString('duongDanAvt');
    final teacherId = prefs.getInt('teacherId'); // 👈 camelCase
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
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('id');
    await prefs.remove('teacherId');
    await prefs.remove('studentId');
    await prefs.remove('fullName');
    notifyListeners();
  }
}
