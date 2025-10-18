import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/de_cuong.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/de_tai_detail.dart';
import 'package:GPMS/features/student/models/giang_vien_huong_dan.dart';
import 'package:GPMS/features/student/services/do_an_service.dart';

class DoAnViewModel extends ChangeNotifier {
  // Đề tài
  DeTaiDetail? deTaiDetail;
  bool isLoadingDeTai = false;
  String? deTaiError;

  // Đề cương hiện tại
  DeCuong? deCuong;

  // Lịch sử nộp đề cương (logs)
  List<DeCuongLog> deCuongLogs = [];
  bool isLoadingLogs = false;
  String? logsError;

  // Giảng viên hướng dẫn
  List<GiangVienHuongDan> advisors = [];
  bool isLoadingAdvisors = false;
  String? advisorError;

  DoAnViewModel() {
    // Gọi song song nhưng lỗi ở logs không ảnh hưởng đề tài
    fetchDeTaiChiTiet();
    fetchAdvisors();
    fetchDeCuongLogs();
  }

  Future<void> fetchDeCuongLogs() async {
    isLoadingLogs = true;
    logsError = null;
    notifyListeners();
    try {
      deCuongLogs = await DoAnService.fetchDeCuongLogs();
    } catch (e) {
      // KHÔNG ném lỗi ra ngoài để tránh che UI đề tài
      logsError = 'Không thể tải lịch sử nộp đề cương: $e';
      deCuongLogs = [];
    } finally {
      isLoadingLogs = false;
      notifyListeners();
    }
  }

  Future<void> fetchDeTaiChiTiet() async {
    isLoadingDeTai = true;
    deTaiError = null;
    notifyListeners();
    try {
      final result = await DoAnService.fetchDeTaiChiTiet();
      deTaiDetail = result;
    } catch (e) {
      deTaiError = 'Đã xảy ra lỗi khi tải đề tài: $e';
    } finally {
      isLoadingDeTai = false;
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
    isLoadingDeTai = true;
    deTaiError = null;
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
        deTaiError = 'Đăng ký đề tài thất bại.';
        return false;
      }
    } catch (e) {
      deTaiError = 'Đăng ký đề tài thất bại: $e';
      return false;
    } finally {
      isLoadingDeTai = false;
      notifyListeners();
    }
  }

  Future<bool> nopDeCuong({required String fileUrl}) async {
    // Nộp đề cương có thể dùng cờ riêng nếu muốn, tạm dùng lại isLoadingLogs để tránh thêm cờ mới
    isLoadingLogs = true;
    logsError = null;
    notifyListeners();
    try {
      final result = DoAnService.nopDeCuong(fileUrl: fileUrl);
      final deCuongResult = await result;
      if (deCuongResult != null) {
        deCuong = deCuongResult;
        await fetchDeCuongLogs(); // tải lại logs nhưng không chặn UI đề tài
        return true;
      } else {
        logsError = 'Nộp đề cương thất bại.';
        return false;
      }
    } catch (e) {
      logsError = 'Nộp đề cương thất bại: $e';
      return false;
    } finally {
      isLoadingLogs = false;
      notifyListeners();
    }
  }
}
