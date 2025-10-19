import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/student/models/student_profile.dart';

class HoSoService {
  HoSoService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    const useEmulator = true;
    return useEmulator ? 'http://10.0.2.2:8080' : 'http://192.168.1.10:8080';
  }

  Uri _byIdUrl(int id) => Uri.parse('$_baseUrl/api/sinh-vien/by-id/$id');

  // -------- GET profile by id --------
  Future<StudentProfile> fetchById({
    required int id,
    String? bearerToken,
  }) async {
    final resp = await http.get(
      _byIdUrl(id),
      headers: {
        'Accept': 'application/json',
        if (bearerToken != null && bearerToken.isNotEmpty)
          'Authorization': 'Bearer $bearerToken',
      },
    );

    if (resp.statusCode != 200) {
      ErrorCode code;
      try {
        code = ErrorCode.fromResponse(jsonDecode(resp.body));
      } catch (_) {
        code = ErrorCode.internalServerError;
      }
      throw CustomException(code);
    }

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final result = (map['result'] as Map?)?.cast<String, dynamic>();
    if (result == null) throw CustomException(ErrorCode.internalServerError);
    return StudentProfile.fromJson(result);
  }

  // -------- POST /api/auth/update-avt --------
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String filename,
    required String bearerToken,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final resp = await _dio.post(
      '$_baseUrl/api/auth/update-avt',
      data: form,
      options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
    );

    final data = resp.data as Map;
    return (data['result'] ?? data['url'] ?? '').toString();
  }

  // -------- POST /api/sinh-vien/upload-cv --------
  Future<String> uploadCv({
    required Uint8List bytes,
    required String filename,
    required String bearerToken,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final resp = await _dio.post(
      '$_baseUrl/api/sinh-vien/upload-cv',
      data: form,
      options: Options(headers: {'Authorization': 'Bearer $bearerToken'}),
    );

    final data = resp.data as Map;
    return (data['result'] ?? data['url'] ?? '').toString();
  }
}
