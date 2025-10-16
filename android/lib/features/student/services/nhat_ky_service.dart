// Service để gọi GET /api/nhat-ky-tien-trinh/tuans
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/services/auth_service.dart';
import '../models/nhat_ki_tuan.dart';
import '../models/danh_sach_nhat_ky.dart';

class NhatKyService {
  final Dio _dio;
  NhatKyService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: AuthService.baseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)));

  Future<Response> fetchTuansRaw({bool includeAll = false}) async {
    final token = await AuthService.getToken();
    final headers = <String, String>{'accept': '*/*'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final queryParams = <String, dynamic>{'includeAll': includeAll};

    try {
      if (kDebugMode) {
        print('[NhatKyService] GET /api/nhat-ky-tien-trinh/tuans -> params: $queryParams');
        print('[NhatKyService] headers: $headers');
      }
      final resp = await _dio.get(
        '/api/nhat-ky-tien-trinh/tuans',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return resp;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (kDebugMode) print('[NhatKyService] DioException: status=$status, message=${e.message}');
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi tải tuần: $msg');
    } catch (e) {
      if (kDebugMode) print('[NhatKyService] Unexpected error: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<List<TuanItem>> getTuans({bool includeAll = false}) async {
    final resp = await fetchTuansRaw(includeAll: includeAll);
    final data = resp.data;

    // The API in screenshots returns { "result": [ {..}, ... ], ... }
    List<dynamic>? list;
    if (data is Map<String, dynamic>) {
      if (data['result'] is List) list = List<dynamic>.from(data['result']);
      else if (data['data'] is List) list = List<dynamic>.from(data['data']);
    } else if (data is List) {
      list = data;
    }

    if (list == null) return [];

    return list.map((e) => TuanItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Fetch raw response for diaries
  Future<Response> fetchDiariesRaw({bool includeAll = false}) async {
    final token = await AuthService.getToken();
    final headers = <String, String>{'accept': '*/*'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final queryParams = <String, dynamic>{'includeAll': includeAll};

    try {
      if (kDebugMode) {
        print('[NhatKyService] GET /api/nhat-ky-tien-trinh -> params: $queryParams');
        print('[NhatKyService] headers: $headers');
      }
      final resp = await _dio.get(
        '/api/nhat-ky-tien-trinh',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return resp;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (kDebugMode) print('[NhatKyService] DioException (diaries): status=$status, message=${e.message}');
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi tải nhật ký: $msg');
    } catch (e) {
      if (kDebugMode) print('[NhatKyService] Unexpected error (diaries): $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Higher-level: parse diaries into List<DiaryItem>
  Future<List<DiaryItem>> getDiaries({bool includeAll = false}) async {
    final resp = await fetchDiariesRaw(includeAll: includeAll);
    final data = resp.data;

    List<dynamic>? list;
    if (data is Map<String, dynamic>) {
      if (data['result'] is List) list = List<dynamic>.from(data['result']);
      else if (data['data'] is List) list = List<dynamic>.from(data['data']);
    } else if (data is List) {
      list = data;
    }

    if (list == null) return [];

    return list.map((e) => DiaryItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Submit diary using multipart/form-data (PUT)
  /// Endpoint: PUT /api/nhat-ky-tien-trinh/{deTaiId}/nop-nhat-ky
  Future<DiaryItem> submitDiary({required int deTaiId, required int idNhatKy, required String noiDung, String? filePath, void Function(int, int)? onSendProgress}) async {
    final token = await AuthService.getToken();
    // Ensure token exists — if not, return a clear error so UI can prompt login
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('[NhatKyService] submitDiary: No auth token found in storage');
      throw Exception('UNAUTHORIZED: Không tìm thấy token. Vui lòng đăng nhập lại.');
    }
    final headers = <String, String>{'accept': '*/*', 'Authorization': 'Bearer $token'};

    try {
      final map = <String, dynamic>{
        // send id as int (server may accept int)
        'idNhatKy': idNhatKy,
        'noiDung': noiDung,
      };

      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          final mp = await MultipartFile.fromFile(file.path, filename: fileName);
          // Use single field 'duongDanFile' to avoid duplicating the same MultipartFile instance
          map['duongDanFile'] = mp;
        }
      }

      final formData = FormData.fromMap(map);

      if (kDebugMode) {
        print('[NhatKyService] PUT /api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky -> headers: $headers');
        print('[NhatKyService] form keys: ${formData.fields.map((e) => e.key).toList()}');
        try {
          print('[NhatKyService] form files: ${formData.files.map((e) => e.key).toList()}');
        } catch (_) {}
        // log file details if present
        if (filePath != null && filePath.isNotEmpty) {
          try {
            final f = File(filePath);
            if (f.existsSync()) {
              print('[NhatKyService] Uploading file: ${f.path} (${f.lengthSync()} bytes)');
            }
          } catch (e) {
            print('[NhatKyService] Could not read file info: $e');
          }
        }
      }

      Response resp;
      try {
        resp = await _dio.put('/api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky', data: formData, options: Options(headers: headers), onSendProgress: onSendProgress);
      } on DioException catch (inner) {
        // Special-case: some servers may complain 'Content size below specified contentLength'.
        // Retry once by recreating the MultipartFile to ensure a fresh stream.
        final msg = inner.message?.toString() ?? inner.toString();
        if (filePath != null && msg.contains('Content size below')) {
          if (kDebugMode) print('[NhatKyService] Detected content-size mismatch; retrying upload with fresh MultipartFile');
          // recreate form data
          final retryMap = <String, dynamic>{
            'idNhatKy': idNhatKy,
            'noiDung': noiDung,
          };
          final file = File(filePath);
          if (await file.exists()) {
            final fileName = file.path.split(Platform.pathSeparator).last;
            final fresh = await MultipartFile.fromFile(file.path, filename: fileName);
            retryMap['duongDanFile'] = fresh;
          }
          final retryForm = FormData.fromMap(retryMap);
          // attempt the retry
          resp = await _dio.put('/api/nhat-ky-tien-trinh/$deTaiId/nop-nhat-ky', data: retryForm, options: Options(headers: headers), onSendProgress: onSendProgress);
        } else {
          rethrow;
        }
      }

      if (kDebugMode) {
        print('[NhatKyService] submitDiary response status: ${resp.statusCode}');
        print('[NhatKyService] submitDiary response data: ${resp.data}');
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        if (kDebugMode) print('[NhatKyService] submitDiary success data: $data');
        if (data is Map<String, dynamic>) {
          final res = data['result'];
          if (res is Map<String, dynamic>) {
            return DiaryItem.fromJson(Map<String, dynamic>.from(res));
          }
        }
        // Try to handle when API returns the created object directly
        if (data is Map<String, dynamic>) {
          return DiaryItem.fromJson(Map<String, dynamic>.from(data));
        }
        final bodyStr = resp.data != null ? resp.data.toString() : '<empty body>';
        throw Exception('Invalid response format when submitting diary. status=${resp.statusCode}, body=$bodyStr');
      } else {
        final bodyStr = resp.data != null ? resp.data.toString() : '<empty body>';
        final statusMsg = resp.statusMessage ?? '';
        if (kDebugMode) print('[NhatKyService] submitDiary non-200: ${resp.statusCode}, statusMessage: $statusMsg, data: ${resp.data}');
        throw Exception('Server returned status=${resp.statusCode} ${statusMsg.isNotEmpty ? "($statusMsg)" : ''}, body=$bodyStr');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final statusMsg = e.response?.statusMessage;
      final respData = e.response?.data;
      String bodyStr;
      try {
        bodyStr = respData != null ? respData.toString() : '<empty body>';
      } catch (_) {
        bodyStr = '<unprintable body>';
      }
      if (kDebugMode) print('[NhatKyService] DioException (submitDiary): status=$status, statusMessage=$statusMsg, message=${e.message}, data=$bodyStr, error=${e.error}');
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final msgParts = <String>[];
      if (status != null) msgParts.add('status=$status');
      if (statusMsg != null && statusMsg.isNotEmpty) msgParts.add('statusMessage=$statusMsg');
      if (bodyStr.isNotEmpty) msgParts.add('body=$bodyStr');
      if (e.message != null && e.message.toString().isNotEmpty) msgParts.add('message=${e.message}');
      if (e.error != null) msgParts.add('error=${e.error}');
      final combined = msgParts.isNotEmpty ? msgParts.join(' | ') : 'Unknown DioException: ${e.toString()}';
      throw Exception('Lỗi khi nộp nhật ký: $combined');
    } catch (e) {
      if (kDebugMode) print('[NhatKyService] Unexpected error (submitDiary): $e');
      throw Exception('Lỗi không xác định khi nộp nhật ký: ${e.toString()}');
    }
  }
}
