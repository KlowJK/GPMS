import 'package:flutter/foundation.dart';
import 'package:GPMS/features/home/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:GPMS/features/home/services/home_service.dart';

/// ViewModel cho màn hình Home (Guest)
///
/// Quản lý state và business logic cho trang chủ guest
/// Sử dụng ChangeNotifier để notify UI khi có thay đổi
class HomeViewModel extends ChangeNotifier {
  final MainService _mainService;

  // State
  List<ThongBaoVaTinTuc>? _notifications;
  List<DeTai>? _topics;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Constructor with dependency injection
  HomeViewModel(this._mainService);

  // Getters
  List<ThongBaoVaTinTuc>? get notifications => _notifications;
  List<DeTai>? get topics => _topics;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasData => _notifications != null && _topics != null;
  bool get hasError => _errorMessage != null;

  /// Load dữ liệu lần đầu
  Future<void> loadInitialData() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load song song cả 2 API
      final results = await Future.wait([
        _mainService.listThongBao(),
        _mainService.listDeTai(),
      ]);

      _notifications = results[0] as List<ThongBaoVaTinTuc>;
      _topics = results[1] as List<DeTai>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới dữ liệu (pull to refresh)
  Future<void> refreshData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load song song cả 2 API
      final results = await Future.wait([
        _mainService.listThongBao(),
        _mainService.listDeTai(),
      ]);

      _notifications = results[0] as List<ThongBaoVaTinTuc>;
      _topics = results[1] as List<DeTai>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể làm mới dữ liệu';
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
      rethrow; // Để UI có thể handle (show SnackBar)
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Retry khi có lỗi
  Future<void> retry() async {
    await loadInitialData();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state (useful for testing or logout)
  void reset() {
    _notifications = null;
    _topics = null;
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    notifyListeners();
  }
}
