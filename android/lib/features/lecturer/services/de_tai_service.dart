// filepath: lib/features/lecturer/services/de_tai_service.dart
import 'dart:convert';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/de_tai_item.dart';

class DeTaiService {
  static String get _base => AuthService.baseUrl;

  /// Headers có Bearer token
  static Future<Map<String, String>> _headers({String? status}) async {
    final token = await AuthService.getToken();
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    if (status != null && status.isNotEmpty) {
      h['status'] = status; // pass 'CHO_DUYET' when needed
    }
    return h;
  }

  /// Bóc tách mọi kiểu response về List<Map>
  static List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw == null) return const [];
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
    return const [];
  }

  /// GET /api/giang-vien/do-an/xet-duyet-de-tai
  // dart
  static Future<List<DeTaiItem>> fetchApprovalList() async {
    // Use query parameter so backend can filter by status
    final uri = Uri.parse('$_base/api/giang-vien/do-an/xet-duyet-de-tai')
        .replace(
          queryParameters: {'status': 'CHO_DUYET'},
        ); // or {'trangThai': 'CHO_DUYET'}

    final headers = await _headers(); // keep auth headers here
    print('GET $uri');
    final res = await http.get(uri, headers: headers);

    print('RESPONSE ${res.statusCode}: ${res.body}');
    if (res.statusCode != 200) {
      throw CustomException(ErrorCode.fromResponse(jsonDecode(res.body)));
    }

    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeTaiItem.fromJson(e)).toList();
  }

  /// GET /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/approve?nhanXet=...
  static Future<DeTaiItem> approve({
    required int deTaiId,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$_base/api/giang-vien/do-an/xet-duyet-de-tai/$deTaiId/approve',
    );
    final headers = await _headers();
    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({'nhanXet': nhanXet}),
    );
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty
        ? _extractList(body).first
        : (body is Map ? body : {});
    return DeTaiItem.fromJson(Map<String, dynamic>.from(map));
  }

  static Future<DeTaiItem> reject({
    required int deTaiId,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$_base/api/giang-vien/do-an/xet-duyet-de-tai/$deTaiId/reject',
    );
    final headers = await _headers();
    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({'nhanXet': nhanXet}),
    );
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty
        ? _extractList(body).first
        : (body is Map ? body : {});
    return DeTaiItem.fromJson(Map<String, dynamic>.from(map));
  }
}
