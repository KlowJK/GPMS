import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/hoi_dong_item.dart';
import 'package:GPMS/features/student/services/hoi_dong_service.dart';
import 'package:GPMS/features/student/services/do_an_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// ViewModel cho màn hình Hội đồng
///
/// Quản lý:
/// - Danh sách hội đồng
/// - Loading states
/// - Error handling với ErrorCode
/// - Pagination support
class HoiDongViewModel extends ChangeNotifier {
  final HoiDongService _hoiDongService;
  final DoAnService _doAnService;

  // State
  List<HoiDongItem> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;
  bool _disposed = false;

  // Pagination
  int _currentPage = 0;
  int _pageSize = 10;
  bool _hasMore = true;

  // Filters
  String? _keyword;
  int? _idDeTai;
  int? _idGiangVien;

  HoiDongViewModel({
    required HoiDongService hoiDongService,
    required DoAnService doAnService,
  }) : _hoiDongService = hoiDongService,
       _doAnService = doAnService;

  // Getters
  List<HoiDongItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  // Filter getters
  String? get keyword => _keyword;
  int? get idDeTai => _idDeTai;
  int? get idGiangVien => _idGiangVien;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Fetch hội đồng với filters
  Future<void> fetchHoiDong({
    String? keyword,
    int? idDeTai,
    int? idGiangVien,
    int page = 0,
    int size = 10,
    List<String>? sort,
    bool append = false,
  }) async {
    if (!append) {
      _isLoading = true;
      _error = null;
      _errorCode = null;
    }
    _safeNotify();

    try {
      final result = await _hoiDongService.fetchHoiDong(
        keyword: keyword,
        idDeTai: idDeTai,
        idGiangVien: idGiangVien,
        page: page,
        size: size,
        sort: sort,
      );

      if (append) {
        _items.addAll(result);
      } else {
        _items = result;
      }

      // Update pagination state
      _currentPage = page;
      _pageSize = size;
      _hasMore = result.length >= size;

      // Save current filters
      _keyword = keyword;
      _idDeTai = idDeTai;
      _idGiangVien = idGiangVien;

      _error = null;
      _errorCode = null;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      if (!append) _items = [];

      if (kDebugMode) {
        print('❌ HoiDongViewModel: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải hội đồng: $e';
      if (!append) _items = [];

      if (kDebugMode) {
        print('❌ HoiDongViewModel: Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Load more items (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    await fetchHoiDong(
      keyword: _keyword,
      idDeTai: _idDeTai,
      idGiangVien: _idGiangVien,
      page: _currentPage + 1,
      size: _pageSize,
      append: true,
    );
  }

  /// Fetch tất cả hội đồng
  Future<void> fetchAll({String? keyword, int page = 0, int size = 10}) {
    return fetchHoiDong(keyword: keyword, page: page, size: size);
  }

  /// Fetch hội đồng theo đề tài
  Future<void> fetchByTopic({
    required int topicId,
    int page = 0,
    int size = 10,
  }) {
    return fetchHoiDong(idDeTai: topicId, page: page, size: size);
  }

  /// Fetch hội đồng theo giảng viên
  Future<void> fetchByLecturer({
    required int lecturerId,
    String? keyword,
    int page = 0,
    int size = 10,
  }) {
    return fetchHoiDong(
      idGiangVien: lecturerId,
      keyword: keyword,
      page: page,
      size: size,
    );
  }

  /// Fetch hội đồng cho sinh viên hiện tại
  ///
  /// Lấy đề tài của sinh viên trước, rồi fetch hội đồng theo đề tài đó
  ///
  /// [fallbackToAll] - Nếu true và không tìm thấy đề tài, sẽ load tất cả hội đồng
  Future<void> fetchForCurrentStudent({bool fallbackToAll = false}) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    _safeNotify();

    try {
      // Get student's topic
      final deTai = await _doAnService.fetchDeTaiChiTiet();

      if (deTai != null && deTai.id > 0) {
        // Fetch hội đồng theo đề tài
        await fetchByTopic(topicId: deTai.id);
      } else {
        if (fallbackToAll) {
          // Fallback: Load all
          await fetchAll();
        } else {
          _error = 'Không tìm thấy đề tài của bạn';
          _errorCode = ErrorCode.deTaiNotFound;
          _items = [];
        }
      }
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      _items = [];

      if (kDebugMode) {
        print('❌ fetchForCurrentStudent: CustomException ${e.errorCode.name}');
      }
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi khi tải hội đồng: $e';
      _items = [];

      if (kDebugMode) {
        print('❌ fetchForCurrentStudent: Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Refresh current view
  Future<void> refresh() async {
    return fetchHoiDong(
      keyword: _keyword,
      idDeTai: _idDeTai,
      idGiangVien: _idGiangVien,
      page: 0,
      size: _pageSize,
    );
  }

  /// Retry after error
  Future<void> retry() async {
    return refresh();
  }

  /// Clear error
  void clearError() {
    _error = null;
    _errorCode = null;
    _safeNotify();
  }

  /// Clear filters và reload
  Future<void> clearFilters() async {
    _keyword = null;
    _idDeTai = null;
    _idGiangVien = null;
    return fetchAll();
  }

  /// Reset all state
  void reset() {
    _items = [];
    _error = null;
    _errorCode = null;
    _isLoading = false;
    _currentPage = 0;
    _hasMore = true;
    _keyword = null;
    _idDeTai = null;
    _idGiangVien = null;
    _safeNotify();
  }

  /// Search với keyword
  Future<void> search(String keyword) async {
    if (keyword.isEmpty) {
      return fetchAll();
    }
    return fetchAll(keyword: keyword);
  }
}
