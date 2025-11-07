import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_item.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_detail.dart';
import 'package:GPMS/features/lecturer/services/hoi_dong_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class HoiDongViewModel extends ChangeNotifier {
  final HoiDongService _service;

  List<HoiDongItem> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;

  // Detail state
  HoiDongDetail? _detail;
  bool _isLoadingDetail = false;
  String? _detailError;
  ErrorCode? _detailErrorCode;

  bool _isDisposed = false;

  HoiDongViewModel({required HoiDongService service}) : _service = service;

  List<HoiDongItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;

  // Detail getters
  HoiDongDetail? get detail => _detail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;
  ErrorCode? get detailErrorCode => _detailErrorCode;
  bool get hasDetailError => _detailError != null;

  List<HoiDongItem> get upcomingCouncils {
    final now = DateTime.now();
    return _items.where((item) {
      if (item.thoiGianBatDau == null) return false;
      return item.thoiGianBatDau!.isAfter(now);
    }).toList();
  }

  List<HoiDongItem> get ongoingCouncils {
    final now = DateTime.now();
    return _items.where((item) {
      if (item.thoiGianBatDau == null || item.thoiGianKetThuc == null) {
        return false;
      }
      return item.thoiGianBatDau!.isBefore(now) &&
          item.thoiGianKetThuc!.isAfter(now);
    }).toList();
  }

  List<HoiDongItem> get completedCouncils {
    final now = DateTime.now();
    return _items.where((item) {
      if (item.thoiGianKetThuc == null) return false;
      return item.thoiGianKetThuc!.isBefore(now);
    }).toList();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> fetchByLecturer({
    required int idGiangVien,
    String? keyword,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetchByLecturer(
        idGiangVien: idGiangVien,
        keyword: keyword,
      );
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];
      if (kDebugMode) print('❌ fetchByLecturer: ${e.errorCode.name}');
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      _items = [];
      if (kDebugMode) print('❌ fetchByLecturer: $e');
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> fetchByTopic({required int idDeTai}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetchByTopic(idDeTai: idDeTai);
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];
      if (kDebugMode) print('❌ fetchByTopic: ${e.errorCode.name}');
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      _items = [];
      if (kDebugMode) print('❌ fetchByTopic: $e');
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> fetchAll({String? keyword}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetchAll(keyword: keyword);
      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];
      if (kDebugMode) print('❌ fetchAll: ${e.errorCode.name}');
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      _items = [];
      if (kDebugMode) print('❌ fetchAll: $e');
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> fetchDetail({required int hoiDongId}) async {
    if (_isLoadingDetail) return;

    _isLoadingDetail = true;
    _detailError = null;
    _detailErrorCode = null;
    _notify();

    try {
      _detail = await _service.fetchDetail(hoiDongId: hoiDongId);
      _detailError = null;
      _detailErrorCode = null;
    } on CustomException catch (e) {
      _detailErrorCode = e.errorCode;
      _detailError = e.errorCode.message;
      _detail = null;
      if (kDebugMode) print('❌ fetchDetail: ${e.errorCode.name}');
    } catch (e) {
      _detailErrorCode = ErrorCode.internalServerError;
      _detailError = 'Lỗi: $e';
      _detail = null;
      if (kDebugMode) print('❌ fetchDetail: $e');
    } finally {
      _isLoadingDetail = false;
      _notify();
    }
  }

  Future<void> retryFetch() => fetchAll();

  Future<void> retryFetchDetail(int hoiDongId) =>
      fetchDetail(hoiDongId: hoiDongId);

  void clearError() {
    _error = null;
    _errorCode = null;
    _notify();
  }

  void clearDetailError() {
    _detailError = null;
    _detailErrorCode = null;
    _notify();
  }

  void reset() {
    _items = [];
    _isLoading = false;
    _error = null;
    _errorCode = null;
    _detail = null;
    _isLoadingDetail = false;
    _detailError = null;
    _detailErrorCode = null;
    _notify();
  }
}
