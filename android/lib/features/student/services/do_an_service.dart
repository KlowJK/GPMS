import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GPMS/features/student/models/de_cuong.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/de_tai_detail.dart';
import 'package:GPMS/features/student/models/giang_vien_huong_dan.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

class DoAnService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    const useEmulator = true;
    if (useEmulator) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://192.168.1.10:8080';
    }
  }

  static const _timeout = Duration(seconds: 15);

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (kDebugMode) {
        print('🔍 Retrieving token from SharedPreferences:');
        print('   - Token exists: [31m${token != null}[0m');
        print('   - Token length: ${token?.length ?? 0}');
        if (token == null || token.isEmpty) {
          print('❌ Token is null or empty!');
        } else {
          print(
            '   - Token first 20 chars: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          );
        }
        print('   - All SharedPreferences keys: ${prefs.getKeys()}');
      }
      if (token == null || token.isEmpty) {
        return null;
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token: $e');
      }
      return null;
    }
  }

  static Future<List<DeCuongLog>> fetchDeCuongLogs() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập hoặc phiên đã hết hạn.');
    }
    final response = await http
        .get(
          Uri.parse(_baseUrl + "/api/de-cuong/sinh-vien/log"),
          headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null) {
        final List<dynamic> logsJson = data['result'];
        return logsJson.map((json) => DeCuongLog.fromJson(json)).toList();
      }
      return [];
    } else {
      // Map lỗi từ server -> ErrorCode
      ErrorCode errorCode;
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is! Map<String, dynamic>) {
          if (kDebugMode) print('⚠️ Invalid JSON response: $errorData');
          throw Exception('Invalid response format');
        }
        errorCode = ErrorCode.fromResponse(errorData);
        if (kDebugMode) {
          print(
            'Parsed errorCode: ${errorCode.name}, field: ${errorCode.field}',
          );
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ Error parsing error response: $e');
        errorCode = ErrorCode.internalServerError;
      }
      throw CustomException(errorCode);
    }
  }

  static Future<DeTaiDetail?> fetchDeTaiChiTiet() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập hoặc phiên đã hết hạn.');
    }
    final response = await http.get(
      Uri.parse("$_baseUrl/api/de-tai/chi-tiet"),
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
    final token = await getToken();
    if (kDebugMode) {
      print('🔍 fetchAdvisors() - baseUrl=$_baseUrl');
      print('   - token present: ${token != null}');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/giang-vien/advisors'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print('📨 fetchAdvisors() status: ${response.statusCode}');
      print('📦 fetchAdvisors() body: ${response.body}');
      print(
        '📋 fetchAdvisors() headers sent: ${{'accept': '*/*', if (token != null) 'Authorization': 'Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...'}}',
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['result'] as List)
          .map((e) => GiangVienHuongDan.fromJson(e))
          .toList();
    } else if (response.statusCode != 200) {
      throw Exception('Bạn cần đăng nhập. (401)');
    } else {
      throw Exception(
        'Không thể tải danh sách giảng viên. (status=${response.statusCode})',
      );
    }
  }

  static Future<DeTaiDetail?> postDangKyDeTai({
    required int gvhdId,
    required String tenDeTai,
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập hoặc phiên đã hết hạn.');
    }
    final tokenTrim = token.trim();
    final uri = Uri.parse('$_baseUrl/api/de-tai/dang-ky');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $tokenTrim'
      ..headers['Accept'] = '*/*'
      ..fields['gvhdId'] = gvhdId.toString()
      ..fields['tenDeTai'] = tenDeTai;

    if (kIsWeb) {
      if (fileBytes != null && fileName != null) {
        // Try to deduce content type from filename extension
        String lower = fileName.toLowerCase();
        String mimeType = 'application/octet-stream';
        if (lower.endsWith('.pdf'))
          mimeType = 'application/pdf';
        else if (lower.endsWith('.doc'))
          mimeType = 'application/msword';
        else if (lower.endsWith('.docx'))
          mimeType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

        request.files.add(
          http.MultipartFile.fromBytes(
            'fileTongQuan',
            fileBytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    } else {
      if (filePath.isNotEmpty) {
        // Try to set contentType based on extension
        String lower = filePath.toLowerCase();
        MediaType? contentType;
        if (lower.endsWith('.pdf'))
          contentType = MediaType('application', 'pdf');
        else if (lower.endsWith('.doc'))
          contentType = MediaType('application', 'msword');
        else if (lower.endsWith('.docx'))
          contentType = MediaType(
            'application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document',
          );

        if (contentType != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'fileTongQuan',
              filePath,
              contentType: contentType,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('fileTongQuan', filePath),
          );
        }
      }
    }

    if (kDebugMode) {
      print('🔐 POST $uri');
      print('   - fields: ${request.fields}');
      print('   - files count: ${request.files.length}');
      print(
        '   - headers (partial): ${request.headers.map((k, v) => MapEntry(k, k == "Authorization" ? (v.length > 20 ? v.substring(0, 20) + "..." : v) : v))}',
      );
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null) {
        return DeTaiDetail.fromJson(data['result']);
      }
    } else {
      throw Exception('Đăng ký đề tài thất bại: ${response.statusCode}');
    }
    return null;
  }

  static Future<DeCuong?> nopDeCuong({required String fileUrl}) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập hoặc phiên đã hết hạn.');
    }

    final tokenTrim = token.trim();
    final uri = Uri.parse('$_baseUrl/api/de-cuong/sinh-vien/nop-de-cuong');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $tokenTrim'
      ..fields['fileUrl'] = fileUrl;

    if (kDebugMode) {
      print('🔐 POST $uri');
      print('   - fields: ${request.fields}');
      print(
        '   - headers (partial): ${request.headers.map((k, v) => MapEntry(k, k == "Authorization" ? (v.length > 20 ? v.substring(0, 20) + "..." : v) : v))}',
      );
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (kDebugMode) {
      print('📨 nopDeCuong status: ${response.statusCode}');
      print('📦 nopDeCuong body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null && data['result'] is Map<String, dynamic>) {
        try {
          return DeCuong.fromJson(Map<String, dynamic>.from(data['result']));
        } catch (e) {
          if (kDebugMode) print('⚠️ Error parsing DeCuong result: $e');
          throw Exception('Lỗi xử lý dữ liệu trả về từ server: $e');
        }
      } else if (data['result'] == null) {
        // server returned success but no result
        if (kDebugMode)
          print('⚠️ nopDeCuong: server returned 200 but result is null');
        return null;
      } else {
        // result present but unexpected type
        if (kDebugMode)
          print(
            '⚠️ nopDeCuong: unexpected result type: ${data['result'].runtimeType}',
          );
        throw Exception('Dữ liệu trả về không đúng định dạng.');
      }
    } else {
      throw Exception('Nộp đề cương thất bại: ${response.body}');
    }
  }
}
