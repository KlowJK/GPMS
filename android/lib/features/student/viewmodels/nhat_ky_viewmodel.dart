import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/nhat_ki_tuan.dart';
import 'package:GPMS/features/student/models/danh_sach_nhat_ky.dart';
import 'package:GPMS/features/student/services/nhat_ky_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// ViewModel cho danh sách Nhật ký
class NhatKyViewModel extends ChangeNotifier {
  final NhatKyService _service;

  List<TuanItem> _tuans = [];
  List<DiaryItem> _diaries = [];
  bool _loading = false;
  bool _loadingDiaries = false;
  String? _error;
  ErrorCode? _errorCode;
  bool _isDisposed = false;

  NhatKyViewModel({required NhatKyService service}) : _service = service;

  List<TuanItem> get tuans => _tuans;
  List<DiaryItem> get diaries => _diaries;
  bool get loading => _loading;
  bool get loadingDiaries => _loadingDiaries;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;

  bool get noDeTai => _errorCode == ErrorCode.deTaiNotFound;
  bool get hasError => _error != null;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> fetchTuans({bool includeAll = false}) async {
    _loading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _tuans = await _service.getTuans(includeAll: includeAll);
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _tuans = [];
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      _tuans = [];
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> fetchDiaries({bool includeAll = false}) async {
    _loadingDiaries = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _diaries = await _service.getDiaries(includeAll: includeAll);
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _diaries = [];
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      _diaries = [];
    } finally {
      _loadingDiaries = false;
      _notify();
    }
  }

  void clearError() {
    _error = null;
    _errorCode = null;
    _notify();
  }

  Future<void> retry() async {
    await Future.wait([fetchTuans(), fetchDiaries()]);
  }
}
