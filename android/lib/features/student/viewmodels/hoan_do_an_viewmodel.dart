import 'dart:io';
import 'package:flutter/material.dart';
import '../models/de_nghi_hoan_model.dart';
import '../services/hoan_do_an_service.dart';

class HoanDoAnViewModel extends ChangeNotifier {
  final HoanDoAnService service;

  HoanDoAnViewModel({required this.service});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

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

  Future<void> guiDeNghiHoan({
    required String lyDo,
    File? minhChungFile,
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    _notify();

    try {
      await service.guiDeNghiHoan(
        lyDo: lyDo,
        minhChungFile: minhChungFile,
      );
      _isSuccess = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }
}
