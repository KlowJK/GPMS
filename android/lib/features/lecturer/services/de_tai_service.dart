import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/de_tai_item.dart';

class DeTaiService {
  static String get _base => AuthService.baseUrl;

  /// Headers có Bearer token
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

  /// Bóc tách mọi kiểu response về List<Map>
  static List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      if (m['result'] != null) return _extractList(m['result']);
      if (m['content'] != null) return _extractList(m['content']);
      // Trường hợp API trả 1 object đơn → convert thành list 1 phần tử
      return [m];
    }
    return const [];
  }

  /// Danh sách đề tài (mục Duyệt Đề tài)
  /// GET /api/giang-vien/do-an/xet-duyet-de-tai
  static Future<List<DeTaiItem>> fetchApprovalList() async {
    final uri = Uri.parse('$_base/api/giang-vien/do-an/xet-duyet-de-tai');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeTaiItem.fromJson(e)).toList();
  }

  /// DUYỆT đề tài (theo yêu cầu dùng GET)
  /// GET /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/approve?nhanXet=...
  static Future<DeTaiItem> approve({required int deTaiId, required String nhanXet}) async {
    final uri = Uri.parse('$_base/api/giang-vien/do-an/xet-duyet-de-tai/$deTaiId/approve')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty ? _extractList(body).first : (body is Map ? body : {});
    return DeTaiItem.fromJson(Map<String, dynamic>.from(map));
  }

  /// TỪ CHỐI đề tài (GET)
  /// GET /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/reject?nhanXet=...
  static Future<DeTaiItem> reject({required int deTaiId, required String nhanXet}) async {
    final uri = Uri.parse('$_base/api/giang-vien/do-an/xet-duyet-de-tai/$deTaiId/reject')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty ? _extractList(body).first : (body is Map ? body : {});
    return DeTaiItem.fromJson(Map<String, dynamic>.from(map));
  }
}
