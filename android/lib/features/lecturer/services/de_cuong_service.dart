// filepath: lib/features/lecturer/services/de_cuong_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DeCuongService {
  static String get _base => AuthService.baseUrl;

  /// Header giống DeTaiService: có Accept + Content-Type và Authorization Bearer <token>
  static Future<Map<String, String>> _headers() async {
    final raw = await AuthService.getToken();

    if (kDebugMode) {
      final short = raw == null
          ? 'NULL'
          : '${raw.substring(0, raw.length > 12 ? 12 : raw.length)}... (len=${raw.length})';
      print('[DeCuongService] token(short) = $short');
    }

    // Cắt "Bearer " nếu token đã có sẵn
    String? token = raw;
    if (token != null && token.startsWith('Bearer ')) {
      token = token.substring(7);
    }

    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      if (m['result'] != null) return _extractList(m['result']);
      if (m['content'] != null) return _extractList(m['content']);
      return [m];
    }
    return const [];
  }

  /// GET /api/de-cuong (giữ nguyên)
  static Future<List<DeCuongItem>> list() async {
    final uri = Uri.parse('$_base/api/de-cuong');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeCuongItem.fromJson(e)).toList();
  }

  /// ✅ PUT /api/de-cuong/{id}/duyet?nhanXet=...
  static Future<DeCuongItem> approve({
    required int id,
    required String nhanXet,
  }) async {
    final uri = Uri.parse('$_base/api/de-cuong/$id/duyet')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.put(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    final map = list.isNotEmpty ? list.first : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  /// ✅ PUT /api/de-cuong/{id}/tu-choi?nhanXet=...
  static Future<DeCuongItem> reject({
    required int id,
    required String nhanXet,
  }) async {
    final uri = Uri.parse('$_base/api/de-cuong/$id/tu-choi')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.put(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    final map = list.isNotEmpty ? list.first : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  /// GET /api/giang-vien/sinh-vien/log?maSinhVien=...
  static Future<List<DeCuongItem>> fetchLogBySinhVien(String maSinhVien) async {
    final uri = Uri.parse('$_base/api/giang-vien/sinh-vien/log')
        .replace(queryParameters: {'maSinhVien': maSinhVien});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeCuongItem.fromJson(e)).toList();
  }
}
