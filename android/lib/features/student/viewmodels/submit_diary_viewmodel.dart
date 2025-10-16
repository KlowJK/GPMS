// filepath: c:\Users\ASUS\AndroidStudioProjects\GPMS\android\lib\features\student\viewmodels\submit_diary_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/danh_sach_nhat_ky.dart';
import '../services/nhat_ky_service.dart';

class SubmitDiaryViewModel extends ChangeNotifier {
  final NhatKyService service;
  SubmitDiaryViewModel({NhatKyService? service}) : service = service ?? NhatKyService();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  String? _rawError;
  String? get rawError => _rawError;

  DiaryItem? _result;
  DiaryItem? get result => _result;

  int _bytesSent = 0;
  int _bytesTotal = 0;
  int get bytesSent => _bytesSent;
  int get bytesTotal => _bytesTotal;
  double get progress => (_bytesTotal > 0) ? (_bytesSent / _bytesTotal) : 0.0;

  Future<bool> submit({required int deTaiId, required int idNhatKy, required String noiDung, String? filePath}) async {
    _isSubmitting = true;
    _error = null;
    _rawError = null;
    _bytesSent = 0;
    _bytesTotal = 0;
    notifyListeners();

    try {
      final res = await service.submitDiary(
        deTaiId: deTaiId,
        idNhatKy: idNhatKy,
        noiDung: noiDung,
        filePath: filePath,
        onSendProgress: (sent, total) {
          _bytesSent = sent;
          _bytesTotal = total;
          // throttle notifications for performance? keep simple for now
          if (!_isSubmitting) return;
          notifyListeners();
        },
      );

      _result = res;
      return true;
    } catch (e, st) {
      // Normalize error strings — avoid showing just 'null'
      final raw = e?.toString() ?? 'Unknown error';
      String normalized = raw;
      if (normalized.trim().isEmpty || normalized.trim().toLowerCase() == 'null' || normalized.contains('Exception: null')) {
        normalized = 'Không nhận được phản hồi chi tiết từ máy chủ. Vui lòng kiểm tra kết nối hoặc đăng nhập lại.';
      }
      // Append a tiny diagnostic hint
      final timestamp = DateTime.now().toIso8601String();
      _rawError = '[$timestamp] $normalized\nSTACKTRACE:\n${st.toString()}';
      _error = 'Lỗi khi nộp nhật ký: ${normalized.split('\n').first}';
      if (kDebugMode) {
        print('[SubmitDiaryViewModel] submit error (normalized): $_rawError');
      }
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
