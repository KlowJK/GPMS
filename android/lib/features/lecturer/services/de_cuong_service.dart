import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DeCuongService {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  DeCuongService({required this.baseUrl, required this.tokenProvider});

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
      if (m['result'] != null) return _extractList(m['result']);
      if (m['content'] != null) return _extractList(m['content']);
      return [m];
    }

    return [];
  }

  /// Fetch danh sách đề cương chờ duyệt
  ///
  /// GET /api/de-cuong?status=CHO_DUYET
  Future<List<DeCuongItem>> list() async {
    final uri = Uri.parse(
      '$baseUrl/api/de-cuong',
    ).replace(queryParameters: {'status': 'CHO_DUYET'});

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
      return list.map((e) => DeCuongItem.fromJson(e)).toList();
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

  /// Duyệt đề cương
  ///
  /// PUT /api/de-cuong/{id}/duyet?reason=...
  Future<DeCuongItem> approve({
    required int id,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/de-cuong/$id/duyet',
    ).replace(queryParameters: {'reason': nhanXet});

    try {
      final headers = await _headers();
      final res = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode({}), // Empty body as required
          )
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
      final map = _extractList(body).isNotEmpty
          ? _extractList(body).first
          : (body is Map ? body : {});
      return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
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

  /// Từ chối đề cương
  ///
  /// PUT /api/de-cuong/{id}/tu-choi?reason=...
  Future<DeCuongItem> reject({required int id, required String nhanXet}) async {
    final uri = Uri.parse(
      '$baseUrl/api/de-cuong/$id/tu-choi',
    ).replace(queryParameters: {'reason': nhanXet});

    try {
      final headers = await _headers();
      final res = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode({}), // Empty body as required
          )
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
      final map = _extractList(body).isNotEmpty
          ? _extractList(body).first
          : (body is Map ? body : {});
      return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
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

  /// Fetch lịch sử đề cương theo sinh viên
  ///
  /// GET /api/giang-vien/sinh-vien/log?maSinhVien=...
  Future<List<DeCuongItem>> fetchLogBySinhVien(String sinhVienId) async {
    final uri = Uri.parse(
      '$baseUrl/api/giang-vien/sinh-vien/log',
    ).replace(queryParameters: {'maSinhVien': sinhVienId});

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
        // Student not found or no logs
        return [];
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
      return list.map((e) => DeCuongItem.fromJson(e)).toList();
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
