import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/nhat_ki_tuan.dart';
import 'package:GPMS/features/student/models/danh_sach_nhat_ky.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Service xử lý API calls cho Nhật ký tiến trình
///
/// Refactored để support:
/// - Instance-based với dependency injection
/// - Better error handling với ErrorCode
/// - Upload progress tracking
/// - Retry logic cho file upload
class NhatKyService {
  final Dio _dio;
  final Future<String?> Function() _tokenProvider;

  NhatKyService({Dio? dio, required Future<String?> Function() tokenProvider})
    : _tokenProvider = tokenProvider,
      _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': '*/*'},
      ),
    );
  }

  static String _getBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080';
  }

  Future<String?> _getToken() async {
    try {
      return await _tokenProvider();
    } catch (e) {
      if (kDebugMode) print('❌ Error getting token: $e');
      return null;
    }
  }

  Never _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401) throw CustomException(ErrorCode.unauthenticated);
    if (statusCode == 403) throw CustomException(ErrorCode.forbidden);
    if (statusCode == 404) throw CustomException(ErrorCode.nhatKyNotFound);

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

  Future<String> _requireToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw CustomException(ErrorCode.unauthenticated);
    }
    return token;
  }

  /// Fetch danh sách tuần
  Future<List<TuanItem>> getTuans({bool includeAll = false}) async {
    final token = await _requireToken();

    try {
      final response = await _dio.get(
        '/api/nhat-ky-tien-trinh/tuans',
        queryParameters: {'includeAll': includeAll},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _parseTuansResponse(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  List<TuanItem> _parseTuansResponse(dynamic data) {
    try {
      List<dynamic>? list;
      if (data is Map<String, dynamic>) {
        list = (data['result'] ?? data['data']) as List<dynamic>?;
      } else if (data is List) {
        list = data;
      }

      if (list == null) return [];
      return list.map((e) => TuanItem.fromJson(e)).toList();
    } catch (e) {
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  /// Fetch danh sách nhật ký
  Future<List<DiaryItem>> getDiaries({bool includeAll = false}) async {
    final token = await _requireToken();

    try {
      final response = await _dio.get(
        '/api/nhat-ky-tien-trinh',
        queryParameters: {'includeAll': includeAll},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _parseDiariesResponse(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  List<DiaryItem> _parseDiariesResponse(dynamic data) {
    try {
      List<dynamic>? list;
      if (data is Map<String, dynamic>) {
        list = (data['result'] ?? data['data']) as List<dynamic>?;
      } else if (data is List) {
        list = data;
      }

      if (list == null) return [];
      return list.map((e) => DiaryItem.fromJson(e)).toList();
    } catch (e) {
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  /// Submit diary
  Future<DiaryItem> submitDiary({
    required int deTaiId,
    required int idNhatKy,
    required String noiDung,
    String? filePath,
    void Function(int, int)? onSendProgress,
  }) async {
    final token = await _requireToken();

    // Validate
    if (noiDung.trim().isEmpty) {
      throw CustomException(ErrorCode.noiDungRequired);
    }

    try {
      final formData = await _buildFormData(
        idNhatKy: idNhatKy,
        noiDung: noiDung,
        filePath: filePath,
      );

      Response response;
      try {
        response = await _dio.put(
          '/api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky',
          data: formData,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          onSendProgress: onSendProgress,
        );
      } on DioException catch (inner) {
        // Retry logic for content-size mismatch
        if (_shouldRetryUpload(inner, filePath)) {
          if (kDebugMode) print('🔄 Retrying upload with fresh MultipartFile');
          final retryFormData = await _buildFormData(
            idNhatKy: idNhatKy,
            noiDung: noiDung,
            filePath: filePath,
          );
          response = await _dio.put(
            '/api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky',
            data: retryFormData,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
            onSendProgress: onSendProgress,
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseSubmitResponse(response.data);
      }
      throw CustomException(ErrorCode.uploadFileFailed);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  bool _shouldRetryUpload(DioException e, String? filePath) {
    if (filePath == null) return false;
    final msg = e.message?.toString() ?? '';
    return msg.contains('Content size below');
  }

  Future<FormData> _buildFormData({
    required int idNhatKy,
    required String noiDung,
    String? filePath,
  }) async {
    final map = <String, dynamic>{'idNhatKy': idNhatKy, 'noiDung': noiDung};

    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        map['duongDanFile'] = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      }
    }

    return FormData.fromMap(map);
  }

  DiaryItem _parseSubmitResponse(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final result = data['result'];
        if (result is Map<String, dynamic>) {
          return DiaryItem.fromJson(result);
        }
        // Direct response
        return DiaryItem.fromJson(data);
      }
      throw CustomException(ErrorCode.invalidResponse);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  void dispose() => _dio.close();
}
