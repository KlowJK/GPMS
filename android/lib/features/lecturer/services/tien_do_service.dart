import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/models/tuan.dart';

class TienDoService {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  TienDoService({required this.baseUrl, required this.tokenProvider});

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
      return [m]; // Single object wrapped in list
    }

    return [];
  }

  /// Fetch tất cả nhật ký (theo tuần)
  ///
  /// GET /api/nhat-ky-tien-trinh/all-nhat-ky/list?tuan=...
  Future<List<TienDoSinhVien>> fetchAllNhatKy({int? tuan}) async {
    final queryParams = tuan != null ? {'tuan': '$tuan'} : null;
    final uri = Uri.parse(
      '$baseUrl/api/nhat-ky-tien-trinh/all-nhat-ky/list',
    ).replace(queryParameters: queryParams);

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
      return TienDoSinhVien.listFromJson(list);
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

  /// Fetch nhật ký by ID
  ///
  /// GET /api/nhat-ky-tien-trinh/{id}
  Future<List<TienDoSinhVien>> fetchNhatKyByIdList({required int id}) async {
    final uri = Uri.parse('$baseUrl/api/nhat-ky-tien-trinh/$id');

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
        return []; // Not found
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
      return TienDoSinhVien.listFromJson(list);
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

  /// Fetch sinh viên được hướng dẫn
  ///
  /// GET /api/nhat-ky-tien-trinh/my-supervised-students/list?status=...
  Future<List<TienDoSinhVien>> fetchMySupervisedStudents({
    String? status,
  }) async {
    final queryParams = status != null ? {'status': status} : null;
    final uri = Uri.parse(
      '$baseUrl/api/nhat-ky-tien-trinh/my-supervised-students/list',
    ).replace(queryParameters: queryParams);

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
      return TienDoSinhVien.listFromJson(list);
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

  /// Fetch danh sách tuần
  ///
  /// GET /api/nhat-ky-tien-trinh/tuans-by-lecturer?includeAll=...
  Future<List<Tuan>> fetchTuansByLecturer({bool includeAll = false}) async {
    final uri = Uri.parse(
      '$baseUrl/api/nhat-ky-tien-trinh/tuans-by-lecturer',
    ).replace(queryParameters: {'includeAll': '$includeAll'});

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
      return Tuan.listFromJson(list);
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

  /// Duyệt nhật ký
  ///
  /// PUT /api/nhat-ky-tien-trinh/{id}/duyet
  Future<void> approveReport({required int id, required String nhanXet}) async {
    final uri = Uri.parse('$baseUrl/api/nhat-ky-tien-trinh/$id/duyet');
    final body = jsonEncode({'id': id, 'nhanXet': nhanXet});

    try {
      final headers = await _headers();
      final res = await http
          .put(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final responseBody = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(responseBody));
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
