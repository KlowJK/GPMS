// filepath: lib/features/student/services/hoi_dong_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/services/auth_service.dart';
import '../models/hoi_dong_item.dart';

class HoiDongService {
  final Dio _dio;
  HoiDongService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: AuthService.baseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)));

  /// Fetch raw response from endpoint
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
      if (kDebugMode) print('[HoiDongService] DioException: status=$status, message=${e.message}');
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

  /// Higher-level helper: fetch and parse to List<HoiDongItem>
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
        if (result['content'] is List) content = List<dynamic>.from(result['content']);
      } else if (data['content'] is List) {
        content = List<dynamic>.from(data['content']);
      }
    } else if (data is List) {
      content = data;
    }

    if (content == null) return [];

    return content.map((e) => HoiDongItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
