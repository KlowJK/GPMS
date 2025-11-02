import 'dart:async';
import 'dart:convert';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:GPMS/shared/models/de_tai.dart';

class MainService {
  /// Base URL configuration
  static String get baseUrl {
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

  /// Get list of notifications
  static Future<List<ThongBaoVaTinTuc>> listThongBao() async {
    final uri = Uri.parse('$baseUrl/api/public/thong-bao/list');
    try {
      final response = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📨 Response status: ${response.statusCode}');
        print('📦 Response body: ${response.body}');
        print('📋 Response headers: ${response.headers}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];
        if (result == null || result is! List) {
          throw Exception(
            'Invalid response format: missing or invalid result field',
          );
        }

        final notifications = result.map<ThongBaoVaTinTuc>((item) {
          return ThongBaoVaTinTuc.fromJson(item);
        }).toList();

        return notifications;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Unknown error';
        final code = errorData['code'] ?? response.statusCode;
        throw Exception('Failed to load notifications: $message (code: $code)');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  static Future<List<DeTai>> listDeTai() async {
    final uri = Uri.parse('$baseUrl/api/public/thu-vien/de-tai');
    try {
      final response = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📨 GET $uri -> ${response.statusCode}');
        print('📦 body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];
        if (result == null || result is! List) {
          throw Exception(
            'Invalid response format: missing or invalid result field',
          );
        }

        final list = result
            .map<DeTai>(
              (item) => DeTai.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();

        return list;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Unknown error';
        final code = errorData['code'] ?? response.statusCode;
        throw Exception('Failed to load de tai: $message (code: $code)');
      }
    } catch (e) {
      throw Exception('Error loading de tai: $e');
    }
  }
}
