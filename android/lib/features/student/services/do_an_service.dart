import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/de_tai_detail.dart';
import '../models/giang_vien_huong_dan.dart';

class DoAnService {
  static String get _baseUrl => AuthService.baseUrl;

  static Future<DeTaiDetail?> fetchDeTaiChiTiet() async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    final response = await http.get(
      Uri.parse(_baseUrl + "/api/de-tai/chi-tiet"),
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null) {
        return DeTaiDetail.fromJson(data['result']);
      }
    }
    return null;
  }

  static Future<List<GiangVienHuongDan>> fetchAdvisors() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(_baseUrl + '/api/giang_vien/advisors'),
      headers: {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['result'] as List)
          .map((e) => GiangVienHuongDan.fromJson(e))
          .toList();
    } else {
      throw Exception('Không thể tải danh sách giảng viên.');
    }
  }

  static Future<DeTaiDetail?> postDangKyDeTai({
    required int gvhdId,
    required String tenDeTai,
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(_baseUrl + '/api/de-tai/dang-ky');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['gvhdId'] = gvhdId.toString()
      ..fields['tenDeTai'] = tenDeTai;
    if (kIsWeb) {
      if (fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'fileTongQuan',
            fileBytes,
            filename: fileName,
          ),
        );
      }
    } else {
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('fileTongQuan', filePath),
        );
      }
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null) {
        return DeTaiDetail.fromJson(data['result']);
      }
    } else {
      throw Exception('Đăng ký đề tài thất bại1: ${response.statusCode}');
    }
    return null;
  }
}
