import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/danh_sach_nhat_ky.dart';
import 'package:GPMS/features/student/services/nhat_ky_service.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class SubmitDiaryViewModel extends ChangeNotifier {
  final NhatKyService _service;

  bool _isSubmitting = false;
  String? _error;
  ErrorCode? _errorCode;
  DiaryItem? _result;
  int _bytesSent = 0;
  int _bytesTotal = 0;

  SubmitDiaryViewModel({required NhatKyService service}) : _service = service;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  ErrorCode? get errorCode => _errorCode;
  DiaryItem? get result => _result;
  int get bytesSent => _bytesSent;
  int get bytesTotal => _bytesTotal;
  double get progress => (_bytesTotal > 0) ? (_bytesSent / _bytesTotal) : 0.0;
  bool get hasError => _error != null;

  Future<bool> submit({
    required int deTaiId,
    required int idNhatKy,
    required String noiDung,
    String? filePath,
  }) async {
    _isSubmitting = true;
    _error = null;
    _errorCode = null;
    _bytesSent = 0;
    _bytesTotal = 0;
    notifyListeners();

    try {
      final res = await _service.submitDiary(
        deTaiId: deTaiId,
        idNhatKy: idNhatKy,
        noiDung: noiDung,
        filePath: filePath,
        onSendProgress: (sent, total) {
          _bytesSent = sent;
          _bytesTotal = total;
          if (_isSubmitting) notifyListeners();
        },
      );

      _result = res;
      return true;
    } on CustomException catch (e) {
      _errorCode = e.errorCode;
      _error = e.errorCode.message;
      return false;
    } catch (e) {
      _errorCode = ErrorCode.internalServerError;
      _error = 'Lỗi: $e';
      return false;
    } finally {
      _isSubmitting = false;
      _bytesSent = 0;
      _bytesTotal = 0;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }
}
