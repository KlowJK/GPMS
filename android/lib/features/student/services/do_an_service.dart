import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:GPMS/features/student/models/de_cuong.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/de_tai_detail.dart';
import 'package:GPMS/features/student/models/giang_vien_huong_dan.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Service xử lý API calls cho Đồ án (Student)
///
/// Refactored để support:
/// - Instance-based (not static)
/// - Dependency injection (testable)
/// - Better error handling với ErrorCode
/// - Token management
class DoAnService {
  final http.Client _client;
  final Future<String?> Function() _tokenProvider;

  /// Constructor với dependency injection
  ///
  /// [client] - HTTP client (có thể mock cho testing)
  /// [tokenProvider] - Function để lấy token (có thể mock)
  DoAnService({http.Client? client, Future<String?> Function()? tokenProvider})
    : _client = client ?? http.Client(),
      _tokenProvider = tokenProvider ?? _defaultTokenProvider;

  /// Default token provider (có thể override)
  static Future<String?> _defaultTokenProvider() async {
    // Import SharedPreferences ở đây nếu cần
    // Hoặc inject token manager service
    return null; // Placeholder
  }

  /// Base URL configuration
  String get baseUrl {
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

  /// Get auth token
  Future<String?> _getToken() async {
    try {
      final token = await _tokenProvider();
      if (kDebugMode) {
        print('🔍 Getting token:');
        print('   - Token exists: ${token != null}');
        if (token != null && token.isNotEmpty) {
          print(
            '   - Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          );
        }
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting token: $e');
      return null;
    }
  }

  /// Parse error response và throw CustomException
  Never _handleErrorResponse(http.Response response) {
    if (kDebugMode) {
      print('❌ Error Response:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');
    }

    ErrorCode errorCode;
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        errorCode = ErrorCode.fromResponse(errorData);
      } else {
        errorCode = ErrorCode.invalidResponse;
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error parsing response: $e');
      errorCode = ErrorCode.internalServerError;
    }

    throw CustomException(errorCode);
  }

  /// Check token và throw nếu null
  Future<String> _requireToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw CustomException(ErrorCode.unauthenticated);
    }
    return token;
  }

  /// Fetch đề cương logs
  Future<List<DeCuongLog>> fetchDeCuongLogs() async {
    final token = await _requireToken();

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/de-cuong/sinh-vien/log'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('📨 fetchDeCuongLogs - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] is List) {
          final logsJson = data['result'] as List<dynamic>;
          return logsJson
              .map((json) => DeCuongLog.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ fetchDeCuongLogs error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch đề tài chi tiết
  Future<DeTaiDetail?> fetchDeTaiChiTiet() async {
    final token = await _requireToken();

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/de-tai/chi-tiet'),
            headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('📨 fetchDeTaiChiTiet - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          return DeTaiDetail.fromJson(data['result'] as Map<String, dynamic>);
        }
        return null;
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ fetchDeTaiChiTiet error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch danh sách giảng viên hướng dẫn
  Future<List<GiangVienHuongDan>> fetchAdvisors() async {
    final token = await _requireToken();

    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/giang-vien/advisors'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('📨 fetchAdvisors - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] is List) {
          return (data['result'] as List<dynamic>)
              .map((e) => GiangVienHuongDan.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ fetchAdvisors error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Đăng ký đề tài
  Future<DeTaiDetail?> postDangKyDeTai({
    required int gvhdId,
    required String tenDeTai,
    required String filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await _requireToken();

    try {
      final uri = Uri.parse('$baseUrl/api/de-tai/dang-ky');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${token.trim()}'
        ..headers['Accept'] = '*/*'
        ..fields['gvhdId'] = gvhdId.toString()
        ..fields['tenDeTai'] = tenDeTai;

      // Add file based on platform
      if (kIsWeb) {
        if (fileBytes != null && fileName != null) {
          final mimeType = _getMimeType(fileName);
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
          final contentType = _getMediaType(filePath);
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
        print('   - Fields: ${request.fields}');
        print('   - Files: ${request.files.length}');
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📨 postDangKyDeTai - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          return DeTaiDetail.fromJson(data['result'] as Map<String, dynamic>);
        }
        return null;
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ postDangKyDeTai error: $e');
      throw CustomException(ErrorCode.uploadFileFailed);
    }
  }

  /// Nộp đề cương
  Future<DeCuong?> nopDeCuong({required String fileUrl}) async {
    final token = await _requireToken();

    try {
      final uri = Uri.parse('$baseUrl/api/de-cuong/sinh-vien/nop-de-cuong');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${token.trim()}'
        ..fields['fileUrl'] = fileUrl;

      if (kDebugMode) {
        print('🔐 POST $uri');
        print('   - Fields: ${request.fields}');
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📨 nopDeCuong - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result'] is Map<String, dynamic>) {
          return DeCuong.fromJson(data['result'] as Map<String, dynamic>);
        }
        return null;
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ nopDeCuong error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Helper: Get MIME type from filename
  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }

  /// Helper: Get MediaType from file path
  MediaType? _getMediaType(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return MediaType('application', 'pdf');
    }
    if (lower.endsWith('.doc')) {
      return MediaType('application', 'msword');
    }
    if (lower.endsWith('.docx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return null;
  }

  /// Dispose HTTP client
  void dispose() {
    _client.close();
  }
}
