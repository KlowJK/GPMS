import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DeCuongService {
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

  /// Danh sách đề cương theo tài khoản đăng nhập
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

  /// DUYỆT đề cương (GET)
  /// GET /api/de-cuong/{id}/duyet?nhanXet=...
  static Future<DeCuongItem> approve({required int id, required String nhanXet}) async {
    final uri = Uri.parse('$_base/api/de-cuong/$id/duyet')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty ? _extractList(body).first : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  /// TỪ CHỐI đề cương (GET)
  /// GET /api/de-cuong/{id}/tu-choi?nhanXet=...
  static Future<DeCuongItem> reject({required int id, required String nhanXet}) async {
    final uri = Uri.parse('$_base/api/de-cuong/$id/tu-choi')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty ? _extractList(body).first : (body is Map ? body : {});
    return DeCuongItem.fromJson(Map<String, dynamic>.from(map));
  }

  /// Log đề cương của sinh viên trong màn chi tiết đề tài
  /// GET /api/de-cuong/sinh-vien/log?sinhVienId=...
  static Future<List<DeCuongItem>> fetchLogBySinhVien(int sinhVienId) async {
    final uri = Uri.parse('$_base/api/de-cuong/sinh-vien/log')
        .replace(queryParameters: {'sinhVienId': '$sinhVienId'});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final list = _extractList(body);
    return list.map((e) => DeCuongItem.fromJson(e)).toList();
  }
}
