import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/sinh_vien_item.dart';

class SinhVienService {
  /// GET /api/giang-vien/sinh-vien
  static Future<List<SinhVienItem>> fetch() async {
    final uri = Uri.parse(
      '${AuthService.baseUrl}/api/giang-vien/sinh-vien/list',
    );
    final headers = await _headers();

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('GET $uri failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);
    final list = _extractList(data);

    // map -> model
    return list
        .map((e) => SinhVienItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  /// Nhận mọi kiểu trả về thường gặp: List, {result: [...]}, {result:{content:[...]}}, {content:[...]}…
  static List _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final r = data['result'];

      if (r is List) return r;

      if (r is Map && r['content'] is List) {
        return List.from(r['content']);
      }

      if (r is Map && r['items'] is List) {
        return List.from(r['items']);
      }

      if (data['content'] is List) return List.from(data['content']);
      if (data['items'] is List) return List.from(data['items']);
    }

    // Không ném TypeError nữa -> trả list rỗng để UI hiển thị "Không có dữ liệu"
    return <dynamic>[];
  }
}
