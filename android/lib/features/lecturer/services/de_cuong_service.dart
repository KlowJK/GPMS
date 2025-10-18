// filepath: lib/features/lecturer/services/de_cuong_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DeCuongService {
  static String get _base => AuthService.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final raw = await AuthService.getToken();
    String? token = raw;
    if (token != null && token.startsWith('Bearer ')) token = token.substring(7);

    if (kDebugMode) {
      debugPrint('[DeCuongService] tokenPrefix='
          '${token == null ? "NULL" : token.substring(0, token.length > 10 ? 10 : token.length)}...');
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

  /// GET /api/de-cuong
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

  // PUT /api/de-cuong/{id}/duyet?reason=... (&nhanXet=... để tương thích ngược)
  static Future<DeCuongItem> approve({
    required int id,
    required String nhanXet,
    bool alsoSendBody = false, // bật nếu BE yêu cầu body JSON
  }) async {
    final note = nhanXet.trim();
    if (note.isEmpty) throw ArgumentError('Nhận xét bắt buộc.');

    final uri = Uri.parse('$_base/api/de-cuong/$id/duyet').replace(
      queryParameters: {
        'reason': note,     // <<< tên BE đang cần
        'nhanXet': note,    // (tùy chọn) giữ để tương thích
      },
    );

    final h = await _headers();
    if (kDebugMode) {
      debugPrint('[DeCuongService.approve] PUT $uri');
      debugPrint('  headers: $h');
    }

    final res = await http.put(
      uri,
      headers: h,
      body: alsoSendBody ? jsonEncode({'idDeCuong': id, 'reason': note}) : null,
    );

    if (res.statusCode != 200) {
      if (kDebugMode) debugPrint('approve sent headers: ${res.request?.headers}');
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    final list = _extractList(body);
    final map = list.isNotEmpty ? list.first : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  // PUT /api/de-cuong/{id}/tu-choi?reason=... (&nhanXet=...)
  static Future<DeCuongItem> reject({
    required int id,
    required String nhanXet,
    bool alsoSendBody = false,
  }) async {
    final note = nhanXet.trim();
    if (note.isEmpty) throw ArgumentError('Nhận xét bắt buộc.');

    final uri = Uri.parse('$_base/api/de-cuong/$id/tu-choi').replace(
      queryParameters: {
        'reason': note,     // <<< tên BE cần
        'nhanXet': note,    // (tùy chọn)
      },
    );

    final h = await _headers();
    if (kDebugMode) {
      debugPrint('[DeCuongService.reject] PUT $uri');
      debugPrint('  headers: $h');
    }

    final res = await http.put(
      uri,
      headers: h,
      body: alsoSendBody ? jsonEncode({'idDeCuong': id, 'reason': note}) : null,
    );

    if (res.statusCode != 200) {
      if (kDebugMode) debugPrint('reject sent headers: ${res.request?.headers}');
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
