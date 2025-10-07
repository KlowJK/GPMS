import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../auth/services/auth_service.dart';
import '../models/de_nghi_hoan_model.dart';

class HoanDoAnService {
  final String baseUrl;

  HoanDoAnService({required this.baseUrl});

  Future<DeNghiHoanModel> guiDeNghiHoan({
    required String lyDo,
    File? minhChungFile,
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

    if (minhChungFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'minhChungFile',
        minhChungFile.path,
        filename: p.basename(minhChungFile.path),
      ));
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
