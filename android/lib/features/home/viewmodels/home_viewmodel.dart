import 'package:flutter/foundation.dart';
import 'package:GPMS/features/home/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:GPMS/features/home/services/home_service.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _mainService;
  final AuthViewModel _authViewModel; // ← Thêm tham chiếu Auth

  // State
  List<ThongBaoVaTinTuc>? _notifications;
  List<DeTai>? _topics;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Constructor
  HomeViewModel(this._mainService, this._authViewModel);

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
      final results = await Future.wait([
        _loadNotifications(), // ← Tự động chọn API
        _mainService.listDeTai(),
      ]);

      _notifications = results[0] as List<ThongBaoVaTinTuc>;
      _topics = results[1] as List<DeTai>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu: $e';
      if (kDebugMode) print('Error loading initial data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới dữ liệu
  Future<void> refreshData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _loadNotifications(), // ← Tự động chọn API
        _mainService.listDeTai(),
      ]);

      _notifications = results[0] as List<ThongBaoVaTinTuc>;
      _topics = results[1] as List<DeTai>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể làm mới dữ liệu';
      if (kDebugMode) print('Error refreshing data: $e');
      rethrow;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Tải thông báo theo trạng thái đăng nhập
  Future<List<ThongBaoVaTinTuc>> _loadNotifications() async {
    if (_authViewModel.isLoggedIn) {
      return await _mainService.listThongBaoByUser(); // ← Có token
    } else {
      return await _mainService.listThongBao(); // ← Public, không token
    }
  }

  /// Retry
  Future<void> retry() async => await loadInitialData();

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _notifications = null;
    _topics = null;
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    notifyListeners();
  }
}
