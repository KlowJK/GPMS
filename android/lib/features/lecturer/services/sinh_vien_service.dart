// filepath: lib/features/lecturer/services/sinh_vien_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/services/auth_service.dart';
import '../models/sinh_vien_item.dart';

class SinhVienService {
  // -----------------------------
  // Dio + headers (kèm Bearer)
  // -----------------------------
  static Future<Dio> _dio() async {
    final token = await AuthService.getToken();
    final options = BaseOptions(
      baseUrl: AuthService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'accept': '*/*',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    return Dio(options);
  }

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

  // -----------------------------
  // GET danh sách sinh viên
  // -----------------------------
  static Future<List<SinhVienItem>> fetch() async {
    final dio = await _dio();
    try {
      final resp = await dio.get('/api/giang-vien/sinh-vien');
      final list = _extractList(resp.data)
          .map((e) => SinhVienItem.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList();
      return list;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[SinhVienService.fetch] DioException ${e.response?.statusCode} - ${e.message}');
      }
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      throw Exception(e.response?.data?.toString() ?? e.message ?? 'Lỗi mạng');
    } catch (e) {
      if (kDebugMode) print('[SinhVienService.fetch] error: $e');
      throw Exception('Lỗi khi tải danh sách sinh viên: $e');
    }
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
