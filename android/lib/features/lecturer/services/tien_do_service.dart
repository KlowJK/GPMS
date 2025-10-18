// filepath: lib/features/lecturer/services/tien_do_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/models/tien_do_item.dart';

class WeeksInfo {
  final DateTime? from;
  final DateTime? to;
  final int selectedWeek;
  final List<int> weeks;
  WeeksInfo({
    this.from,
    this.to,
    required this.selectedWeek,
    required this.weeks,
  });
}

class TienDoService {
  static String get _base => AuthService.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final raw = await AuthService.getToken();
    if (kDebugMode) {
      final short = raw == null ? 'NULL' : '${raw.substring(0, raw.length > 10 ? 10 : raw.length)}...';
      debugPrint('[TienDoService] token(short) $short');
    }
    var token = raw;
    if (token != null && token.startsWith('Bearer ')) token = token.substring(7);
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      if (m['result'] != null) return _extractList(m['result']);
      if (m['content'] != null) return _extractList(m['content']);
      return [m];
    }
    return const [];
  }

  // --- helpers parse an toàn ---
  static DateTime? _toDateFlex(dynamic v) {
    if (v == null) return null;
    if (v is int) {
      final isSeconds = v < 100000000000;
      return DateTime.fromMillisecondsSinceEpoch(isSeconds ? v * 1000 : v);
    }
    if (v is num) {
      final x = v.toInt();
      final isSeconds = x < 100000000000;
      return DateTime.fromMillisecondsSinceEpoch(isSeconds ? x * 1000 : x);
    }
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final m = RegExp(
        r'(\d{2})[-/](\d{2})[-/](\d{4})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?'
    ).firstMatch(s);
    if (m != null) {
      final d  = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final y  = int.parse(m.group(3)!);
      final h  = int.tryParse(m.group(4) ?? '0') ?? 0;
      final mi = int.tryParse(m.group(5) ?? '0') ?? 0;
      final se = int.tryParse(m.group(6) ?? '0') ?? 0;
      return DateTime(y, mo, d, h, mi, se);
    }
    return null;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static List<int> _parseWeeks(dynamic rawWeeks) {
    final set = <int>{};
    if (rawWeeks is List) {
      for (final e in rawWeeks) {
        int? val;
        if (e is int) val = e;
        else if (e is num) val = e.toInt();
        else if (e is String) val = int.tryParse(e.trim());
        if (val != null && val > 0 && val < 100) set.add(val);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  static int _calcWeekCount(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 15;
    final days = to.difference(from).inDays + 1;
    final weeks = (days / 7).ceil();
    return weeks.clamp(1, 30);
  }

  /// ✅ GET /api/nhat-ky-tien-trinh/tuans-by-lecturer?includeAll=false|true
  /// Hỗ trợ cả 2 format:
  /// 1) result: [ {tuan, ngayBatDau, ngayKetThuc}, ... ]
  /// 2) result: { weeks: [...], from: "...", to: "...", currentWeek: n }
  static Future<WeeksInfo> fetchWeeksByLecturer({required bool includeAll}) async {
    final uri = Uri.parse('$_base/api/nhat-ky-tien-trinh/tuans-by-lecturer')
        .replace(queryParameters: {'includeAll': includeAll.toString()});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    // TH1: API trả mảng tuần: [{tuan, ngayBatDau, ngayKetThuc}, ...]
    final listLike = _extractList(decoded);
    if (listLike.isNotEmpty && listLike.first.containsKey('tuan')) {
      final ranges = <int, Map<String, DateTime?>>{};
      DateTime? minFrom, maxTo;
      for (final e in listLike) {
        final w = _toInt(e['tuan']);
        if (w <= 0) continue;
        final f = _toDateFlex(e['ngayBatDau']);
        final t = _toDateFlex(e['ngayKetThuc']);
        ranges[w] = {'from': f, 'to': t};
        if (f != null && (minFrom == null || f.isBefore(minFrom))) minFrom = f;
        if (t != null && (maxTo   == null || t.isAfter(maxTo)))     maxTo   = t;
      }
      var weeks = ranges.keys.toList()..sort();
      if (weeks.isEmpty) weeks = [1];

      // chọn tuần hiện tại theo "now" nếu khớp range; không thì lấy tuần nhỏ nhất
      var selected = weeks.first;
      final now = DateTime.now();
      for (final w in weeks) {
        final f = ranges[w]!['from'], t = ranges[w]!['to'];
        if (f != null && t != null &&
            (now.isAtSameMomentAs(f) || now.isAfter(f)) &&
            (now.isAtSameMomentAs(t) || now.isBefore(t))) {
          selected = w; break;
        }
      }

      if (kDebugMode) {
        debugPrint('[Weeks] ${weeks.join(", ")} | selected=$selected '
            '| from=$minFrom | to=$maxTo');
      }

      return WeeksInfo(
        from: minFrom, to: maxTo, selectedWeek: selected, weeks: weeks,
      );
    }

    // TH2: API trả object { weeks, from, to, currentWeek, ... }
    final obj = (decoded is Map && decoded['result'] is Map)
        ? Map<String, dynamic>.from(decoded['result'])
        : (listLike.isNotEmpty ? listLike.first : <String, dynamic>{});

    final from = _toDateFlex(obj['from'] ?? obj['ngayBatDau'] ?? obj['startDate']);
    final to   = _toDateFlex(obj['to']   ?? obj['ngayKetThuc'] ?? obj['endDate']);
    var selected = _toInt(obj['currentWeek'] ?? obj['weekNow'] ?? obj['week'] ?? 1);
    var weeks = _parseWeeks(obj['weeks'] ?? obj['listWeeks'] ?? obj['tuans']);

    if (weeks.isEmpty) {
      final count = _calcWeekCount(from, to);
      weeks = List.generate(count, (i) => i + 1);
    }
    if (!weeks.contains(selected)) {
      selected = weeks.first;
    }

    if (kDebugMode) {
      debugPrint('[Weeks(obj)] ${weeks.join(", ")} | selected=$selected '
          '| from=$from | to=$to');
    }

    return WeeksInfo(from: from, to: to, selectedWeek: selected, weeks: weeks);
  }

  /// ✅ Khử trùng lặp theo (maSinhVien, idDeTai)
  static Future<List<ProgressStudent>> listStudents({required int week}) async {
    final uri = Uri.parse('$_base/api/nhat-ky-tien-trinh/all-nhat-ky/list')
        .replace(queryParameters: {'week': '$week'});
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final list = _extractList(jsonDecode(res.body))
        .map((e) => ProgressStudent.fromJson(e))
        .toList();

    final seen = <String>{};
    final dedup = <ProgressStudent>[];
    for (final it in list) {
      final key = '${it.maSinhVien}#${it.idDeTai}';
      if (seen.add(key)) dedup.add(it);
    }
    if (kDebugMode) {
      debugPrint('[Students] raw=${list.length} -> unique=${dedup.length}');
    }
    return dedup;
  }

  /// GET /api/nhat-ky-tien-trinh/my-supervised-students/list?maSinhVien=&deTaiId=&week=
  static Future<List<WeeklyEntry>> fetchStudentLogs({
    required String maSinhVien,
    int? deTaiId,
    int? week,
  }) async {
    final qp = <String, String>{'maSinhVien': maSinhVien};
    if (deTaiId != null && deTaiId > 0) qp['deTaiId'] = '$deTaiId';
    if (week != null && week > 0) qp['week'] = '$week';

    final uri = Uri.parse('$_base/api/nhat-ky-tien-trinh/my-supervised-students/list')
        .replace(queryParameters: qp);
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final list = _extractList(jsonDecode(res.body));
    return list.map((e) => WeeklyEntry.fromJson(e)).toList();
  }

  /// PUT /api/nhat-ky-tien-trinh/{id}/duyet?nhanXet=...
  static Future<WeeklyEntry> review({required int id, required String nhanXet}) async {
    final uri = Uri.parse('$_base/api/nhat-ky-tien-trinh/$id/duyet')
        .replace(queryParameters: {'nhanXet': nhanXet});
    final res = await http.put(uri, headers: await _headers(), body: '{}');
    if (res.statusCode != 200) {
      throw Exception('PUT ${uri.path} failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    final map = _extractList(body).isNotEmpty
        ? _extractList(body).first
        : (body is Map ? body : {});
    return WeeklyEntry.fromJson(Map<String, dynamic>.from(map));
  }
}
