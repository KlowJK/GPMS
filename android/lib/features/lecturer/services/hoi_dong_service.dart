// filepath: lib/features/student/services/hoi_dong_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/services/auth_service.dart';
import '../models/hoi_dong_item.dart';

class HoiDongService {
  // ========= Aliases (dùng trong UI) =========

  /// Lấy DS hội đồng theo giảng viên qua endpoint /api/hoi-dong/list.
  /// Nếu không truyền [teacherId] sẽ suy ra từ tài khoản hiện tại.
  static Future<List<HoiDongItem>> listByLecturer({
    String? keyword,
    int? teacherId,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final inferredTeacherId =
        teacherId ?? (await AuthService.getCurrentUser())?.teacherId;

    if (inferredTeacherId == null) {
      throw Exception('Không tìm thấy id giảng viên. Vui lòng đăng nhập lại.');
    }

    return HoiDongService().getHoiDongItemsViaListEndpoint(
      idGiangVien: inferredTeacherId,
      keyword: keyword,
      page: page,
      size: size,
      sort: sort,
    );
  }

  /// Lấy DS theo đề tài (giữ nguyên endpoint chung /api/hoi-dong nếu cần).
  static Future<List<HoiDongItem>> listByTopic({
    required int topicId,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) {
    return HoiDongService().getHoiDongItems(
      idDeTai: topicId,
      page: page,
      size: size,
      sort: sort,
    );
  }

  /// Lấy tất cả (hoặc theo keyword) – endpoint chung /api/hoi-dong.
  static Future<List<HoiDongItem>> listAll({
    String? keyword,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) {
    return HoiDongService().getHoiDongItems(
      keyword: keyword,
      page: page,
      size: size,
      sort: sort,
    );
  }

  // ========= Instance =========

  final Dio _dio;
  HoiDongService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: AuthService.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  // ---------- COMMON HELPERS ----------
  Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    final headers = <String, String>{'accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is Map && data['result'] is List) {
      return List<dynamic>.from(data['result'] as List);
    }
    if (data is Map && data['content'] is List) {
      return List<dynamic>.from(data['content'] as List);
    }
    if (data is List) return data;
    return const [];
  }

  // ---------- ENDPOINT: /api/hoi-dong (giữ để dùng chung khi cần) ----------
  Future<Response> fetchHoiDong({
    String? keyword,
    int? idDeTai,
    int? idGiangVien,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final headers = await _headers();

    final queryParams = <String, dynamic>{
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (idDeTai != null) 'idDeTai': idDeTai,
      if (idGiangVien != null) 'idGiangVien': idGiangVien,
      'page': page,
      'size': size,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };

    try {
      if (kDebugMode) {
        print('[HoiDongService] GET /api/hoi-dong -> $queryParams');
      }
      return await _dio.get(
        '/api/hoi-dong',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (kDebugMode) {
        print('[HoiDongService] DioException: status=$status, message=${e.message}');
      }
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi tải hội đồng: $msg');
    } catch (e) {
      if (kDebugMode) print('[HoiDongService] Unexpected error: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Parse cho endpoint chung /api/hoi-dong
  Future<List<HoiDongItem>> getHoiDongItems({
    String? keyword,
    int? idDeTai,
    int? idGiangVien,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final resp = await fetchHoiDong(
      keyword: keyword,
      idDeTai: idDeTai,
      idGiangVien: idGiangVien,
      page: page,
      size: size,
      sort: sort,
    );
    final arr = _extractList(resp.data);
    return arr
        .whereType<Map>()
        .map((e) => HoiDongItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ---------- ENDPOINT MỚI: /api/hoi-dong/list ----------
  /// Lấy danh sách hội đồng theo **id giảng viên** (endpoint theo yêu cầu).
  Future<List<HoiDongItem>> getHoiDongItemsViaListEndpoint({
    required int idGiangVien,
    String? keyword,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final headers = await _headers();

    final queryParams = <String, dynamic>{
      'idGiangVien': idGiangVien,
      'page': page,
      'size': size,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };

    try {
      if (kDebugMode) {
        print('[HoiDongService] GET /api/hoi-dong/list -> $queryParams');
      }
      final resp = await _dio.get(
        '/api/hoi-dong/list',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      final arr = _extractList(resp.data);
      return arr
          .whereType<Map>()
          .map((e) => HoiDongItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (kDebugMode) {
        print('[HoiDongService] DioException(/list): status=$status, message=${e.message}');
      }
      if (status == 401) throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi tải danh sách hội đồng: $msg');
    } catch (e) {
      if (kDebugMode) print('[HoiDongService] Unexpected error(/list): $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
