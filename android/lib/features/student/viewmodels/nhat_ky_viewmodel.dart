import 'package:flutter/material.dart';
import '../models/nhat_ki_tuan.dart';
import '../models/danh_sach_nhat_ky.dart';
import '../services/nhat_ky_service.dart';

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

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void clearError() {
    _error = null;
  }

  Future<void> fetchTuans({bool includeAll = false}) async {
    _loading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();
    try {
      _tuans = await service.getTuans(includeAll: includeAll);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> fetchDiaries({bool includeAll = false}) async {
    _loadingDiaries = true;
    _error = null;
    if (!_isDisposed) notifyListeners();
    try {
      _diaries = await service.getDiaries(includeAll: includeAll);
    } catch (e) {
      _error = e.toString();
    }
    _loadingDiaries = false;
    if (!_isDisposed) notifyListeners();
  }
}
