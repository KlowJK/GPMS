import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/models/tuan.dart';
import 'package:GPMS/features/lecturer/services/tien_do_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class TienDoViewModel extends ChangeNotifier {
  final TienDoService _service;

  // State - Nhật ký items
  List<TienDoSinhVien> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;

  // State - Tuần
  List<Tuan> _tuans = [];
  bool _isLoadingTuans = false;
  String? _tuansError;
  ErrorCode? _tuansErrorCode;

  // State - Supervised students
  List<TienDoSinhVien> _supervisedStudents = [];
  bool _isLoadingSupervised = false;
  String? _supervisedError;
  ErrorCode? _supervisedErrorCode;

  // Processing state
  bool _isProcessing = false;

  // Filters
  int? _selectedTuan;
  String? _statusFilter;

  static const String STATUS_DA_DUYET = 'HOAN_THANH';

  bool _isDisposed = false;

  TienDoViewModel({required TienDoService service}) : _service = service {
    // Auto load tuans on init
    fetchTuans();
  }

  // Getters - Items
  List<TienDoSinhVien> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;

  // Getters - Tuans
  List<Tuan> get tuans => _tuans;
  bool get isLoadingTuans => _isLoadingTuans;
  String? get tuansError => _tuansError;
  ErrorCode? get tuansErrorCode => _tuansErrorCode;
  bool get hasTuansError => _tuansError != null;

  // Getters - Supervised students
  List<TienDoSinhVien> get supervisedStudents => _supervisedStudents;
  bool get isLoadingSupervised => _isLoadingSupervised;
  String? get supervisedError => _supervisedError;
  ErrorCode? get supervisedErrorCode => _supervisedErrorCode;
  bool get hasSupervisedError => _supervisedError != null;

  // Processing & filters
  bool get isProcessing => _isProcessing;
  int? get selectedTuan => _selectedTuan;
  String? get statusFilter => _statusFilter;

  /// Pending items only
  List<TienDoSinhVien> get pendingItems =>
      _items.where((item) => item.trangThaiNhatKy != STATUS_DA_DUYET).toList();

  /// Approved items
  List<TienDoSinhVien> get approvedItems =>
      _items.where((item) => item.trangThaiNhatKy == STATUS_DA_DUYET).toList();

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

  /// Fetch danh sách tuần
  Future<void> fetchTuans({bool includeAll = false}) async {
    if (_isLoadingTuans) return;

    _isLoadingTuans = true;
    _tuansError = null;
    _tuansErrorCode = null;
    _notify();

    try {
      _tuans = await _service.fetchTuansByLecturer(includeAll: includeAll);
      _tuansError = null;
      _tuansErrorCode = null;
    } on CustomException catch (e) {
      _tuansErrorCode = e.errorCode;
      _tuansError = e.errorCode.message;
      _tuans = [];

      if (kDebugMode) {
        print('❌ fetchTuans: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _tuansErrorCode = ErrorCode.internalServerError;
      _tuansError = 'Lỗi khi tải danh sách tuần: $e';
      _tuans = [];

      if (kDebugMode) {
        print('❌ fetchTuans: Unexpected error: $e');
      }
    } finally {
      _isLoadingTuans = false;
      _notify();
    }
  }

  /// Fetch tất cả nhật ký (theo tuần)
  Future<void> fetchAllNhatKy({Tuan? tuan}) async {
    if (_isLoading) return;

    _selectedTuan = tuan?.tuan;
    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetchAllNhatKy(tuan: tuan?.tuan);
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];

      if (kDebugMode) {
        print('❌ fetchAllNhatKy: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải nhật ký: $e';
      _items = [];

      if (kDebugMode) {
        print('❌ fetchAllNhatKy: Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Fetch nhật ký by ID
  Future<List<TienDoSinhVien>> fetchNhatKyById(int id) async {
    if (_isLoading) return [];

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      final result = await _service.fetchNhatKyByIdList(id: id);

      // Update existing items
      if (result.isNotEmpty) {
        for (final item in result) {
          final idx = _items.indexWhere((e) => e.id == item.id);
          if (idx != -1) {
            _items[idx] = item;
          } else {
            _items.insert(0, item);
          }
        }
      }

      _error = null;
      _errorCode = null;
      _notify();
      return result;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ fetchNhatKyById: CustomException ${e.errorCode.name}');
      }
      return [];
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải nhật ký: $e';

      if (kDebugMode) {
        print('❌ fetchNhatKyById: Unexpected error: $e');
      }
      return [];
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  /// Fetch sinh viên được hướng dẫn
  Future<void> fetchMySupervisedStudents({String? status}) async {
    if (_isLoadingSupervised) return;

    _statusFilter = status;
    _isLoadingSupervised = true;
    _supervisedError = null;
    _supervisedErrorCode = null;
    _notify();

    try {
      _supervisedStudents = await _service.fetchMySupervisedStudents(
        status: status,
      );

      // Also update main items
      _items = _supervisedStudents;

      _supervisedError = null;
      _supervisedErrorCode = null;
    } on CustomException catch (e) {
      _supervisedErrorCode = e.errorCode;
      _supervisedError = e.errorCode.message;
      _supervisedStudents = [];

      if (kDebugMode) {
        print(
          '❌ fetchMySupervisedStudents: CustomException ${e.errorCode.name}',
        );
      }
    } catch (e) {
      _supervisedErrorCode = ErrorCode.internalServerError;
      _supervisedError = 'Lỗi khi tải sinh viên: $e';
      _supervisedStudents = [];

      if (kDebugMode) {
        print('❌ fetchMySupervisedStudents: Unexpected error: $e');
      }
    } finally {
      _isLoadingSupervised = false;
      _notify();
    }
  }

  /// Duyệt nhật ký
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> approveReport({required int id, required String nhanXet}) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.approveReport(id: id, nhanXet: nhanXet);

      // Optimistic update
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(
          nhanXet: nhanXet,
          trangThaiNhatKy: STATUS_DA_DUYET,
        );
      }

      _error = null;
      _errorCode = null;
      _notify();
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ approveReport: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi duyệt nhật ký: $e';

      if (kDebugMode) {
        print('❌ approveReport: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Refresh current view
  Future<void> refresh({
    int? tuan,
    String? status,
    bool supervised = false,
  }) async {
    if (supervised) {
      await fetchMySupervisedStudents(status: status ?? _statusFilter);
    } else {
      final selectedTuanObj = tuan != null
          ? _tuans.firstWhere((t) => t.tuan == tuan, orElse: () => _tuans.first)
          : null;
      await fetchAllNhatKy(tuan: selectedTuanObj);
    }
  }

  /// Retry methods
  Future<void> retryFetchItems() => fetchAllNhatKy();
  Future<void> retryFetchTuans() => fetchTuans();
  Future<void> retryFetchSupervised() => fetchMySupervisedStudents();

  /// Clear errors
  void clearError() {
    _error = null;
    _errorCode = null;
    _notify();
  }

  void clearTuansError() {
    _tuansError = null;
    _tuansErrorCode = null;
    _notify();
  }

  void clearSupervisedError() {
    _supervisedError = null;
    _supervisedErrorCode = null;
    _notify();
  }

  void clearAllErrors() {
    clearError();
    clearTuansError();
    clearSupervisedError();
  }

  /// Reset all state
  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    _errorCode = null;
    _tuans = [];
    _isLoadingTuans = false;
    _tuansError = null;
    _tuansErrorCode = null;
    _supervisedStudents = [];
    _isLoadingSupervised = false;
    _supervisedError = null;
    _supervisedErrorCode = null;
    _isProcessing = false;
    _selectedTuan = null;
    _statusFilter = null;
    _notify();
  }
}
