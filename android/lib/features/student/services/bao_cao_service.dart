import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/services/auth_service.dart';
import '../models/report_item.dart';

class BaoCaoService {
  final String baseUrl;
  final Dio _dio;

  BaoCaoService({required this.baseUrl})
      : _dio = Dio(BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20)));

  Future<List<ReportItem>> fetchReports() async {
    final token = await AuthService.getToken();
    final headers = <String, String>{'accept': '*/*'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kDebugMode) {
        print('[BaoCaoService] GET $baseUrl/api/bao-cao/list-bao-cao');
      }
      final resp = await _dio.get('/api/bao-cao/list-bao-cao',
          options: Options(headers: headers));
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        List<dynamic>? list;
        if (data is Map<String, dynamic>) {
          if (data['result'] is List) {
            list = List<dynamic>.from(data['result']);
          } else if (data['data'] is List) {
            list = List<dynamic>.from(data['data']);
          }
        } else if (data is List) {
          list = data;
        }
        if (list == null) return [];
        return list
            .map((e) => ReportItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        throw Exception(
            'Lỗi khi tải danh sách báo cáo: status=${resp.statusCode}');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi tải danh sách báo cáo: $msg');
    } catch (e) {
      if (kDebugMode) print('[BaoCaoService] Unexpected error: $e');
      throw Exception('Lỗi không xác định khi tải báo cáo: $e');
    }
  }

  Future<SubmittedReportRaw?> submitReport({
    required int version,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    void Function(int, int)? onSendProgress,
  }) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('UNAUTHORIZED: Không tìm thấy token. Vui lòng đăng nhập lại.');
    }

    final headers = <String, String>{
      'accept': '*/*',
      'Authorization': 'Bearer $token'
    };

    try {
      final map = <String, dynamic>{'phienBan': version.toString()};

      if (filePath != null && filePath.isNotEmpty) {
        final mp = await MultipartFile.fromFile(filePath,
            filename: fileName ?? filePath.split(RegExp(r"[\\/]")).last);
        map['duongDanFile'] = mp;
      } else if (fileBytes != null && fileName != null) {
        map['duongDanFile'] =
            MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else {
        throw Exception("No file provided to submitReport");
      }

      final form = FormData.fromMap(map);

      if (kDebugMode) {
        print('[BaoCaoService] POST /api/bao-cao/nop-bao-cao');
        print('  - fields: ${form.fields}');
        print('  - files: ${form.files.map((e) => e.key).toList()}');
      }

      final resp = await _dio.post('/api/bao-cao/nop-bao-cao',
          data: form,
          options: Options(headers: headers),
          onSendProgress: onSendProgress);

      if (kDebugMode) {
        print(
            '[BaoCaoService] submit response status: ${resp.statusCode} data: ${resp.data}');
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        if (data is Map<String, dynamic>) {
          final res = data['result'] ?? data;
          if (res is Map<String, dynamic>) {
            return SubmittedReportRaw.fromJson(res);
          }
        }
        return null;
      } else {
        final body = resp.data != null ? resp.data.toString() : '<empty body>';
        throw Exception(
            'Lỗi khi nộp báo cáo: status=${resp.statusCode}, body=$body');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final body = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi nộp báo cáo: $body');
    } catch (e) {
      if (kDebugMode) print('[BaoCaoService] Unexpected submit error: $e');
      throw Exception('Lỗi không xác định khi nộp báo cáo: $e');
    }
  }
}
