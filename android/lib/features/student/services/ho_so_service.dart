import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/student/models/student_profile.dart';

/// Service xử lý API calls cho Hồ sơ sinh viên
///
/// Refactored để support:
/// - Instance-based với dependency injection
/// - Better error handling với ErrorCode
/// - File upload support (avatar, CV)
class HoSoService {
  final Dio _dio;
  final http.Client _httpClient;
  final Future<String?> Function() _tokenProvider;

  HoSoService({
    Dio? dio,
    http.Client? httpClient,
    required Future<String?> Function() tokenProvider,
  }) : _dio = dio ?? _createDefaultDio(),
       _httpClient = httpClient ?? http.Client(),
       _tokenProvider = tokenProvider;

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  static String _getBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080';
    const useEmulator = true;
    return useEmulator ? 'http://10.0.2.2:8080' : 'http://192.168.1.10:8080';
  }

  Future<String?> _getToken() async {
    try {
      return await _tokenProvider();
    } catch (e) {
      if (kDebugMode) print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<String> _requireToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw CustomException(ErrorCode.unauthenticated);
    }
    return token;
  }

  Never _handleHttpError(http.Response response) {
    if (kDebugMode) {
      print('❌ HTTP Error: ${response.statusCode}');
      print('   Body: ${response.body}');
    }

    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        final errorCode = ErrorCode.fromResponse(errorData);
        throw CustomException(errorCode);
      }
    } catch (e) {
      if (e is CustomException) rethrow;
    }

    // Default error based on status code
    if (response.statusCode == 401) {
      throw CustomException(ErrorCode.unauthenticated);
    }
    if (response.statusCode == 403) {
      throw CustomException(ErrorCode.forbidden);
    }
    if (response.statusCode == 404) {
      throw CustomException(ErrorCode.sinhVienNotFound);
    }

    throw CustomException(ErrorCode.internalServerError);
  }

  Never _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401) throw CustomException(ErrorCode.unauthenticated);
    if (statusCode == 403) throw CustomException(ErrorCode.forbidden);
    if (statusCode == 404) throw CustomException(ErrorCode.sinhVienNotFound);

    if (e.response?.data is Map<String, dynamic>) {
      try {
        final errorCode = ErrorCode.fromResponse(e.response!.data);
        throw CustomException(errorCode);
      } catch (_) {}
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw CustomException(ErrorCode.timeout);
    }

    throw CustomException(ErrorCode.internalServerError);
  }

  /// Fetch student profile by ID
  Future<StudentProfile> fetchById({required int id}) async {
    final token = await _requireToken();

    try {
      final uri = Uri.parse('${_getBaseUrl()}/api/sinh-vien/by-id/$id');

      if (kDebugMode) {
        print('📨 HoSoService: GET $uri');
      }

      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('✅ HoSoService: Response ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return _parseProfileResponse(response.body);
      } else {
        _handleHttpError(response);
      }
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ fetchById error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  StudentProfile _parseProfileResponse(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final result = map['result'];

      if (result is Map<String, dynamic>) {
        return StudentProfile.fromJson(result);
      }

      throw CustomException(ErrorCode.invalidResponse);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ Parse error: $e');
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  /// Upload avatar
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = await _requireToken();

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      if (kDebugMode) {
        print('📨 HoSoService: POST /api/auth/update-avt');
        print('   File: $filename (${bytes.length} bytes)');
      }

      final response = await _dio.post(
        '/api/auth/update-avt',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (kDebugMode) {
        print('✅ HoSoService: Avatar uploaded');
      }

      return _parseUploadResponse(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ uploadAvatar error: $e');
      throw CustomException(ErrorCode.uploadFileFailed);
    }
  }

  /// Upload CV
  Future<String> uploadCv({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = await _requireToken();

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      if (kDebugMode) {
        print('📨 HoSoService: POST /api/sinh-vien/upload-cv');
        print('   File: $filename (${bytes.length} bytes)');
      }

      final response = await _dio.post(
        '/api/sinh-vien/upload-cv',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (kDebugMode) {
        print('✅ HoSoService: CV uploaded');
      }

      return _parseUploadResponse(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ uploadCv error: $e');
      throw CustomException(ErrorCode.uploadFileFailed);
    }
  }

  String _parseUploadResponse(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final url = data['result'] ?? data['url'];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      }
      throw CustomException(ErrorCode.invalidResponse);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  void dispose() {
    _dio.close();
    _httpClient.close();
  }
}
