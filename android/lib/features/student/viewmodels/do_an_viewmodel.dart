import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/de_cuong.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/de_tai_detail.dart';
import 'package:GPMS/features/student/models/giang_vien_huong_dan.dart';
import 'package:GPMS/features/student/services/do_an_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// ViewModel cho màn hình Đồ án (Student)
///
/// Quản lý:
/// - Đề tài chi tiết
/// - Lịch sử đề cương
/// - Danh sách giảng viên
/// - Đăng ký đề tài
/// - Nộp đề cương
class DoAnViewModel extends ChangeNotifier {
  final DoAnService _service;

  // Đề tài
  DeTaiDetail? _deTaiDetail;
  bool _isLoadingDeTai = false;
  String? _deTaiError;
  ErrorCode? _deTaiErrorCode;

  // Đề cương hiện tại
  DeCuong? _deCuong;

  // Lịch sử nộp đề cương (logs)
  List<DeCuongLog> _deCuongLogs = [];
  bool _isLoadingLogs = false;
  String? _logsError;
  ErrorCode? _logsErrorCode;

  // Giảng viên hướng dẫn
  List<GiangVienHuongDan> _advisors = [];
  bool _isLoadingAdvisors = false;
  String? _advisorError;
  ErrorCode? _advisorErrorCode;

  // Getters
  DeTaiDetail? get deTaiDetail => _deTaiDetail;
  bool get isLoadingDeTai => _isLoadingDeTai;
  String? get deTaiError => _deTaiError;
  ErrorCode? get deTaiErrorCode => _deTaiErrorCode;

  DeCuong? get deCuong => _deCuong;

  List<DeCuongLog> get deCuongLogs => _deCuongLogs;
  bool get isLoadingLogs => _isLoadingLogs;
  String? get logsError => _logsError;
  ErrorCode? get logsErrorCode => _logsErrorCode;

  List<GiangVienHuongDan> get advisors => _advisors;
  bool get isLoadingAdvisors => _isLoadingAdvisors;
  String? get advisorError => _advisorError;
  ErrorCode? get advisorErrorCode => _advisorErrorCode;

  /// Constructor với dependency injection
  DoAnViewModel(this._service);

  /// Fetch đề tài chi tiết
  Future<void> fetchDeTaiChiTiet() async {
    _isLoadingDeTai = true;
    _deTaiError = null;
    _deTaiErrorCode = null;
    notifyListeners();

    try {
      _deTaiDetail = await _service.fetchDeTaiChiTiet();
      _deTaiError = null;
      _deTaiErrorCode = null;
    } on CustomException catch (e) {
      _deTaiErrorCode = e.errorCode;
      _deTaiError = e.errorCode.message;
      if (kDebugMode) {
        print('❌ fetchDeTaiChiTiet CustomException: ${e.errorCode.name}');
      }
    } catch (e) {
      _deTaiErrorCode = ErrorCode.internalServerError;
      _deTaiError = 'Đã xảy ra lỗi khi tải đề tài: $e';
      if (kDebugMode) {
        print('❌ fetchDeTaiChiTiet error: $e');
      }
    } finally {
      _isLoadingDeTai = false;
      notifyListeners();
    }
  }

  /// Alias for fetchDeTaiChiTiet
  Future<void> fetchDeTaiDetail() => fetchDeTaiChiTiet();

  /// Fetch lịch sử đề cương
  Future<void> fetchDeCuongLogs() async {
    _isLoadingLogs = true;
    _logsError = null;
    _logsErrorCode = null;
    notifyListeners();

    try {
      _deCuongLogs = await _service.fetchDeCuongLogs();
      _logsError = null;
      _logsErrorCode = null;
    } on CustomException catch (e) {
      _logsErrorCode = e.errorCode;
      _logsError = e.errorCode.message;
      _deCuongLogs = [];
      if (kDebugMode) {
        print('❌ fetchDeCuongLogs CustomException: ${e.errorCode.name}');
      }
    } catch (e) {
      _logsErrorCode = ErrorCode.internalServerError;
      _logsError = 'Không thể tải lịch sử đề cương: $e';
      _deCuongLogs = [];
      if (kDebugMode) {
        print('❌ fetchDeCuongLogs error: $e');
      }
    } finally {
      _isLoadingLogs = false;
      notifyListeners();
    }
  }

