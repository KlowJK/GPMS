import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';

/// Service gọi API Sinh viên cho giảng viên
class SinhVienService {
  static String get _base => AuthService.baseUrl;

  /// Lấy danh sách sinh viên (phân trang)
  /// GET /api/sinh-vien?page=&size=
  static Future<Map<String, dynamic>> fetchPage({
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('401: Bạn cần đăng nhập.');
    }
    final uri = Uri.parse('$_base/api/sinh-vien?page=$page&size=$size');
    final res = await http.get(uri, headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>; // {result: Page{...}}
  }

  /// Thông tin chi tiết sinh viên
  /// GET /api/sinh-vien/{maSV}
  static Future<Map<String, dynamic>> fetchInfo(String maSV) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('401: Bạn cần đăng nhập.');
    }
    final uri = Uri.parse('$_base/api/sinh-vien/$maSV');
    final res = await http.get(uri, headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>; // {result: {...}}
  }
}
