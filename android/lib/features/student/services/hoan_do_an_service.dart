import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../auth/services/auth_service.dart';
import '../models/de_nghi_hoan_model.dart';

class HoanDoAnService {
  final String baseUrl;

  HoanDoAnService({required this.baseUrl});

  Future<List<DeNghiHoanModel>> getDanhSachDeNghi() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Lỗi xác thực: Không tìm thấy token.');
    }

    final uri = Uri.parse('$baseUrl/api/de-tai/danh-sach-sinh-vien/hoan-do-an');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData.containsKey('result') &&
          responseData['result'] is Map &&
          responseData['result'].containsKey('content')) {
        final List<dynamic> content = responseData['result']['content'];
        return content.map((json) => DeNghiHoanModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi API: Phản hồi không hợp lệ.');
      }
    } else {
      final errorMessage = responseData['message'] ?? 'Lấy danh sách thất bại.';
      throw Exception('Lỗi ${response.statusCode}: $errorMessage');
    }
  }

  Future<DeNghiHoanModel> guiDeNghiHoan({
    required String lyDo,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Lỗi xác thực: Không tìm thấy token.');
    }

    final uri = Uri.parse('$baseUrl/api/de-tai/sinh-vien/hoan-do-an');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['lyDo'] = lyDo;

    // Handle file attachment based on platform
    if (fileName != null) {
      if (kIsWeb && fileBytes != null) {
        // Web platform uses bytes
        request.files.add(http.MultipartFile.fromBytes(
          'minhChungFile',
          fileBytes,
          filename: fileName,
        ));
      } else if (!kIsWeb && filePath != null) {
        // Mobile platform uses path
        request.files.add(await http.MultipartFile.fromPath(
          'minhChungFile',
          filePath,
          filename: fileName,
        ));
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData.containsKey('result')) {
          return DeNghiHoanModel.fromJson(responseData['result']);
        } else {
          throw Exception('Lỗi API: Phản hồi không chứa trường "result".');
        }
      } else {
        final errorMessage = responseData['message'] ?? 'Gửi đề nghị thất bại.';
        throw Exception('Lỗi ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Đã có lỗi không mong muốn xảy ra khi gửi đề nghị: $e');
    }
  }
}
