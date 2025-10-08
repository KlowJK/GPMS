import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

class DeTaiService {
  static String get _base => '${AuthService.baseUrl}/api/de-tai';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    final sp = await SharedPreferences.getInstance();
    final type = (sp.getString('typeToken') ?? 'Bearer').trim();
    if (token == null || token.isEmpty) {
      throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
    }
    return {
      'accept': 'application/json',
      'content-type': 'application/json',
      'Authorization': '$type $token',
    };
  }

  /// GET /api/de-tai/xet-duyet?trangThai=...&page=...&size=...
  static Future<Map<String, dynamic>> fetchPage({
    String trangThai = 'CHO_DUYET',
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('$_base/xet-duyet?trangThai=$trangThai&page=$page&size=$size');
    final res = await http.get(uri, headers: await _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PUT /api/de-tai/xet-duyet/{deTaiId}
  static Future<Map<String, dynamic>> approveDeTai({
    required int deTaiId,
    required bool approved,
    String? nhanXet,
  }) async {
    final uri = Uri.parse('$_base/xet-duyet/$deTaiId');
    final body = jsonEncode({'approved': approved, if (nhanXet != null) 'nhanXet': nhanXet});
    final res = await http.put(uri, headers: await _authHeaders(), body: body);
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
