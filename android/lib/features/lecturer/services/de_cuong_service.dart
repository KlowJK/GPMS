// filepath: lib/features/lecturer/services/de_cuong_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DeCuongService {
  static String get _base => AuthService.baseUrl;

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

  /// Danh sách đề cương theo tài khoản đăng nhậpda
  /// GET /api/de-cuong
  static Future<List<DeCuongItem>> list() async {
    final uri = Uri.parse(
      '$_base/api/de-cuong',
    ).replace(queryParameters: {'status': 'CHO_DUYET'});
    ;
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeCuongItem.fromJson(e)).toList();
  }

  static Future<DeCuongItem> approve({
    required int id,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$_base/api/de-cuong/$id/duyet',
    ).replace(queryParameters: {'reason': nhanXet});
    final res = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode({}), // send empty JSON body to satisfy PUT
    );
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty
        ? _extractList(body).first
        : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  static Future<DeCuongItem> reject({
    required int id,
    required String nhanXet,
  }) async {
    final uri = Uri.parse(
      '$_base/api/de-cuong/$id/tu-choi',
    ).replace(queryParameters: {'reason': nhanXet});
    final res = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode({}), // send empty JSON body to satisfy PUT
    );
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty
        ? _extractList(body).first
        : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  static Future<List<DeCuongItem>> fetchLogBySinhVien(String sinhVienId) async {
    final uri = Uri.parse(
      '$_base/api/giang-vien/sinh-vien/log',
    ).replace(queryParameters: {'maSinhVien': sinhVienId});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeCuongItem.fromJson(e)).toList();
  }
}
