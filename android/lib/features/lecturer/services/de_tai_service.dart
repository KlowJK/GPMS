import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/de_tai_item.dart';

class DeTaiService {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  DeTaiService({required this.baseUrl, required this.tokenProvider});

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

  /// Fetch danh sách đề tài chờ duyệt
  ///
  /// GET /api/giang-vien/do-an/xet-duyet-de-tai?status=CHO_DUYET
  Future<List<DeTaiItem>> fetchApprovalList() async {
    final uri = Uri.parse(
      '$baseUrl/api/giang-vien/do-an/xet-duyet-de-tai',
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
      return list.map((e) => DeTaiItem.fromJson(e)).toList();
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

  /// Duyệt đề tài
  ///
  /// PUT /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/approve
  Future<DeTaiItem> approve({
    required int deTaiId,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/giang-vien/do-an/xet-duyet-de-tai/$deTaiId/approve',
    );

    try {
      final headers = await _headers();
      final res = await http
          .put(uri, headers: headers, body: jsonEncode({'nhanXet': nhanXet}))
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
      return DeTaiItem.fromJson(Map<String, dynamic>.from(map));
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

  /// Từ chối đề tài
  ///
  /// PUT /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/reject
  Future<DeTaiItem> reject({
    required int deTaiId,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/giang-vien/do-an/xet-duyet-de-tai/$deTaiId/reject',
    );

    try {
      final headers = await _headers();
      final res = await http
          .put(uri, headers: headers, body: jsonEncode({'nhanXet': nhanXet}))
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
      return DeTaiItem.fromJson(Map<String, dynamic>.from(map));
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
