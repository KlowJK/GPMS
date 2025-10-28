// dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/models/tuan.dart';
import 'package:GPMS/features/auth/services/auth_service.dart';

/// Service gọi API Nhật ký tiến trình (giảng viên)
class TienDoService {
  // -------------------------- BASE URL --------------------------------------
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    const useEmulator = true;
    if (useEmulator) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://192.168.1.10:8080';
    }
  }

  final http.Client _client;
  String? _authToken;

  /// You can still optionally set a token manually, otherwise the service will
  /// call `AuthService.getToken()` for each request.
  TienDoService({http.Client? client, String? authToken})
    : _client = client ?? http.Client(),
      _authToken = authToken;

  void setAuthToken(String? token) => _authToken = token;

  Future<List<TienDoSinhVien>> fetchAllNhatKy({int? tuan}) async {
    final uri = Uri.parse(
      '$baseUrl/api/nhat-ky-tien-trinh/all-nhat-ky/list',
    ).replace(queryParameters: _cleanParams({'tuan': tuan?.toString()}));

    final headers = await _headersGet();
    final res = await _client.get(uri, headers: headers);
    _ensureSuccess(res);

    final list = _extractList(_safeDecode(res.body));
    return TienDoSinhVien.listFromJson(list);
  }

  Future<List<TienDoSinhVien>> fetchNhatKyByIdList({int? id}) async {
    final uri = Uri.parse('$baseUrl/api/nhat-ky-tien-trinh/$id');

    final headers = await _headersGet();
    final res = await _client.get(uri, headers: headers);
    _ensureSuccess(res);

    final decoded = _safeDecode(res.body);

    List<dynamic> rawList = <dynamic>[];
    if (decoded is Map && decoded['result'] is List) {
      debugPrint(res.body);
      rawList = List<dynamic>.from(decoded['result'] as List);
    } else if (decoded is List) {
      rawList = List<dynamic>.from(decoded);
    } else if (decoded is Map) {
      // single object -> wrap into a list
      rawList = <dynamic>[decoded];
    }

    return TienDoSinhVien.listFromJson(rawList);
  }

  Future<List<TienDoSinhVien>> fetchMySupervisedStudents({
    String? status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/nhat-ky-tien-trinh/my-supervised-students/list',
    ).replace(queryParameters: _cleanParams({'status': status}));

    final headers = await _headersGet();
    final res = await _client.get(uri, headers: headers);
    _ensureSuccess(res);

    final list = _extractList(_safeDecode(res.body));
    return TienDoSinhVien.listFromJson(list);
  }

  Future<List<Tuan>> fetchTuansByLecturer({bool includeAll = false}) async {
    final uri = Uri.parse(
      '$baseUrl/api/nhat-ky-tien-trinh/tuans-by-lecturer',
    ).replace(queryParameters: {'includeAll': includeAll.toString()});

    final headers = await _headersGet();
    final res = await _client.get(uri, headers: headers);

    _ensureSuccess(res);

    final decoded = _safeDecode(res.body);
    final list = _extractList(decoded); // <-- bóc result đúng chuẩn
    return Tuan.listFromJson(list);
  }

  Future<void> approveReport({required int id, required String nhanXet}) async {
    final uri = Uri.parse('$baseUrl/api/nhat-ky-tien-trinh/$id/duyet');
    final body = jsonEncode({'id': id, 'nhanXet': nhanXet});

    final headers = await _headersJson();
    final res = await _client.put(uri, headers: headers, body: body);
    _ensureSuccess(res);
  }

  // -------------------------- HELPERS ---------------------------------------

  Future<String?> _resolveToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    try {
      final token = await AuthService.getToken();
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _headersGet() async {
    final out = <String, String>{'Accept': 'application/json'};
    final token = await _resolveToken();
    if (token != null && token.isNotEmpty) {
      out['Authorization'] = 'Bearer $token';
    }
    return out;
  }

  Future<Map<String, String>> _headersJson() async {
    final out = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await _resolveToken();
    if (token != null && token.isNotEmpty) {
      out['Authorization'] = 'Bearer $token';
    }
    return out;
  }

  Map<String, String>? _cleanParams(Map<String, String?> params) {
    final out = <String, String>{};
    params.forEach((k, v) {
      if (v != null && v.isNotEmpty) out[k] = v;
    });
    return out.isEmpty ? null : out;
  }

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'HTTP ${res.statusCode} ${res.reasonPhrase ?? ''}'.trim();
      final decoded = _safeDecode(res.body);
      if (decoded is Map && decoded['message'] != null) {
        msg = decoded['message'].toString();
      }
      throw http.ClientException(msg, res.request?.url);
    }
  }

  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is Map && decoded['result'] is List) {
      return List<dynamic>.from(decoded['result'] as List);
    }
    if (decoded is List) {
      return List<dynamic>.from(decoded);
    }
    return <dynamic>[];
  }

  void dispose() => _client.close();
}
