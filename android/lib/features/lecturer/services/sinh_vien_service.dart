import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/sinh_vien_item.dart';

class SinhVienService {
  static String get _base => AuthService.baseUrl;

  /// GET /api/giang-vien/sinh-vien
  /// Trả về List<SinhVienItem>. Chịu được format:
  /// - [ {...}, {...} ]
  /// - { result: [ ... ] }
  /// - { result: { content: [ ... ] } }
  /// - { content: [ ... ] } hoặc { items: [ ... ] }
  static Future<List<SinhVienItem>> fetchList() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('UNAUTHORIZED: thiếu token, hãy đăng nhập.');
    }

    final uri = Uri.parse('$_base/api/giang-vien/sinh-vien');
    final res = await http.get(uri, headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }

    final raw = jsonDecode(res.body);

    // bóc “list” từ nhiều lớp bọc khác nhau
    dynamic maybeList = raw;
    if (maybeList is Map && maybeList.containsKey('result')) {
      maybeList = maybeList['result'];
    }
    if (maybeList is Map) {
      maybeList = maybeList['content'] ?? maybeList['items'] ?? [];
    }
    if (maybeList is! List) {
      throw FormatException('Response không đúng dạng List');
    }

    return maybeList
        .where((e) => e != null)
        .map((e) => SinhVienItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
