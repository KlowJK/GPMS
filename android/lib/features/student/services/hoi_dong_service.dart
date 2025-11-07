import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:GPMS/features/student/models/hoi_dong_item.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_detail.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Service xử lý API calls cho Hội đồng (Student)
///
/// Refactored để support:
/// - Pure instance-based (no static methods)
/// - Dependency injection (testable)
/// - Better error handling với ErrorCode
/// - Dio-based với proper configuration
/// - Fetch detail (reuse lecturer models)
class HoiDongService {
  final Dio _dio;
  final Future<String?> Function() _tokenProvider;

  /// Constructor với dependency injection
  ///
  /// [dio] - Dio client (có thể mock cho testing)
  /// [tokenProvider] - Function để lấy token
  HoiDongService({Dio? dio, required Future<String?> Function() tokenProvider})
    : _tokenProvider = tokenProvider,
      _dio = dio ?? _createDefaultDio();

  /// Create default Dio instance
  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      ),
    );
  }

  /// Base URL configuration
  static String _getBaseUrl() {
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

  /// Get auth token
  Future<String?> _getToken() async {
    try {
      final token = await _tokenProvider();
      if (kDebugMode) {
        print('🔍 HoiDongService: Getting token');
        print('   - Token exists: ${token != null}');
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting token: $e');
      return null;
    }
  }

  /// Handle DioException và convert sang CustomException
  Never _handleDioError(DioException e) {
    if (kDebugMode) {
      print('❌ DioException in HoiDongService:');
      print('   - Status: ${e.response?.statusCode}');
      print('   - Message: ${e.message}');
      print('   - Data: ${e.response?.data}');
    }

    final statusCode = e.response?.statusCode;

    // Handle specific status codes
    if (statusCode == 401) {
      throw CustomException(ErrorCode.unauthenticated);
    }

    if (statusCode == 403) {
      throw CustomException(ErrorCode.forbidden);
    }

    if (statusCode == 404) {
      throw CustomException(ErrorCode.hoiDongNotFound);
    }

    // Try to parse error from response body
    if (e.response?.data is Map<String, dynamic>) {
      try {
        final errorCode = ErrorCode.fromResponse(
          e.response!.data as Map<String, dynamic>,
        );
        throw CustomException(errorCode);
      } catch (_) {
        // If parsing fails, use generic error
      }
    }

    // Network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw CustomException(ErrorCode.timeout);
    }

    if (e.type == DioExceptionType.connectionError) {
      throw CustomException(ErrorCode.noInternet);
    }

    // Generic error
    throw CustomException(ErrorCode.internalServerError);
  }

  /// Check token và throw nếu null
  Future<String> _requireToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw CustomException(ErrorCode.unauthenticated);
    }
    return token;
  }

  /// Fetch hội đồng từ API
  ///
  /// [keyword] - Từ khóa tìm kiếm
  /// [idDeTai] - Lọc theo đề tài
  /// [idGiangVien] - Lọc theo giảng viên
  /// [page] - Trang (default: 0)
  /// [size] - Kích thước trang (default: 10)
  /// [sort] - Danh sách điều kiện sort
  Future<List<HoiDongItem>> fetchHoiDong({
    String? keyword,
    int? idDeTai,
    int? idGiangVien,
    int page = 0,
    int size = 100,
    List<String>? sort,
  }) async {
    final token = await _requireToken();

    try {
      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'size': size};

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (idDeTai != null) {
        queryParams['idDeTai'] = idDeTai;
      }
      if (idGiangVien != null) {
        queryParams['idGiangVien'] = idGiangVien;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      if (kDebugMode) {
        print('📨 HoiDongService: GET /api/hoi-dong');
        print('   - Params: $queryParams');
      }

      // Make request
      final response = await _dio.get(
        '/api/hoi-dong',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (kDebugMode) {
        print('✅ HoiDongService: Response status ${response.statusCode}');
      }

      // Parse response
      return _parseHoiDongResponse(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ Unexpected error: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Fetch chi tiết hội đồng theo ID
  ///
  /// GET /api/hoi-dong/{hoiDongId}
  /// Reuses HoiDongDetail model from lecturer package
  Future<HoiDongDetail> fetchDetail({required int hoiDongId}) async {
    final token = await _requireToken();

    try {
      if (kDebugMode) {
        print('📨 HoiDongService: GET /api/hoi-dong/$hoiDongId');
      }

      final response = await _dio.get(
        '/api/hoi-dong/$hoiDongId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (kDebugMode) {
        print(
          '✅ HoiDongService: Detail response status ${response.statusCode}',
        );
      }

      // Parse response - handle result wrapper
      final data = response.data;
      final detailData = data is Map && data['result'] != null
          ? data['result']
          : data;

      return HoiDongDetail.fromJson(
        Map<String, dynamic>.from(detailData as Map),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is CustomException) rethrow;
      if (kDebugMode) print('❌ Unexpected error in fetchDetail: $e');
      throw CustomException(ErrorCode.internalServerError);
    }
  }

  /// Parse response data thành List<HoiDongItem>
  List<HoiDongItem> _parseHoiDongResponse(dynamic data) {
    try {
      List<dynamic>? content;

      // Handle different response structures
      if (data is Map<String, dynamic>) {
        // Structure 1: { result: { content: [...] } }
        if (data['result'] is Map<String, dynamic>) {
          final result = data['result'] as Map<String, dynamic>;
          if (result['content'] is List) {
            content = result['content'] as List<dynamic>;
          }
        }
        // Structure 2: { content: [...] }
        else if (data['content'] is List) {
          content = data['content'] as List<dynamic>;
        }
        // Structure 3: { result: [...] }
        else if (data['result'] is List) {
          content = data['result'] as List<dynamic>;
        }
      }
      // Structure 4: Direct array
      else if (data is List) {
        content = data;
      }

      if (content == null) {
        if (kDebugMode) {
          print('⚠️ Cannot find content array in response: $data');
        }
        return [];
      }

      return content
          .map(
            (item) =>
                HoiDongItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing response: $e');
        print('   - Data: $data');
      }
      throw CustomException(ErrorCode.invalidResponse);
    }
  }

  /// Fetch tất cả hội đồng (hoặc theo keyword)
  Future<List<HoiDongItem>> fetchAll({
    String? keyword,
    int page = 0,
    int size = 100,
    List<String>? sort,
  }) {
    return fetchHoiDong(keyword: keyword, page: page, size: size, sort: sort);
  }

  /// Fetch hội đồng theo đề tài
  Future<List<HoiDongItem>> fetchByTopic({
    required int topicId,
    int page = 0,
    int size = 100,
    List<String>? sort,
  }) {
    return fetchHoiDong(idDeTai: topicId, page: page, size: size, sort: sort);
  }

  /// Fetch hội đồng theo giảng viên
  Future<List<HoiDongItem>> fetchByLecturer({
    required int lecturerId,
    String? keyword,
    int page = 0,
    int size = 100,
    List<String>? sort,
  }) {
    return fetchHoiDong(
      idGiangVien: lecturerId,
      keyword: keyword,
      page: page,
      size: size,
      sort: sort,
    );
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
