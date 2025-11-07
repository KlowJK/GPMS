import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';
import 'package:GPMS/features/lecturer/services/de_cuong_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class DeCuongViewModel extends ChangeNotifier {
  final DeCuongService _service;

  // State - List
  List<DeCuongItem> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;

  // State - Student logs
  List<DeCuongItem> _studentLogs = [];
  bool _isLoadingLogs = false;
  String? _logsError;
  ErrorCode? _logsErrorCode;

  // Processing state
  bool _isProcessing = false;

  bool _isDisposed = false;

  DeCuongViewModel(this._service) {
    // Auto load on init
    fetchList();
  }

  // Getters - List
  List<DeCuongItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;
  bool get isProcessing => _isProcessing;

  // Getters - Student logs
  List<DeCuongItem> get studentLogs => _studentLogs;
  bool get isLoadingLogs => _isLoadingLogs;
  String? get logsError => _logsError;
  ErrorCode? get logsErrorCode => _logsErrorCode;
  bool get hasLogsError => _logsError != null;

  /// Pending items only
  List<DeCuongItem> get pendingItems =>
      _items.where((it) => it.status == DeCuongStatus.pending).toList();

  /// Approved items
  List<DeCuongItem> get approvedItems =>
      _items.where((it) => it.status == DeCuongStatus.approved).toList();

  /// Rejected items
  List<DeCuongItem> get rejectedItems =>
      _items.where((it) => it.status == DeCuongStatus.rejected).toList();

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

  /// Fetch danh sách đề cương chờ duyệt
  Future<void> fetchList() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.list();
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];

      if (kDebugMode) {
        print('❌ fetchList: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải danh sách: $e';
      _items = [];

      if (kDebugMode) {
        print('❌ fetchList: Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Fetch lịch sử đề cương của sinh viên
  Future<void> fetchStudentLogs(String sinhVienId) async {
    if (_isLoadingLogs) return;

    _isLoadingLogs = true;
    _logsError = null;
    _logsErrorCode = null;
    _notify();

    try {
      _studentLogs = await _service.fetchLogBySinhVien(sinhVienId);
      _logsError = null;
      _logsErrorCode = null;
    } on CustomException catch (e) {
      _logsErrorCode = e.errorCode;
      _logsError = e.errorCode.message;
      _studentLogs = [];

      if (kDebugMode) {
        print('❌ fetchStudentLogs: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _logsErrorCode = ErrorCode.internalServerError;
      _logsError = 'Lỗi khi tải lịch sử: $e';
      _studentLogs = [];

      if (kDebugMode) {
        print('❌ fetchStudentLogs: Unexpected error: $e');
      }
    } finally {
      _isLoadingLogs = false;
      _notify();
    }
  }

  /// Duyệt đề cương
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> approveDeCuong({
    required int id,
    required String nhanXet,
  }) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.approve(id: id, nhanXet: nhanXet);

      // Refresh list after approval
      await fetchList();

      _error = null;
      _errorCode = null;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ approveDeCuong: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi duyệt đề cương: $e';

      if (kDebugMode) {
        print('❌ approveDeCuong: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Từ chối đề cương
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> rejectDeCuong({required int id, required String nhanXet}) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.reject(id: id, nhanXet: nhanXet);

      // Refresh list after rejection
      await fetchList();

      _error = null;
      _errorCode = null;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ rejectDeCuong: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi từ chối đề cương: $e';

      if (kDebugMode) {
        print('❌ rejectDeCuong: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Retry fetch list
  Future<void> retryList() => fetchList();

  /// Retry fetch logs
  Future<void> retryLogs(String sinhVienId) => fetchStudentLogs(sinhVienId);

  /// Clear list error
  void clearError() {
    _error = null;
    _errorCode = null;
    _notify();
  }

  /// Clear logs error
  void clearLogsError() {
    _logsError = null;
    _logsErrorCode = null;
    _notify();
  }

  /// Clear all errors
  void clearAllErrors() {
    clearError();
    clearLogsError();
  }

  /// Reset all state
  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    _errorCode = null;
    _studentLogs = [];
    _isLoadingLogs = false;
    _logsError = null;
    _logsErrorCode = null;
    _isProcessing = false;
    _notify();
  }
}
