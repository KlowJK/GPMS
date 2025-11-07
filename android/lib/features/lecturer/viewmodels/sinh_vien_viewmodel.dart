import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/sinh_vien_item.dart';
import 'package:GPMS/features/lecturer/services/sinh_vien_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class SinhVienViewModel extends ChangeNotifier {
  final SinhVienService _service;

  // State
  List<SinhVienItem> _items = [];
  bool _isLoading = false;
  String? _error;
  ErrorCode? _errorCode;

  // Search state
  String _searchQuery = '';

  bool _isDisposed = false;

  SinhVienViewModel(this._service) {
    // Auto load on init
    fetchList();
  }

  // Getters
  List<SinhVienItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  bool get hasError => _error != null;
  String get searchQuery => _searchQuery;

  /// Filtered items based on search query
  List<SinhVienItem> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _items;

    return _items.where((item) {
      final name = (item.hoTen ?? '').toLowerCase();
      final maSV = (item.maSV ?? '').toLowerCase();
      final lop = (item.tenLop ?? '').toLowerCase();
      final deTai = (item.tenDeTai ?? '').toLowerCase();

      return name.contains(query) ||
          maSV.contains(query) ||
          lop.contains(query) ||
          deTai.contains(query);
    }).toList();
  }

  /// Total count
  int get totalCount => _items.length;

  /// Filtered count
  int get filteredCount => filteredItems.length;

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

  /// Fetch danh sách sinh viên
  Future<void> fetchList() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _errorCode = null;
    _notify();

    try {
      _items = await _service.fetch();
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

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _notify();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _notify();
  }

  /// Retry fetch
  Future<void> retry() => fetchList();

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
    _searchQuery = '';
    _notify();
  }

  /// Get sinh viên by maSV
  SinhVienItem? findByMaSV(String maSV) {
    try {
      return _items.firstWhere((item) => item.maSV == maSV);
    } catch (_) {
      return null;
    }
  }

  /// Get sinh viên by index in filtered list
  SinhVienItem? getFilteredItemAt(int index) {
    final filtered = filteredItems;
    if (index < 0 || index >= filtered.length) return null;
    return filtered[index];
  }
}
