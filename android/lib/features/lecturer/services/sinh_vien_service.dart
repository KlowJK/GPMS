import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/sinh_vien_item.dart';

class SinhVienService {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  SinhVienService({required this.baseUrl, required this.tokenProvider});

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

      // Try different response formats
      if (m['result'] != null) {
        final result = m['result'];
        if (result is List) return _extractList(result);
        if (result is Map) {
          if (result['content'] is List) return _extractList(result['content']);
          if (result['items'] is List) return _extractList(result['items']);
        }
      }

      if (m['content'] is List) return _extractList(m['content']);
      if (m['items'] is List) return _extractList(m['items']);

      // Single item
      return [m];
    }

    return [];
  }

  /// Fetch danh sách sinh viên được hướng dẫn
  ///
  /// GET /api/giang-vien/sinh-vien/list
  Future<List<SinhVienItem>> fetch() async {
    final uri = Uri.parse('$baseUrl/api/giang-vien/sinh-vien/list');

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
        // No students found
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
      return list.map((e) => SinhVienItem.fromJson(e)).toList();
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
