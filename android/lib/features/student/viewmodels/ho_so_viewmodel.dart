import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../auth/services/auth_service.dart';
import '../models/student_profile.dart';
import '../services/ho_so_service.dart';

class HoSoViewModel extends ChangeNotifier {
  HoSoViewModel(this._service);
  final HoSoService _service;

  bool _loading = false;
  String? _error;
  StudentProfile? _profile;
  String? _avatarUrl; // hiển thị ngay sau khi đổi

  bool get isLoading => _loading;
  String? get error => _error;
  StudentProfile? get profile => _profile;
  String? get avatarUrl => _avatarUrl ?? _profile?.avatarUrl;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // ---- Load theo user hiện tại ----
  Future<void> loadForCurrentUser() async {
    _setLoading(true);
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) throw Exception('Chưa đăng nhập.');
      final p = await _service.fetchById(
        id: user.studentId ?? user.id,
        bearerToken: user.token,
      );
      _profile = p;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _profile = null;
    } finally {
      _setLoading(false);
    }
  }

  // ---- Upload CV ----
  Future<String?> pickAndUploadCV(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (res == null || res.files.isEmpty) return null;
    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Thiếu token.');
      final url = await _service.uploadCv(
        bytes: bytes,
        filename: file.name,
        bearerToken: token,
      );
      _profile = (_profile ?? const StudentProfile()).copyWith(cvUrl: url);
      _error = null;
      return url;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---- Upload Avatar ----
  Future<String?> pickAndUploadAvatar(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (res == null || res.files.isEmpty) return null;
    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Thiếu token.');
      final url = await _service.uploadAvatar(
        bytes: bytes,
        filename: file.name,
        bearerToken: token,
      );
      _avatarUrl = url; // cập nhật tạm thời ngay
      _error = null;
      notifyListeners();
      return url;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
