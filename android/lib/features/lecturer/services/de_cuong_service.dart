import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/auth/services/auth_service.dart';

class DeCuongService {
  static String get _base => AuthService.baseUrl;

  /// GET /api/de-cuong?page=&size=
  static Future<Map<String, dynamic>> fetchPage({int page = 0, int size = 10}) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

    final uri = Uri.parse('$_base/api/de-cuong').replace(queryParameters: {'page': '$page', 'size': '$size'});
    final res = await http.get(uri, headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PUT /api/de-cuong/{id}/duyet
  static Future<Map<String, dynamic>> approve({required int id, required String nhanXet}) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

    final uri = Uri.parse('$_base/api/de-cuong/$id/duyet');
    final res = await http.put(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nhanXet': nhanXet}),
    );

    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// PUT /api/de-cuong/{id}/tu-choi
  static Future<Map<String, dynamic>> reject({required int id, required String nhanXet}) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

    final uri = Uri.parse('$_base/api/de-cuong/$id/tu-choi');
    final res = await http.put(
      uri,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nhanXet': nhanXet}),
    );

    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
