import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:GPMS/features/lecturer/models/student_supervised.dart';

class BaoCaoService {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  BaoCaoService({required this.baseUrl, required this.tokenProvider});

  /// Get headers with Bearer token
  Future<Map<String, String>> _headers() async {
    final token = await tokenProvider();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Extract list from various response formats
  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      if (m['result'] is List) return _extractList(m['result']);
      if (m['content'] is List) return _extractList(m['content']);
      return [m];
    }

    return [];
  }

  /// Fetch danh sách sinh viên được hướng dẫn
  ///
  /// GET /api/bao-cao/list-sinh-vien-supervised
  Future<List<StudentSupervised>> fetchSupervisedStudents() async {
    final uri = Uri.parse('$baseUrl/api/bao-cao/list-sinh-vien-supervised');

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);
      final list = _extractList(body);
      return list.map((e) => StudentSupervised.fromJson(e)).toList();
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch danh sách báo cáo
  ///
  /// GET /api/bao-cao/list-bao-cao-giang-vien?status=...
  Future<List<ReportSubmission>> fetchList({String? status}) async {
    final uri = Uri.parse(
      '$baseUrl/api/bao-cao/list-bao-cao-giang-vien',
    ).replace(queryParameters: status != null ? {'status': status} : null);

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);
      final list = _extractList(body);
      return list.map((e) => ReportSubmission.fromJson(e)).toList();
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch báo cáo của sinh viên
  ///
  /// GET /api/bao-cao/list-bao-cao-sinh-vien?maSinhVien=...
  Future<List<ReportSubmission>> fetchStudentReports({
    required String maSinhVien,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/bao-cao/list-bao-cao-sinh-vien',
    ).replace(queryParameters: {'maSinhVien': maSinhVien});

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode == 404) {
        return []; // No reports found
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);
      final list = _extractList(body);
      return list.map((e) => ReportSubmission.fromJson(e)).toList();
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Duyệt báo cáo
  ///
  /// PUT /api/bao-cao/duyet
  Future<void> approveReport({
    required int idBaoCao,
    required double diemHuongDan,
    String? nhanXet,
  }) async {
    final queryParams = <String, String>{
      'idBaoCao': '$idBaoCao',
      'diemHuongDan': '$diemHuongDan',
      if (nhanXet != null && nhanXet.isNotEmpty) 'nhanXet': nhanXet,
    };

    final uri = Uri.parse(
      '$baseUrl/api/bao-cao/duyet',
    ).replace(queryParameters: queryParams);

    try {
      final headers = await _headers();
      final res = await http
          .put(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Từ chối báo cáo
  ///
  /// PUT /api/bao-cao/tu-choi
  Future<void> rejectReport({
    required int idBaoCao,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/bao-cao/tu-choi',
    ).replace(queryParameters: {'idBaoCao': '$idBaoCao', 'nhanXet': nhanXet});

    try {
      final headers = await _headers();
      final res = await http
          .put(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }
}
