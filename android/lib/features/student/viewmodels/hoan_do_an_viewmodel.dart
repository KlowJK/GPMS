import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/de_nghi_hoan_model.dart';
import 'package:GPMS/features/student/services/hoan_do_an_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// ViewModel cho màn hình Hoãn Đồ Án
///
/// Quản lý:
/// - Danh sách đề nghị hoãn
/// - Gửi đề nghị hoãn mới
/// - Error handling với ErrorCode
class HoanDoAnViewModel extends ChangeNotifier {
  final HoanDoAnService _service;

  // State for list
  List<DeNghiHoanModel> _deNghiList = [];
  bool _isFetchingList = false;
  String? _fetchListError;
  ErrorCode? _fetchListErrorCode;

  // State for submission
  bool _isSubmitting = false;
  String? _submitError;
  ErrorCode? _submitErrorCode;
  bool _isSuccess = false;

  bool _isDisposed = false;

  HoanDoAnViewModel({required HoanDoAnService service}) : _service = service {
    // Auto fetch on init
    fetchDeNghiHoan();
  }

  // Getters - List
  List<DeNghiHoanModel> get deNghiList => _deNghiList;
  bool get isFetchingList => _isFetchingList;
  String? get fetchListError => _fetchListError;
  ErrorCode? get fetchListErrorCode => _fetchListErrorCode;
  bool get hasFetchListError => _fetchListError != null;

  // Getters - Submission
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  ErrorCode? get submitErrorCode => _submitErrorCode;
  bool get hasSubmitError => _submitError != null;
  bool get isSuccess => _isSuccess;

  // Legacy getters for backward compatibility
  bool get isLoading => _isSubmitting;
  String? get error => _submitError;

  /// Latest đề nghị
  DeNghiHoanModel? get latestDeNghi {
    if (_deNghiList.isEmpty) return null;
    return _deNghiList.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
  }

  /// Check if has pending request
  bool get hasPendingRequest {
    final latest = latestDeNghi;
    if (latest == null) return false;
    // Assuming there's a status field in DeNghiHoanModel
    // Adjust based on your model
    return latest.trangThai?.toString() == 'PENDING' ||
        latest.trangThai?.toString() == 'CHO_DUYET';
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Fetch danh sách đề nghị hoãn
  Future<void> fetchDeNghiHoan() async {
    _isFetchingList = true;
    _fetchListError = null;
    _fetchListErrorCode = null;
    _notify();

    try {
      _deNghiList = await _service.getDanhSachDeNghi();
      _fetchListError = null;
      _fetchListErrorCode = null;
    } on CustomException catch (e) {
      _fetchListErrorCode = e.errorCode;
      _fetchListError = e.errorCode.message;
      _deNghiList = [];

      if (kDebugMode) {
        print('❌ fetchDeNghiHoan: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _fetchListErrorCode = ErrorCode.internalServerError;
      _fetchListError = 'Lỗi khi tải danh sách: $e';
      _deNghiList = [];

      if (kDebugMode) {
        print('❌ fetchDeNghiHoan: Unexpected error: $e');
      }
    } finally {
      _isFetchingList = false;
      _notify();
    }
  }

  /// Gửi đề nghị hoãn đồ án
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> guiDeNghiHoan({
    required String lyDo,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    _submitErrorCode = null;
    _isSuccess = false;
    _notify();

    try {
      await _service.guiDeNghiHoan(
        lyDo: lyDo,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      _isSuccess = true;
      _submitError = null;
      _submitErrorCode = null;

      // Refresh list after successful submission
      await fetchDeNghiHoan();

      return true;
    } on CustomException catch (e) {
      _submitErrorCode = e.errorCode;
      _submitError = e.errorCode.message;
      _isSuccess = false;

      if (kDebugMode) {
        print('❌ guiDeNghiHoan: CustomException ${e.errorCode.name}');
      }

      return false;
    } catch (e) {
      _submitErrorCode = ErrorCode.internalServerError;
      _submitError = 'Lỗi khi gửi đề nghị: $e';
      _isSuccess = false;

      if (kDebugMode) {
        print('❌ guiDeNghiHoan: Unexpected error: $e');
      }

      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  /// Retry fetch list
  Future<void> retryFetchList() => fetchDeNghiHoan();

  /// Retry submission (need to call with parameters again)
  void clearSubmitError() {
    _submitError = null;
    _submitErrorCode = null;
    _isSuccess = false;
    _notify();
  }

  /// Clear fetch list error
  void clearFetchListError() {
    _fetchListError = null;
    _fetchListErrorCode = null;
    _notify();
  }

  /// Clear all errors
  void clearAllErrors() {
    clearSubmitError();
    clearFetchListError();
  }

  /// Reset success state
  void resetSuccess() {
    _isSuccess = false;
    _notify();
  }

  /// Reset all state
  void reset() {
    _deNghiList = [];
    _isFetchingList = false;
    _fetchListError = null;
    _fetchListErrorCode = null;
    _isSubmitting = false;
    _submitError = null;
    _submitErrorCode = null;
    _isSuccess = false;
    _notify();
  }
}
