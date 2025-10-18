import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/student/models/hoi_dong_item.dart';

class HoiDongService {
  // ===== Aliases / Static helpers (đặt ở đầu class) =====

  /// Lấy DS hội đồng theo giảng viên.
  /// Nếu không truyền [teacherId] sẽ cố gắng suy ra từ AuthService (current user).
  static Future<List<HoiDongItem>> listByLecturer({
    String? keyword,
    int? teacherId,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final inferredTeacherId =
        teacherId ?? (await AuthService.getCurrentUser())?.teacherId;
    return HoiDongService().getHoiDongItems(
      keyword: keyword,
      idGiangVien: inferredTeacherId,
      page: page,
      size: size,
      sort: sort,
    );
  }

  /// Lấy DS hội đồng theo đề tài.
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

  /// Lấy tất cả (hoặc theo keyword).
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

  // ===== Instance section =====

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

  /// Fetch raw response từ endpoint `/api/hoi-dong`
  Future<Response> fetchHoiDong({
    String? keyword,
    int? idDeTai,
    int? idGiangVien,
    int page = 0,
    int size = 10,
    List<String>? sort,
  }) async {
    final token = await AuthService.getToken();
    final headers = <String, String>{'accept': '*/*'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final queryParams = <String, dynamic>{};
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (idDeTai != null) queryParams['idDeTai'] = idDeTai;
    if (idGiangVien != null) queryParams['idGiangVien'] = idGiangVien;
    queryParams['page'] = page;
    queryParams['size'] = size;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

    try {
      if (kDebugMode) {
        print('[HoiDongService] GET /api/hoi-dong -> params: $queryParams');
        print('[HoiDongService] headers: $headers');
      }
      final resp = await _dio.get(
        '/api/hoi-dong',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return resp;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (kDebugMode) {
        print(
            '[HoiDongService] DioException: status=$status, message=${e.message}');
      }
      if (status == 401) {
        throw Exception('UNAUTHORIZED: Bạn cần đăng nhập.');
      }
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Lỗi khi tải hội đồng: $msg');
    } catch (e) {
      if (kDebugMode) print('[HoiDongService] Unexpected error: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Helper parse -> List<HoiDongItem>
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

    final data = resp.data;

    List<dynamic>? content;
    if (data is Map<String, dynamic>) {
      if (data['result'] is Map<String, dynamic>) {
        final result = data['result'] as Map<String, dynamic>;
        if (result['content'] is List) {
          content = List<dynamic>.from(result['content']);
        }
      } else if (data['content'] is List) {
        content = List<dynamic>.from(data['content']);
      }
    } else if (data is List) {
      content = data;
    }

    if (content == null) return [];

    return content
        .map((e) => HoiDongItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
