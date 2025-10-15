// filepath: lib/features/lecturer/services/tien_do_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/services/auth_service.dart';

/// Trạng thái hiển thị ở màn danh sách
enum SubmitStatus { submitted, missing }

/// Item cho màn danh sách sinh viên (từ /api/nhat-ky-tien-trinh)
class ProgressStudent {
  final int idDeTai;
  final String hoTen;
  final String maSinhVien;
  final String lop;
  final String deTai;
  final int tuan; // tuần hiện tại
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final SubmitStatus status;

  ProgressStudent({
    required this.idDeTai,
    required this.hoTen,
    required this.maSinhVien,
    required this.lop,
    required this.deTai,
    required this.tuan,
    required this.status,
    required this.ngayBatDau,
    required this.ngayKetThuc,
  });

  /// Map chuỗi trạng thái backend -> SubmitStatus
  static SubmitStatus _mapStatus(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'DA_NOP':
      case 'HOAN_THANH':
        return SubmitStatus.submitted;
      case 'CHUA_NOP':
      default:
        return SubmitStatus.missing;
    }
  }

  factory ProgressStudent.fromJson(Map<String, dynamic> j) {
    DateTime? _p(String? iso) =>
        (iso == null || iso.isEmpty) ? null : DateTime.tryParse(iso);
    return ProgressStudent(
      idDeTai: (j['idDeTai'] as num).toInt(),
      hoTen: (j['hoTen'] ?? '') as String,
      maSinhVien: (j['maSinhVien'] ?? '') as String,
      lop: (j['lop'] ?? '') as String,
      deTai: (j['deTai'] ?? '') as String,
      tuan: (j['tuan'] is num) ? (j['tuan'] as num).toInt() : 1,
      ngayBatDau: _p(j['ngayBatDau'] as String?),
      ngayKetThuc: _p(j['ngayKetThuc'] as String?),
      status: _mapStatus(j['trangThaiNhatKy'] as String?),
    );
  }
}

/// Item tuần cho màn chi tiết (từ /api/nhat-ky-tien-trinh/tuans)
class WeeklyEntry {
  final int tuan;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String noiDung;
  final String duongDanFile;
  final String? nhanXet;

  WeeklyEntry({
    required this.tuan,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.noiDung,
    required this.duongDanFile,
    required this.nhanXet,
  });

  factory WeeklyEntry.fromJson(Map<String, dynamic> j) {
    DateTime? _p(String? iso) =>
        (iso == null || iso.isEmpty) ? null : DateTime.tryParse(iso);
    return WeeklyEntry(
      tuan: (j['tuan'] as num).toInt(),
      ngayBatDau: _p(j['ngayBatDau'] as String?),
      ngayKetThuc: _p(j['ngayKetThuc'] as String?),
      noiDung: (j['noiDung'] ?? '') as String,
      duongDanFile: (j['duongDanFile'] ?? '') as String,
      nhanXet: j['nhanXet'] as String?,
    );
  }
}

class TienDoService {
  final Dio _dio;

  TienDoService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: AuthService.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    final h = <String, String>{'accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  /// Màn chính: GET /api/nhat-ky-tien-trinh?tuan=...
  Future<List<ProgressStudent>> fetchStudents({int? week}) async {
    final headers = await _headers();
    final qp = <String, dynamic>{};
    if (week != null) qp['tuan'] = week;

    try {
      if (kDebugMode) {
        print('[TienDoService] GET /api/nhat-ky-tien-trinh $qp');
      }
      final resp = await _dio.get(
        '/api/nhat-ky-tien-trinh',
        queryParameters: qp,
        options: Options(headers: headers),
      );

      final data = resp.data;
      List list;
      if (data is Map && data['result'] is List) {
        list = data['result'] as List;
      } else if (data is List) {
        list = data;
      } else {
        list = const [];
      }
      return list
          .map((e) => ProgressStudent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'Lỗi tải danh sách tiến độ: ${e.response?.data ?? e.message}');
    }
  }

  /// Màn chi tiết: GET /api/nhat-ky-tien-trinh/tuans?deTaiId=...
  Future<List<WeeklyEntry>> fetchWeeksByTopic(int deTaiId) async {
    final headers = await _headers();
    try {
      if (kDebugMode) {
        print('[TienDoService] GET /api/nhat-ky-tien-trinh/tuans?deTaiId=$deTaiId');
      }
      final resp = await _dio.get(
        '/api/nhat-ky-tien-trinh/tuans',
        queryParameters: {'deTaiId': deTaiId},
        options: Options(headers: headers),
      );
      final data = resp.data;
      final list = (data is Map && data['result'] is List)
          ? (data['result'] as List)
          : (data is List ? data : const []);
      return list
          .map((e) => WeeklyEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'Lỗi tải nhật ký theo tuần: ${e.response?.data ?? e.message}');
    }
  }

  /// PUT /api/nhat-ky-tien-trinh/{deTaiId}/nop-nhat-ky  body: { tuan, nhanXet }
  Future<void> submitReview({
    required int deTaiId,
    required int tuan,
    required String nhanXet,
  }) async {
    final headers = await _headers();
    final body = {'tuan': tuan, 'nhanXet': nhanXet};
    try {
      if (kDebugMode) {
        print('[TienDoService] PUT /api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky $body');
      }
      await _dio.put(
        '/api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky',
        data: body,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw Exception(
          'Gửi nhận xét thất bại: ${e.response?.data ?? e.message}');
    }
  }
}
