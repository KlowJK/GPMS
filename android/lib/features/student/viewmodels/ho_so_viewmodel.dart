import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/student/models/student_profile.dart';
import 'package:GPMS/features/student/services/ho_so_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// ViewModel cho màn hình Hồ sơ sinh viên
///
/// Quản lý:
/// - Load profile
/// - Upload avatar
/// - Upload CV
/// - Error handling với ErrorCode
class HoSoViewModel extends ChangeNotifier {
  final HoSoService _service;
  final int? _currentUserId;

  bool _loading = false;
  String? _error;
  ErrorCode? _errorCode;
  StudentProfile? _profile;
  String? _avatarUrl; // Temporary avatar URL after upload

  HoSoViewModel({required HoSoService service, int? currentUserId})
    : _service = service,
      _currentUserId = currentUserId;

  // Getters
  bool get isLoading => _loading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  StudentProfile? get profile => _profile;
  bool get hasError => _error != null;

  /// Avatar URL prioritizes temporary uploaded URL, then profile URL
  String? get avatarUrl => _avatarUrl ?? _profile?.avatarUrl;

  /// CV URL from profile
  String? get cvUrl => _profile?.cvUrl;

  /// Check if has profile
  bool get hasProfile => _profile != null;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Load profile for current user
  Future<void> loadProfile() async {
    if (_currentUserId == null) {
      _error = 'User ID không xác định';
      _errorCode = ErrorCode.userNotFound;
      notifyListeners();
      return;
    }

    await loadProfileById(_currentUserId!);
  }

  /// Load profile by ID
  Future<void> loadProfileById(int id) async {
    _setLoading(true);
    _error = null;
    _errorCode = null;

    try {
      _profile = await _service.fetchById(id: id);
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _profile = null;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải hồ sơ: $e';
      _profile = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Pick and upload CV
  Future<String?> pickAndUploadCV(BuildContext context) async {
    // Pick file
    final pickedFile = await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (pickedFile == null) return null;

    // Upload
    _setLoading(true);
    _error = null;
    _errorCode = null;

    try {
      final url = await _service.uploadCv(
        bytes: pickedFile.bytes,
        filename: pickedFile.name,
      );

      // Update profile with new CV URL
      if (_profile != null) {
        _profile = _profile!.copyWith(cvUrl: url);
      }

      _error = null;
      _errorCode = null;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tải CV lên thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return url;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (context.mounted) {
        _showErrorSnackBar(context, e.errorCode.message);
      }

      return null;
    } catch (e) {
      _errorCode = ErrorCode.uploadFileFailed;
      _error = 'Lỗi khi tải CV: $e';

      if (context.mounted) {
        _showErrorSnackBar(context, 'Không thể tải CV lên');
      }

      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Pick and upload avatar
  Future<String?> pickAndUploadAvatar(BuildContext context) async {
    // Pick file
    final pickedFile = await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (pickedFile == null) return null;

    // Upload
    _setLoading(true);
    _error = null;
    _errorCode = null;

    try {
      final url = await _service.uploadAvatar(
        bytes: pickedFile.bytes,
        filename: pickedFile.name,
      );

      // Update temporary avatar URL (shows immediately)
      _avatarUrl = url;
      _error = null;
      _errorCode = null;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return url;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (context.mounted) {
        _showErrorSnackBar(context, e.errorCode.message);
      }

      return null;
    } catch (e) {
      _errorCode = ErrorCode.uploadFileFailed;
      _error = 'Lỗi khi tải ảnh: $e';

      if (context.mounted) {
        _showErrorSnackBar(context, 'Không thể tải ảnh lên');
      }

      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Helper: Pick file
  Future<_PickedFile?> _pickFile({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        _error = 'Không thể đọc file';
        _errorCode = ErrorCode.fileEmpty;
        notifyListeners();
        return null;
      }

      return _PickedFile(bytes: bytes, name: file.name);
    } catch (e) {
      _error = 'Lỗi khi chọn file: $e';
      _errorCode = ErrorCode.internalServerError;
      notifyListeners();
      return null;
    }
  }

  /// Helper: Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Retry load profile
  Future<void> retry() => loadProfile();

  /// Clear error
  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _loading = false;
    _error = null;
    _errorCode = null;
    _profile = null;
    _avatarUrl = null;
    notifyListeners();
  }
}

/// Helper class for picked file
class _PickedFile {
  final Uint8List bytes;
  final String name;

  _PickedFile({required this.bytes, required this.name});
}
