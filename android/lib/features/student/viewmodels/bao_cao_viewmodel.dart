import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/report_item.dart';
import 'package:GPMS/features/student/services/bao_cao_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// ViewModel cho màn hình Báo cáo
///
/// Quản lý:
/// - Danh sách báo cáo
/// - Submit báo cáo với progress tracking
/// - Error handling với ErrorCode
/// - Business logic (canSubmitNew, latestReport, hasTopic)
class BaoCaoViewModel extends ChangeNotifier {
  final BaoCaoService _service;

  bool _loading = false;
  String? _error;
  ErrorCode? _errorCode;
  List<ReportItem> _items = [];
  SubmittedReportRaw? _lastSubmittedRaw;
  int _bytesSent = 0;
  int _bytesTotal = 0;

  BaoCaoViewModel({required BaoCaoService service}) : _service = service;

  // Basic getters
  bool get loading => _loading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  List<ReportItem> get items => _items;
  SubmittedReportRaw? get lastSubmittedRaw => _lastSubmittedRaw;
  int get bytesSent => _bytesSent;
  int get bytesTotal => _bytesTotal;
  double get progress => (_bytesTotal > 0) ? (_bytesSent / _bytesTotal) : 0.0;

  // Helper getters
  bool get hasError => _error != null;
  bool get isUploading => _bytesSent > 0 && _bytesSent < _bytesTotal;

  /// Check if user has topic (đề tài)
  /// Returns true by default, unless we get specific error indicating no topic
  bool get hasTopic {
    // If we got a "no topic" error, return false
    if (_errorCode == ErrorCode.deTaiNotFound) {
      return false;
    }
    // Otherwise assume user has topic (default to true)
    return true;
  }

  /// Get latest report by createdAt
  ReportItem? get latestReport {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  /// Check if user can submit new report
  /// True nếu:
  /// - Chưa có báo cáo nào
  /// - Báo cáo mới nhất bị rejected
  bool get canSubmitNew {
    final latest = latestReport;
    return latest == null || latest.status == ReportStatus.rejected;
  }

  /// Check if has pending report
  bool get hasPendingReport {
    final latest = latestReport;
    if (latest == null) return false;
    return latest.status == ReportStatus.pending;
  }

  /// Fetch danh sách báo cáo
  Future<void> fetchReports() async {
    _loading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      _items = await _service.fetchReports();
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];

      if (kDebugMode) {
        print('❌ BaoCaoViewModel: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      _items = [];

      if (kDebugMode) {
        print('❌ BaoCaoViewModel: Unexpected error: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Submit báo cáo mới
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> submitReport({
    required int version,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _bytesSent = 0;
    _bytesTotal = 0;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final raw = await _service.submitReport(
        version: version,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        onSendProgress: (sent, total) {
          _bytesSent = sent;
          _bytesTotal = total;
          notifyListeners();
        },
      );

      _lastSubmittedRaw = raw;

      // Refresh list sau khi submit thành công
      await fetchReports();

      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;

      if (kDebugMode) {
        print('❌ submitReport: CustomException ${e.errorCode.name}');
      }

      notifyListeners();
      return false;
    } catch (e) {
      _errorCode = ErrorCode.uploadFileFailed;
      _error = 'Lỗi: $e';

      if (kDebugMode) {
        print('❌ submitReport: Unexpected error: $e');
      }

      notifyListeners();
      return false;
    } finally {
      _bytesSent = 0;
      _bytesTotal = 0;
      notifyListeners();
    }
  }

  /// Retry after error
  Future<void> retry() => fetchReports();

  /// Refresh data
  Future<void> refresh() => fetchReports();

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
    _items = [];
    _lastSubmittedRaw = null;
    _bytesSent = 0;
    _bytesTotal = 0;
    notifyListeners();
  }

  /// Get next version number
  int getNextVersion() {
    if (_items.isEmpty) return 1;
    final maxVersion = _items
        .map((e) => e.version)
        .reduce((max, version) => version > max ? version : max);
    return maxVersion + 1;
  }
}
