import 'package:flutter/material.dart';
import 'package:GPMS/features/student/models/report_item.dart';
import 'package:GPMS/features/student/services/bao_cao_service.dart';

class BaoCaoViewModel extends ChangeNotifier {
  final BaoCaoService service;
  BaoCaoViewModel({required this.service});

  List<ReportItem> _items = [];
  List<ReportItem> get items => _items;
  bool _loading = false;
  bool get loading => _loading;
  String? _error;
  String? get error => _error;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchReports() async {
    _loading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();
    try {
      _items = await service.getReports();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> submitReport(ReportItem item) async {
    _loading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();
    try {
      final newItem = await service.submitReport(item);
      _items.insert(0, newItem);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    if (!_isDisposed) notifyListeners();
  }
}
