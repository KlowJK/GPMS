import 'dart:convert';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/lecturer/models/student_supervised.dart';
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/core/exception/error_code.dart';

class BaoCaoService {
  final http.Client _client;
  final String baseUrl;

  /// Default base URL depending on platform / emulator
  static String get defaultBaseUrl {
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

  BaoCaoService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? defaultBaseUrl,
      _client = client ?? http.Client();

  Future<List<StudentSupervised>> fetchSupervisedStudents() async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/api/bao-cao/list-sinh-vien-supervised');

    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await _client.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      _handleErrorResponse(resp);
    }

    final decoded = jsonDecode(resp.body);

    List<dynamic>? items;
    if (decoded is Map && decoded['result'] is List) {
      items = decoded['result'] as List<dynamic>;
    } else if (decoded is List) {
      items = decoded;
    }

    if (items == null) {
      throw CustomException(ErrorCode.fromResponse(jsonDecode(resp.body)));
    }

    return items
        .map((e) => StudentSupervised.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReportSubmission>> fetchList({String? status}) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(
      '$baseUrl/api/bao-cao/list-bao-cao-giang-vien',
    ).replace(queryParameters: status != null ? {'status': status} : null);
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final resp = await _client.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      _handleErrorResponse(resp);
    }
    final decoded = jsonDecode(resp.body);

    List<dynamic>? items;
    if (decoded is Map && decoded['result'] is List) {
      items = decoded['result'] as List<dynamic>;
    } else if (decoded is List) {
      items = decoded;
    }
    if (items == null) {
      throw CustomException(ErrorCode.fromResponse(jsonDecode(resp.body)));
    }
    return items
        .map((e) => ReportSubmission.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReportSubmission>> fetchStudentReports({
    required String maSinhVien,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(
      '$baseUrl/api/bao-cao/list-bao-cao-sinh-vien',
    ).replace(queryParameters: {'maSinhVien': maSinhVien});

    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await _client.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      _handleErrorResponse(resp);
    }

    final decoded = jsonDecode(resp.body);

    List<dynamic>? items;
    if (decoded is Map && decoded['result'] is List) {
      items = decoded['result'] as List<dynamic>;
    } else if (decoded is List) {
      items = decoded;
    }

    if (items == null) {
      throw CustomException(ErrorCode.fromResponse(jsonDecode(resp.body)));
    }

    return items
        .map((e) => ReportSubmission.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> rejectReport({
    required int idBaoCao,
    required String nhanXet,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/api/bao-cao/tu-choi').replace(
      queryParameters: {
        'idBaoCao': '$idBaoCao',
        'nhanXet': nhanXet, // sẽ được URL-encode
      },
    );

    final headers = {
      'Accept': 'application/json',
      if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token',
    };

    final resp = await _client.put(uri, headers: headers);

    if (resp.statusCode != 200) {
      _handleErrorResponse(resp);
    }
  }

  Future<void> approveReport({
    required int idBaoCao,
    required double diemHuongDan,
    String? nhanXet,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/api/bao-cao/duyet').replace(
      queryParameters: {
        'idBaoCao': '$idBaoCao',
        if (diemHuongDan != null) 'diemHuongDan': '$diemHuongDan',
        if (nhanXet != null && nhanXet!.isNotEmpty) 'nhanXet': nhanXet!,
      },
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await _client.put(uri, headers: headers);

    if (resp.statusCode != 200) {
      _handleErrorResponse(resp);
    }
  }

  void _handleErrorResponse(http.Response resp) {
    String? serverMessage;
    try {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        if (decoded['message'] != null)
          serverMessage = decoded['message'].toString();
        // some APIs put payload under 'result' with nested message
        if (serverMessage == null &&
            decoded['result'] is Map &&
            decoded['result']['message'] != null) {
          serverMessage = decoded['result']['message'].toString();
        }
      }
    } catch (_) {
      // ignore parse errors
    }

    final code = _mapStatusToErrorCode(resp.statusCode);
    final message =
        serverMessage ?? '${code.message} (HTTP ${resp.statusCode})';
    throw CustomException(ErrorCode.fromResponse(jsonDecode(resp.body)));
  }

  ErrorCode _mapStatusToErrorCode(int status) {
    if (status == 400) return ErrorCode.unauthenticated;

    return ErrorCode.unauthenticated;
  }

  void dispose() => _client.close();
}
