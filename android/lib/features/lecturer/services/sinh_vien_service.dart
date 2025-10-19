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

  // -----------------------------
  // Helper: bóc list từ nhiều kiểu response khác nhau
  // -----------------------------
  static List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Phổ biến kiểu { result: { content: [...] } }
      final result = data['result'];
      if (result is Map<String, dynamic>) {
        if (result['content'] is List) {
          return List<dynamic>.from(result['content'] as List);
        }
        if (result['data'] is List) {
          return List<dynamic>.from(result['data'] as List);
        }
      }
      // Hoặc { content: [...] } / { data: [...] }
      if (data['content'] is List) {
        return List<dynamic>.from(data['content'] as List);
      }
      if (data['data'] is List) {
        return List<dynamic>.from(data['data'] as List);
      }
    } else if (data is List) {
      return data;
    }
    return <dynamic>[];
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  // -----------------------------
  // POST/GET nộp danh sách (đổi path nếu backend khác)
  // -----------------------------
  static const String _submitPath = '/api/giang-vien/sinh-vien/nop-danh-sach';

  static Future<void> submitDanhSach() async {
    final dio = await _dio();
    try {
      // Nếu server dùng GET, đổi dòng dưới thành: await dio.get(_submitPath);
      final resp = await dio.post(_submitPath);
      final code = resp.statusCode ?? 200;
      if (![200, 201, 204].contains(code)) {
        throw Exception('HTTP $code: ${resp.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[SinhVienService.submitDanhSach] DioException ${e.response?.statusCode} - ${e.message}');
      }
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      throw Exception(e.response?.data?.toString() ?? e.message ?? 'Lỗi mạng');
    } catch (e) {
      if (kDebugMode) print('[SinhVienService.submitDanhSach] error: $e');
      throw Exception('Gửi danh sách thất bại: $e');
    }
  }
}
