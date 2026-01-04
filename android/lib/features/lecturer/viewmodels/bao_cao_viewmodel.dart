import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:GPMS/features/lecturer/models/student_supervised.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class BaoCaoViewModel extends ChangeNotifier {
  final BaoCaoService _service;

  // State - Reports list
  List<ReportSubmission> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;

  // State - Supervised students
  List<StudentSupervised> _supervisedStudents = [];
  bool _isLoadingStudents = false;
  String? _studentsError;
  ErrorCode? _studentsErrorCode;

  // State - Student reports
  List<ReportSubmission> _studentReports = [];
  bool _isLoadingReports = false;
  String? _reportsError;
  ErrorCode? _reportsErrorCode;

  // Processing state
  bool _isProcessing = false;
  String? _statusFilter;

  static const String STATUS_CHO_DUYET = 'CHO_DUYET';

  bool _isDisposed = false;

  BaoCaoViewModel({required BaoCaoService service}) : _service = service {
    // Auto load on init
    fetchList(status: STATUS_CHO_DUYET);
    fetchSupervisedStudents();
  }

  // Getters - Reports list
  List<ReportSubmission> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;

  // Getters - Supervised students
  List<StudentSupervised> get supervisedStudents => _supervisedStudents;
  bool get isLoadingStudents => _isLoadingStudents;
  String? get studentsError => _studentsError;
  ErrorCode? get studentsErrorCode => _studentsErrorCode; // ✅ Added getter
  bool get hasStudentsError => _studentsError != null;

  // Getters - Student reports
  List<ReportSubmission> get studentReports => _studentReports;
  bool get isLoadingReports => _isLoadingReports;
  String? get reportsError => _reportsError;
  ErrorCode? get reportsErrorCode => _reportsErrorCode; // ✅ Added getter
  bool get hasReportsError => _reportsError != null;

  // Processing & filter
  bool get isProcessing => _isProcessing;
  String? get statusFilter => _statusFilter;

  /// Pending reports only
  List<ReportSubmission> get pendingReports =>
      _items.where((r) => r.trangThai == 'CHO_DUYET').toList();

  /// Approved reports
  List<ReportSubmission> get approvedReports =>
      _items.where((r) => r.trangThai == 'DA_DUYET').toList();

  /// Rejected reports
  List<ReportSubmission> get rejectedReports =>
      _items.where((r) => r.trangThai == 'TU_CHOI').toList();

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

  /// Fetch danh sách báo cáo
  Future<void> fetchList({String? status}) async {
    if (_isLoading) return;

    _statusFilter = status;
    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetchList(status: status);
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

  /// Fetch danh sách sinh viên được hướng dẫn
  Future<void> fetchSupervisedStudents() async {
    if (_isLoadingStudents) return;

    _isLoadingStudents = true;
    _studentsError = null;
    _studentsErrorCode = null;
    _notify();

    try {
      _supervisedStudents = await _service.fetchSupervisedStudents();
      _studentsError = null;
      _studentsErrorCode = null;
    } on CustomException catch (e) {
      _studentsErrorCode = e.errorCode;
      _studentsError = e.errorCode.message;
      _supervisedStudents = [];

      if (kDebugMode) {
        print('❌ fetchSupervisedStudents: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _studentsErrorCode = ErrorCode.internalServerError;
      _studentsError = 'Lỗi khi tải danh sách sinh viên: $e';
      _supervisedStudents = [];

      if (kDebugMode) {
        print('❌ fetchSupervisedStudents: Unexpected error: $e');
      }
    } finally {
      _isLoadingStudents = false;
      _notify();
    }
  }

  /// Fetch báo cáo của sinh viên
  Future<void> fetchStudentReports({required String maSinhVien}) async {
    if (_isLoadingReports) return;

    _isLoadingReports = true;
    _reportsError = null;
    _reportsErrorCode = null;
    _notify();

    try {
      _studentReports = await _service.fetchStudentReports(
        maSinhVien: maSinhVien,
      );
      _reportsError = null;
      _reportsErrorCode = null;
    } on CustomException catch (e) {
      _reportsErrorCode = e.errorCode;
      _reportsError = e.errorCode.message;
      _studentReports = [];

      if (kDebugMode) {
        print('❌ fetchStudentReports: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _reportsErrorCode = ErrorCode.internalServerError;
      _reportsError = 'Lỗi khi tải báo cáo sinh viên: $e';
      _studentReports = [];

      if (kDebugMode) {
        print('❌ fetchStudentReports: Unexpected error: $e');
      }
    } finally {
      _isLoadingReports = false;
      _notify();
    }
  }

  /// Duyệt báo cáo
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> approve({
    required int idBaoCao,
    required double diemHuongDan,
    String? nhanXet,
  }) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.approveReport(
        idBaoCao: idBaoCao,
        diemHuongDan: diemHuongDan,
        nhanXet: nhanXet,
      );

      // Reload list after approval
      await fetchList(status: _statusFilter);

      _error = null;
      _errorCode = null;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ approve: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi duyệt báo cáo: $e';

      if (kDebugMode) {
        print('❌ approve: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Từ chối báo cáo
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> reject({required int idBaoCao, required String nhanXet}) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      await _service.rejectReport(idBaoCao: idBaoCao, nhanXet: nhanXet);

      // Reload list after rejection
      await fetchList(status: _statusFilter);

      _error = null;
      _errorCode = null;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ reject: CustomException ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi từ chối báo cáo: $e';

      if (kDebugMode) {
        print('❌ reject: Unexpected error: $e');
      }
      return false;
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  /// Retry fetch list
  Future<void> retryList() => fetchList(status: _statusFilter);

  /// Retry fetch students
  Future<void> retryStudents() => fetchSupervisedStudents();

  /// Retry fetch reports
  Future<void> retryReports(String maSinhVien) =>
      fetchStudentReports(maSinhVien: maSinhVien);

  /// Clear list error
  void clearError() {
    _error = null;
    _errorCode = null;
    _notify();
  }

  /// Clear students error
  void clearStudentsError() {
    _studentsError = null;
    _studentsErrorCode = null;
    _notify();
  }

  /// Clear reports error
  void clearReportsError() {
    _reportsError = null;
    _reportsErrorCode = null;
    _notify();
  }

  /// Clear all errors
  void clearAllErrors() {
    clearError();
    clearStudentsError();
    clearReportsError();
  }

  /// Reset all state
  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    _errorCode = null;
    _supervisedStudents = [];
    _isLoadingStudents = false;
    _studentsError = null;
    _studentsErrorCode = null;
    _studentReports = [];
    _isLoadingReports = false;
    _reportsError = null;
    _reportsErrorCode = null;
    _isProcessing = false;
    _statusFilter = null;
    _notify();
  }
}