  /// Fetch giảng viên hướng dẫn
  Future<void> fetchAdvisors() async {
    _isLoadingAdvisors = true;
    _advisorError = null;
    _advisorErrorCode = null;
    notifyListeners();

    try {
      _advisors = await _service.fetchAdvisors();
      _advisorError = null;
      _advisorErrorCode = null;
    } on CustomException catch (e) {
      _advisorErrorCode = e.errorCode;
      _advisorError = e.errorCode.message;
      _advisors = [];
      if (kDebugMode) {
        print('❌ fetchAdvisors CustomException: ${e.errorCode.name}');
      }
    } catch (e) {
      _advisorErrorCode = ErrorCode.internalServerError;
      _advisorError = 'Không thể tải danh sách giảng viên: $e';
      _advisors = [];
      if (kDebugMode) {
        print('❌ fetchAdvisors error: $e');
      }
    } finally {
      _isLoadingAdvisors = false;
      notifyListeners();
    }
  }

  /// Đăng ký đề tài
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> dangKyDeTai({
    required int gvhdId,
    required String tenDeTai,
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _isLoadingDeTai = true;
    _deTaiError = null;
    _deTaiErrorCode = null;
    notifyListeners();

    try {
      final result = await _service.postDangKyDeTai(
        gvhdId: gvhdId,
        tenDeTai: tenDeTai,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      if (result != null) {
        _deTaiDetail = result;
        _deTaiError = null;
        _deTaiErrorCode = null;
        return true;
      } else {
        _deTaiError = 'Đăng ký đề tài thất bại';
        _deTaiErrorCode = ErrorCode.internalServerError;
        return false;
      }
    } on CustomException catch (e) {
      _deTaiErrorCode = e.errorCode;
      _deTaiError = e.errorCode.message;
      if (kDebugMode) {
        print('❌ dangKyDeTai CustomException: ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _deTaiErrorCode = ErrorCode.uploadFileFailed;
      _deTaiError = 'Đăng ký đề tài thất bại: $e';
      if (kDebugMode) {
        print('❌ dangKyDeTai error: $e');
      }
      return false;
    } finally {
      _isLoadingDeTai = false;
      notifyListeners();
    }
  }

  /// Nộp đề cương
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> nopDeCuong({required String fileUrl}) async {
    _isLoadingLogs = true;
    _logsError = null;
    _logsErrorCode = null;
    notifyListeners();

    try {
      final result = await _service.nopDeCuong(fileUrl: fileUrl);

      if (result != null) {
        _deCuong = result;
        _logsError = null;
        _logsErrorCode = null;

        // Refresh logs sau khi nộp thành công
        await fetchDeCuongLogs();
        return true;
      } else {
        _logsError = 'Nộp đề cương thất bại';
        _logsErrorCode = ErrorCode.internalServerError;
        return false;
      }
    } on CustomException catch (e) {
      _logsErrorCode = e.errorCode;
      _logsError = e.errorCode.message;
      if (kDebugMode) {
        print('❌ nopDeCuong CustomException: ${e.errorCode.name}');
      }
      return false;
    } catch (e) {
      _logsErrorCode = ErrorCode.internalServerError;
      _logsError = 'Nộp đề cương thất bại: $e';
      if (kDebugMode) {
        print('❌ nopDeCuong error: $e');
      }
      return false;
    } finally {
      _isLoadingLogs = false;
      notifyListeners();
    }
  }

  /// Retry tải đề tài
  Future<void> retryDeTai() => fetchDeTaiChiTiet();

  /// Retry tải logs
  Future<void> retryLogs() => fetchDeCuongLogs();

  /// Retry tải advisors
  Future<void> retryAdvisors() => fetchAdvisors();

  /// Clear errors
  void clearDeTaiError() {
    _deTaiError = null;
    _deTaiErrorCode = null;
    notifyListeners();
  }

  void clearLogsError() {
    _logsError = null;
    _logsErrorCode = null;
    notifyListeners();
  }

  void clearAdvisorError() {
    _advisorError = null;
    _advisorErrorCode = null;
    notifyListeners();
  }

  /// Reset tất cả state
  void reset() {
    _deTaiDetail = null;
    _deTaiError = null;
    _deTaiErrorCode = null;
    _isLoadingDeTai = false;

    _deCuong = null;
    _deCuongLogs = [];
    _logsError = null;
    _logsErrorCode = null;
    _isLoadingLogs = false;

    _advisors = [];
    _advisorError = null;
    _advisorErrorCode = null;
    _isLoadingAdvisors = false;

    notifyListeners();
  }
}
