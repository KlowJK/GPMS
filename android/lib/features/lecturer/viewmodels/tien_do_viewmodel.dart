import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/models/tuan.dart';
import 'package:GPMS/features/lecturer/services/tien_do_service.dart';

class TienDoViewModel extends ChangeNotifier {
  final TienDoService service;
  TienDoViewModel({TienDoService? service})
    : service = service ?? TienDoService();

  // Data
  List<TienDoSinhVien> _items = [];
  List<Tuan> _tuans = [];

  // Filters / state
  int? selectedTuan;
  String? statusFilter;

  // Flags
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  // Getters
  List<TienDoSinhVien> get items => List.unmodifiable(_items);
  List<Tuan> get tuans => List.unmodifiable(_tuans);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  // -------------------- Actions --------------------

  /// Tuần theo giảng viên
  Future<void> loadTuans({bool includeAll = false}) async {
    _setLoading(true);
    try {
      final res = await service.fetchTuansByLecturer(); // <-- pass includeAll
      _tuans = res;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _tuans = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<TienDoSinhVien>> fetchNhatKyByIdList(int id) async {
    _setLoading(true);
    try {
      final res = await service.fetchNhatKyByIdList(id: id);
      _error = null;

      if (res.isNotEmpty) {
        for (final item in res) {
          final idx = _items.indexWhere((e) => e.id == item.id);
          if (idx != -1) {
            _items[idx] = item;
          } else {
            _items.insert(0, item);
          }
        }
        notifyListeners();
      }

      return res;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Tất cả nhật ký (theo tuần)
  Future<void> loadAll({Tuan? tuan}) async {
    _setLoading(true);
    try {
      final tuanNum = tuan?.tuan;
      final res = await service.fetchAllNhatKy(tuan: tuanNum);
      _items = res;
      selectedTuan = tuanNum;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Nhật ký SV do GVHD phụ trách (lọc theo trạng thái)
  Future<void> loadMySupervised({String? status}) async {
    _setLoading(true);
    try {
      final res = await service.fetchMySupervisedStudents(status: status);
      _items = res;
      statusFilter = status;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh: nếu không truyền tham số, dùng filter hiện có
  Future<void> refresh({
    int? tuan,
    String? status,
    bool supervised = false,
  }) async {
    _setRefreshing(true);
    try {
      if (supervised) {
        final res = await service.fetchMySupervisedStudents(
          status: status ?? statusFilter,
        );
        _items = res;
        statusFilter = status ?? statusFilter;
      } else {
        final res = await service.fetchAllNhatKy(tuan: tuan ?? selectedTuan);
        _items = res;
        selectedTuan = tuan ?? selectedTuan;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _setRefreshing(false);
    }
  }

  /// Duyệt một nhật ký (optimistic update)
  static const String STATUS_DA_DUYET =
      'HOAN_THANH'; // chỉnh cho khớp BE nếu khác
  Future<void> approveReport(int id, String nhanXet) async {
    _setLoading(true);
    try {
      await service.approveReport(id: id, nhanXet: nhanXet);

      final idx = _items.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(
          nhanXet: nhanXet,
          trangThaiNhatKy: STATUS_DA_DUYET,
        );
      }
      _error = null;
      // Nếu muốn chắc ăn, có thể gọi lại load theo filter hiện tại:
      // await refresh(tuan: selectedTuan, status: statusFilter, supervised: true/false);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // -------------------- Helpers --------------------
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setRefreshing(bool v) {
    _isRefreshing = v;
    notifyListeners();
  }

  void clear() {
    _items = [];
    _tuans = [];
    selectedTuan = null;
    statusFilter = null;
    _error = null;
    _isLoading = false;
    _isRefreshing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
