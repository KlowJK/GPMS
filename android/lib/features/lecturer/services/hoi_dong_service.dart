import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_item.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_detail.dart';

class HoiDongService {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  HoiDongService({required this.baseUrl, required this.tokenProvider});

  /// Get headers with Bearer token
  Future<Map<String, String>> _headers() async {
    final token = await tokenProvider();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Extract list from various response formats
  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      if (m['result'] is List) return _extractList(m['result']);
      if (m['content'] is List) return _extractList(m['content']);
      return [m]; // Single object wrapped in list
    }

    return [];
  }

  /// Fetch danh sách hội đồng theo giảng viên
  ///
  /// GET /api/hoi-dong/list?idGiangVien=...
  Future<List<HoiDongItem>> fetchByLecturer({
    required int idGiangVien,
    String? keyword,
    int page = 0,
    int size = 1000,
    List<String>? sort,
  }) async {
    final queryParams = <String, String>{
      'idGiangVien': '$idGiangVien',
      'page': '$page',
      'size': '$size',
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (sort != null && sort.isNotEmpty) 'sort': sort.join(','),
    };

    final uri = Uri.parse(
      '$baseUrl/api/hoi-dong/list',
    ).replace(queryParameters: queryParams);

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);
      final list = _extractList(body);
      return list.map((e) => HoiDongItem.fromJson(e)).toList();
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch danh sách hội đồng theo đề tài
  ///
  /// GET /api/hoi-dong?idDeTai=...
  Future<List<HoiDongItem>> fetchByTopic({
    required int idDeTai,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final queryParams = <String, String>{
      'idDeTai': '$idDeTai',
      'page': '$page',
      'size': '$size',
      if (sort != null && sort.isNotEmpty) 'sort': sort.join(','),
    };

    final uri = Uri.parse(
      '$baseUrl/api/hoi-dong',
    ).replace(queryParameters: queryParams);

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);
      final list = _extractList(body);
      return list.map((e) => HoiDongItem.fromJson(e)).toList();
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch tất cả hội đồng (với keyword filter)
  ///
  /// GET /api/hoi-dong?keyword=...
  Future<List<HoiDongItem>> fetchAll({
    String? keyword,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      'size': '$size',
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (sort != null && sort.isNotEmpty) 'sort': sort.join(','),
    };

    final uri = Uri.parse(
      '$baseUrl/api/hoi-dong',
    ).replace(queryParameters: queryParams);

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);
      final list = _extractList(body);
      return list.map((e) => HoiDongItem.fromJson(e)).toList();
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  Future<HoiDongDetail> fetchDetail({required int hoiDongId}) async {
    final uri = Uri.parse('$baseUrl/api/hoi-dong/$hoiDongId');

    try {
      final headers = await _headers();
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        throw CustomException(ErrorCode.unauthenticated);
      }

      if (res.statusCode == 403) {
        throw CustomException(ErrorCode.forbidden);
      }

      if (res.statusCode == 404) {
        throw CustomException(ErrorCode.notFound);
      }

      if (res.statusCode != 200) {
        try {
          final body = jsonDecode(res.body);
          throw CustomException(ErrorCode.fromResponse(body));
        } catch (e) {
          throw CustomException(ErrorCode.internalServerError);
        }
      }

      final body = jsonDecode(res.body);

      // Extract from result wrapper
      final data = body is Map && body['result'] != null
          ? body['result']
          : body;

      return HoiDongDetail.fromJson(Map<String, dynamic>.from(data as Map));
    } on CustomException {
      rethrow;
    } on http.ClientException {
      throw CustomException(ErrorCode.noInternet);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw CustomException(ErrorCode.timeout);
      }
      throw CustomException(ErrorCode.internalServerError);
    }
  }
}
