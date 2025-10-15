import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user_entity.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  UserEntity? _user;

  bool get isLoggedIn => _user != null;
  UserEntity? get user => _user;

  bool get isTeacher => _user?.role == 'GIANG_VIEN';
  bool get isStudent => _user?.role == 'SINH_VIEN';

  Future<void> login(String email, String password) async {
    try {
      final u = await AuthService.login(email, password);
      _user = u;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', u.token);
      await prefs.setString('typeToken', u.typeToken);
      await prefs.setString('expiresAt', u.expiresAt);
      await prefs.setInt('id', u.id);
      if (u.fullName != null) {
        await prefs.setString('fullName', u.fullName!);
      } else {
        await prefs.remove('fullName');
      }
      await prefs.setString('email', u.email);
      await prefs.setString('role', u.role);
      if (u.duongDanAvt != null) {
        await prefs.setString('duongDanAvt', u.duongDanAvt!);
      } else {
        await prefs.remove('duongDanAvt');
      }
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
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('typeToken');
    await prefs.remove('expiresAt');
    await prefs.remove('id');
    await prefs.remove('fullName');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('duongDanAvt');
    await prefs.remove('teacherId');
    await prefs.remove('studentId');
    notifyListeners();
  }
}
