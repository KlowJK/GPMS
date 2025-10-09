import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/de_nghi_hoan_model.dart';
import '../services/hoan_do_an_service.dart';

class HoanDoAnViewModel extends ChangeNotifier {
  final HoanDoAnService service;

  HoanDoAnViewModel({required this.service}) {
    fetchDeNghiHoan(); // Fetch the list on initialization
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  List<DeNghiHoanModel> _deNghiList = [];
  List<DeNghiHoanModel> get deNghiList => _deNghiList;

  bool _isFetchingList = false;
  bool get isFetchingList => _isFetchingList;

  String? _fetchListError;
  String? get fetchListError => _fetchListError;

  bool _isDisposed = false;

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

  Future<void> fetchDeNghiHoan() async {
    _isFetchingList = true;
    _fetchListError = null;
    _notify();

    try {
      _deNghiList = await service.getDanhSachDeNghi();
    } catch (e) {
      _fetchListError = e.toString();
    } finally {
      _isFetchingList = false;
      _notify();
    }
  }

  Future<void> guiDeNghiHoan({
    required String lyDo,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    _notify();

    try {
      await service.guiDeNghiHoan(
        lyDo: lyDo,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _isSuccess = true;
      await fetchDeNghiHoan(); // Refresh the list after successful submission
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }
}
