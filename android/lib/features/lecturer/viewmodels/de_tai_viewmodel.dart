import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/de_tai_item.dart';
import 'package:GPMS/features/lecturer/services/de_tai_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class DeTaiViewModel extends ChangeNotifier {
  final DeTaiService _service;

  // State
  List<DeTaiItem> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;

  // Processing state (prevent duplicate actions)
  bool _isProcessing = false;

  bool _isDisposed = false;

  DeTaiViewModel(this._service) {
    // Auto load on init
    fetchApprovalList();
  }

  // Getters
  List<DeTaiItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;
  bool get isProcessing => _isProcessing;

  /// Pending items only
  List<DeTaiItem> get pendingItems =>
      _items.where((it) => it.status == TopicStatus.pending).toList();

  /// Approved items
  List<DeTaiItem> get approvedItems =>
      _items.where((it) => it.status == TopicStatus.approved).toList();

  /// Rejected items
  List<DeTaiItem> get rejectedItems =>
      _items.where((it) => it.status == TopicStatus.rejected).toList();

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

  /// Fetch danh sách đề tài chờ duyệt
  Future<void> fetchApprovalList() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetchApprovalList();
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];

      if (kDebugMode) {
        print('❌ fetchApprovalList: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải danh sách: $e';
      _items = [];

      if (kDebugMode) {
        print('❌ fetchApprovalList: Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Duyệt đề tài
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> approveDeTai({
    required int deTaiId,
    required String nhanXet,
  }) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.approve(deTaiId: deTaiId, nhanXet: nhanXet);

      // Refresh list after approval
      await fetchApprovalList();

      _error = null;
      _errorCode = null;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ approveDeTai: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi duyệt đề tài: $e';

      if (kDebugMode) {
        print('❌ approveDeTai: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Từ chối đề tài
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> rejectDeTai({
    required int deTaiId,
    required String nhanXet,
  }) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.reject(deTaiId: deTaiId, nhanXet: nhanXet);

      // Refresh list after rejection
      await fetchApprovalList();

      _error = null;
      _errorCode = null;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ rejectDeTai: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi từ chối đề tài: $e';

      if (kDebugMode) {
        print('❌ rejectDeTai: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Retry fetch
  Future<void> retry() => fetchApprovalList();

  /// Clear error
  void clearError() {
    _error = null;
    _errorCode = null;
    _notify();
  }

  /// Reset all state
  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    _errorCode = null;
    _isProcessing = false;
    _notify();
  }
}
