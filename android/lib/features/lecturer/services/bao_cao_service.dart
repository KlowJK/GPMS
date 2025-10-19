import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/services/auth_service.dart';
import '../models/bao_cao_item.dart';

class BaoCaoService {
  static String get _base => AuthService.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // Chuẩn hoá mọi kiểu response -> List<Map>
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

  /// LIST cho giảng viên
  /// GET /api/bao-cao/list-bao-cao-giang-vien
  static Future<List<BaoCaoItem>> fetchList() async {
    final uri = Uri.parse('$_base/api/bao-cao/list-bao-cao-giang-vien');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => BaoCaoItem.fromJson(e)).toList();
  }
}
