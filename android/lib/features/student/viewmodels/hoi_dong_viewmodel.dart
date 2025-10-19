import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/hoi_dong_item.dart';
import 'package:GPMS/features/student/services/hoi_dong_service.dart';
import 'package:GPMS/features/student/services/do_an_service.dart';

class HoiDongViewModel extends ChangeNotifier {
  final HoiDongService service;
  HoiDongViewModel({HoiDongService? service}) : service = service ?? HoiDongService();

  List<HoiDongItem> _items = [];
  List<HoiDongItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchHoiDong({
    String? keyword,
    int? idDeTai,
    int? idGiangVien,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final result = await service.getHoiDongItems(
        keyword: keyword,
        idDeTai: idDeTai,
        idGiangVien: idGiangVien,
        page: page,
        size: size,
        sort: sort,
      );
      _items = result;
    } on Exception catch (e) {
      // show specific message if Dio returned 401 earlier in service
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Lấy đề tài của sinh viên hiện tại (nếu có) rồi gọi API lấy hội đồng theo idDeTai
  Future<void> fetchForCurrentStudent({bool fallbackToAll = false}) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final deTai = await DoAnService.fetchDeTaiChiTiet();
      if (deTai != null) {
        // trực tiếp lấy danh sách hội đồng theo idDeTai
        final items = await service.getHoiDongItems(idDeTai: deTai.id);
        _items = items;
      } else {
        if (fallbackToAll) {
          final items = await service.getHoiDongItems();
          _items = items;
        } else {
          _error = 'Không tìm thấy đề tài cho sinh viên hiện tại.';
        }
      }
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  void clearError() {
    _error = null;
    _safeNotify();
  }
}
