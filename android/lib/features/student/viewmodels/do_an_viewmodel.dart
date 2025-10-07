import '../models/de_tai_detail.dart';
import '../models/giang_vien_huong_dan.dart';
import '../services/do_an_service.dart';
import 'package:flutter/foundation.dart';
class DoAnViewModel extends ChangeNotifier {
  DeTaiDetail? deTaiDetail;
  bool isLoading = true;
  String? error;

  List<GiangVienHuongDan> advisors = [];
  bool isLoadingAdvisors = false;
  String? advisorError;

  DoAnViewModel() {
    fetchDeTaiChiTiet();
  }

  Future<void> fetchDeTaiChiTiet() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await DoAnService.fetchDeTaiChiTiet();
      deTaiDetail = result;
      if (result == null) {
        error = 'Bạn chưa đăng ký đề tài.';
      }
    } catch (e) {
      error = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdvisors() async {
    isLoadingAdvisors = true;
    advisorError = null;
    notifyListeners();
    try {
      advisors = await DoAnService.fetchAdvisors();
    } catch (e) {
      advisorError = e.toString();
    } finally {
      isLoadingAdvisors = false;
      notifyListeners();
    }
  }

  Future<bool> dangKyDeTai({
    required int gvhdId,
    required String tenDeTai,
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await DoAnService.postDangKyDeTai(
        gvhdId: gvhdId,
        tenDeTai: tenDeTai,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      if (result != null) {
        deTaiDetail = result;
        return true;
      } else {
        error = 'Đăng ký đề tài thất bại2.';
        return false;
      }
    } catch (e) {
      error = 'Đăng ký đề tài thất bại3: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

