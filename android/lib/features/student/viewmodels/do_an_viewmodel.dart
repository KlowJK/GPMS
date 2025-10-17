import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/de_cuong.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/de_tai_detail.dart';
import 'package:GPMS/features/student/models/giang_vien_huong_dan.dart';
import 'package:GPMS/features/student/services/do_an_service.dart';

class DoAnViewModel extends ChangeNotifier {
  DeTaiDetail? deTaiDetail;
  DeCuong? deCuong;
  List<DeCuongLog> deCuongLogs = [];
  bool isLoading = true;
  String? error;

  List<GiangVienHuongDan> advisors = [];
  bool isLoadingAdvisors = false;
  String? advisorError;

  DoAnViewModel() {
    fetchDeTaiChiTiet();
    fetchAdvisors();
    fetchDeCuongLogs();
  }

  Future<void> fetchDeCuongLogs() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      deCuongLogs = await DoAnService.fetchDeCuongLogs();
    } catch (e) {
      error = 'Đã xảy ra lỗi khi tải lịch sử nộp đề cương: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDeTaiChiTiet() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await DoAnService.fetchDeTaiChiTiet();
      deTaiDetail = result;
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
      advisors = [];
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
        error = 'Đăng ký đề tài thất bại.';
        return false;
      }
    } catch (e) {
      error = 'Đăng ký đề tài thất bại: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> nopDeCuong({required String fileUrl}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await DoAnService.nopDeCuong(fileUrl: fileUrl);
      if (result != null) {
        deCuong = result;
        // Sau khi nộp thành công, tải lại danh sách logs
        await fetchDeCuongLogs();
        return true;
      } else {
        error = 'Nộp đề cương thất bại.';
        return false;
      }
    } catch (e) {
      error = 'Nộp đề cương thất bại: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
