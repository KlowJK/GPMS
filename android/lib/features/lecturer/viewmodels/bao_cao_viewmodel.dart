// dart
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:GPMS/features/lecturer/models/student_supervised.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';

class BaoCaoViewModel extends ChangeNotifier {
  final BaoCaoService _service;

  List<ReportSubmission> _items = [];
  List<ReportSubmission> get items => List.unmodifiable(_items);

  List<StudentSupervised> _supervisedStudents = [];
  List<StudentSupervised> get supervisedStudents =>
      List.unmodifiable(_supervisedStudents);
  static const String STATUS_CHO_DUYET = 'CHO_DUYET';
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  BaoCaoViewModel({required BaoCaoService service}) : _service = service;

  Future<void> load({String? status}) async {
    _statusFilter = status ?? _statusFilter;
    _setLoading(true);
    _error = null;
    try {
      final list = await _service.fetchList(status: _statusFilter);
      _items = list;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async => load(status: STATUS_CHO_DUYET);

  Future<void> fetchSupervisedStudents() async {
    _setLoading(true);
    _error = null;
    try {
      final list = await _service.fetchSupervisedStudents();
      _supervisedStudents = list;
    } catch (e) {
      _error = e.toString();
      _supervisedStudents = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStudentReports({required String maSinhVien}) async {
    _setLoading(true);
    _error = null;
    try {
      final list = await _service.fetchStudentReports(maSinhVien: maSinhVien);
      _items = list;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approve({
    required int idBaoCao,
    required double diemHuongDan,
    String? nhanXet,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.approveReport(
        idBaoCao: idBaoCao,
        diemHuongDan: diemHuongDan,
        nhanXet: nhanXet,
      );
      await load(status: _statusFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reject({required int idBaoCao, required String nhanXet}) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.rejectReport(idBaoCao: idBaoCao, nhanXet: nhanXet);
      await load(status: _statusFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    load(status: _statusFilter);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
