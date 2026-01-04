import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/student/models/de_nghi_hoan_model.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Service xử lý API calls cho Hoãn Đồ Án
///
/// Refactored để support:
/// - Instance-based với dependency injection
/// - Better error handling với ErrorCode
/// - File upload support (mobile + web)
class HoanDoAnService {
  final http.Client _client;
  final Future<String?> Function() _tokenProvider;

  /// Constructor với dependency injection
  HoanDoAnService({
    http.Client? client,
    required Future<String?> Function() tokenProvider,
  }) : _tokenProvider = tokenProvider,
       _client = client ?? http.Client();

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

  static const _timeout = Duration(seconds: 20);

  /// Get auth token
  Future<String?> _getToken() async {
    try {
      final token = await _tokenProvider();
      if (kDebugMode) {
        print('🔍 HoanDoAnService: Getting token');
        print('   - Token exists: ${token != null}');
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting token: $e');
      return null;
    }
  }

  /// Check token và throw nếu null
  Future<String> _requireToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw CustomException(ErrorCode.unauthenticated);
    }
    return token;
  }

  /// Handle HTTP error response
  Never _handleErrorResponse(http.Response response) {
    if (kDebugMode) {
      print('❌ Error Response:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');
    }

    final statusCode = response.statusCode;

    // Handle specific status codes
    if (statusCode == 401) {
      throw CustomException(ErrorCode.unauthenticated);
    }

    if (statusCode == 403) {
      throw CustomException(ErrorCode.forbidden);
    }

    if (statusCode == 404) {
      throw CustomException(ErrorCode.deTaiNotFound);
    }

    // Try to parse error from response body
    try {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      if (errorData is Map<String, dynamic>) {
        final errorCode = ErrorCode.fromResponse(errorData);
        throw CustomException(errorCode);
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error parsing response: $e');
    }

    // Generic error
    throw CustomException(ErrorCode.internalServerError);
  }

  /// Get danh sách đề nghị hoãn
  Future<List<DeNghiHoanModel>> getDanhSachDeNghi() async {
    final token = await _requireToken();

    try {
      final uri = Uri.parse(
        '$baseUrl/api/de-tai/danh-sach-sinh-vien/hoan-do-an',
      );

      if (kDebugMode) {
        print('📨 HoanDoAnService: GET $uri');
      }

      final response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('✅ HoanDoAnService: Response status ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseDanhSachResponse(response);
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ getDanhSachDeNghi error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Parse danh sách response
  List<DeNghiHoanModel> _parseDanhSachResponse(http.Response response) {
    try {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (responseData is! Map<String, dynamic>) {
        throw CustomException(ErrorCode.invalidResponse);
      }

      // Try to get content from nested structure
      List<dynamic>? content;

      if (responseData.containsKey('result') &&
          responseData['result'] is Map<String, dynamic>) {
        final result = responseData['result'] as Map<String, dynamic>;
        if (result.containsKey('content') && result['content'] is List) {
          content = result['content'] as List<dynamic>;
        }
      } else if (responseData.containsKey('result') &&
          responseData['result'] is List) {
        content = responseData['result'] as List<dynamic>;
      } else if (responseData.containsKey('content') &&
          responseData['content'] is List) {
        content = responseData['content'] as List<dynamic>;
      }

      if (content == null) {
        if (kDebugMode) {
          print('⚠️ Cannot find content in response: $responseData');
        }
        return [];
      }

      return content
          .map((json) => DeNghiHoanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) {
        print('❌ Error parsing response: $e');
      }
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  /// Gửi đề nghị hoãn đồ án
  ///
  /// [lyDo] - Lý do hoãn
  /// [filePath] - Đường dẫn file minh chứng (mobile)
  /// [fileBytes] - File bytes (web)
  /// [fileName] - Tên file
  Future<DeNghiHoanModel> guiDeNghiHoan({
    required String lyDo,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await _requireToken();

    // Validate input
    if (lyDo.trim().isEmpty) {
      throw CustomException(ErrorCode.lyDoHoanRequired);
    }

    try {
      final uri = Uri.parse('$baseUrl/api/de-tai/sinh-vien/hoan-do-an');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add fields
      request.fields['lyDo'] = lyDo;

      // Add file if provided
      if (fileName != null) {
        if (kIsWeb && fileBytes != null) {
          // Web platform
          request.files.add(
            http.MultipartFile.fromBytes(
              'minhChungFile',
              fileBytes,
              filename: fileName,
            ),
          );
        } else if (!kIsWeb && filePath != null) {
          // Mobile platform
          request.files.add(
            await http.MultipartFile.fromPath(
              'minhChungFile',
              filePath,
              filename: fileName,
            ),
          );
        }
      }

      if (kDebugMode) {
        print('📨 HoanDoAnService: POST $uri');
        print('   - Fields: ${request.fields}');
        print('   - Files: ${request.files.map((e) => e.filename).toList()}');
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('✅ HoanDoAnService: Response status ${response.statusCode}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseGuiDeNghiResponse(response);
      } else {
        _handleErrorResponse(response);
      }
    } on TimeoutException {
      throw CustomException(ErrorCode.timeout);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ guiDeNghiHoan error: $e');

      // Check for specific file upload errors
      if (e.toString().contains('file')) {
        throw CustomException(ErrorCode.donHoanFileUploadFailed);
      }

      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Parse gửi đề nghị response
  DeNghiHoanModel _parseGuiDeNghiResponse(http.Response response) {
    try {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (responseData is! Map<String, dynamic>) {
        throw CustomException(ErrorCode.invalidResponse);
      }

      if (responseData.containsKey('result')) {
        return DeNghiHoanModel.fromJson(
          responseData['result'] as Map<String, dynamic>,
        );
      } else {
        if (kDebugMode) {
          print('⚠️ Response does not contain "result" field: $responseData');
        }
        throw CustomException(ErrorCode.invalidResponse);
      }
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) {
        print('❌ Error parsing response: $e');
      }
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  /// Dispose HTTP client
  void dispose() {
    _client.close();
  }
}
