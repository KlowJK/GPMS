import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/report_item.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Service xử lý API calls cho Báo cáo
///
/// Refactored để support:
/// - Instance-based với dependency injection
/// - Better error handling với ErrorCode
/// - Upload progress tracking
/// - Dio-based với proper configuration
class BaoCaoService {
  final Dio _dio;
  final Future<String?> Function() _tokenProvider;

  /// Constructor với dependency injection
  BaoCaoService({Dio? dio, required Future<String?> Function() tokenProvider})
    : _tokenProvider = tokenProvider,
      _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
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
    if (statusCode == 404) throw CustomException(ErrorCode.baoCaoNotFound);

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

  Future<List<ReportItem>> fetchReports() async {
    final token = await _requireToken();

    try {
      final response = await _dio.get(
        '/api/bao-cao/list-bao-cao',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseReportsResponse(response.data);
      }
      throw CustomException(ErrorCode.internalServerError);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  List<ReportItem> _parseReportsResponse(dynamic data) {
    try {
      List<dynamic>? list;
      if (data is Map<String, dynamic>) {
        list = (data['result'] ?? data['data']) as List<dynamic>?;
      } else if (data is List) {
        list = data;
      }

      if (list == null) return [];
      return list.map((item) => ReportItem.fromJson(item)).toList();
    } catch (e) {
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  Future<SubmittedReportRaw?> submitReport({
    required int version,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    void Function(int, int)? onSendProgress,
  }) async {
    final token = await _requireToken();

    if ((filePath == null || filePath.isEmpty) &&
        (fileBytes == null || fileName == null)) {
      throw CustomException(ErrorCode.fileEmpty);
    }

    try {
      final formData = await _buildFormData(
        version: version,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      final response = await _dio.post(
        '/api/bao-cao/nop-bao-cao',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        onSendProgress: onSendProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseSubmitResponse(response.data);
      }
      throw CustomException(ErrorCode.uploadFileFailed);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      throw CustomException(ErrorCode.uploadFileFailed);
    }
  }

  Future<FormData> _buildFormData({
    required int version,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final map = <String, dynamic>{'phienBan': version.toString()};

    if (filePath != null && filePath.isNotEmpty) {
      final name = fileName ?? filePath.split(RegExp(r"[\\/]")).last;
      map['duongDanFile'] = await MultipartFile.fromFile(
        filePath,
        filename: name,
      );
    } else if (fileBytes != null && fileName != null) {
      map['duongDanFile'] = MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      );
    }

    return FormData.fromMap(map);
  }

  SubmittedReportRaw? _parseSubmitResponse(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final result = data['result'] ?? data;
        if (result is Map<String, dynamic>) {
          return SubmittedReportRaw.fromJson(result);
        }
      }
      return null;
    } catch (e) {
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  void dispose() => _dio.close();
}
