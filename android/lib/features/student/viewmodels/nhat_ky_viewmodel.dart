import 'package:flutter/material.dart';
import 'package:GPMS/features/student/models/nhat_ki_tuan.dart';
import 'package:GPMS/features/student/models/danh_sach_nhat_ky.dart';
import 'package:GPMS/features/student/services/nhat_ky_service.dart';

class NhatKyViewModel extends ChangeNotifier {
  final NhatKyService service;
  NhatKyViewModel({NhatKyService? service}) : service = service ?? NhatKyService();

  List<TuanItem> _tuans = [];
  List<TuanItem> get tuans => _tuans;

  List<DiaryItem> _diaries = [];
  List<DiaryItem> get diaries => _diaries;

  bool _loading = false;
  bool get loading => _loading;

  bool _loadingDiaries = false;
  bool get loadingDiaries => _loadingDiaries;

  String? _error;
  String? get error => _error;

  // New: flag indicating the student has no topic (đề tài)
  bool _noDeTai = false;
  bool get noDeTai => _noDeTai;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void clearError() {
    _error = null;
    _noDeTai = false;
  }

  bool _detectNoDeTai(Object e) {
    try {
      final s = e.toString().toLowerCase();
      if (s.contains('3005')) return true;
      if (s.contains('de tai') || s.contains('đề tài')) {
        if (s.contains('khong') || s.contains('không') || s.contains('khong ton tai') || s.contains('không tồn tại') || s.contains('not found')) return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> fetchTuans({bool includeAll = false}) async {
    _loading = true;
    _error = null;
    _noDeTai = false;
    if (!_isDisposed) notifyListeners();
    try {
      _tuans = await service.getTuans(includeAll: includeAll);
    } catch (e) {
      if (_detectNoDeTai(e)) {
        _noDeTai = true;
        _error = null;
      } else {
        _error = e.toString();
        _noDeTai = false;
      }
    }
    _loading = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> fetchDiaries({bool includeAll = false}) async {
    _loadingDiaries = true;
    _error = null;
    _noDeTai = false;
    if (!_isDisposed) notifyListeners();
    try {
      _diaries = await service.getDiaries(includeAll: includeAll);
    } catch (e) {
      if (_detectNoDeTai(e)) {
        _noDeTai = true;
        _error = null;
      } else {
        _error = e.toString();
        _noDeTai = false;
      }
    }
    _loadingDiaries = false;
    if (!_isDisposed) notifyListeners();
  }
}
