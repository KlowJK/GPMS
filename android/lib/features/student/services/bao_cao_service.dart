import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GPMS/features/student/models/report_item.dart';

class BaoCaoService {
  final String baseUrl;
  BaoCaoService({required this.baseUrl});

  Future<List<ReportItem>> getReports() async {
    final res = await http.get(Uri.parse('$baseUrl/reports'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => ReportItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load reports');
  }

  Future<ReportItem> submitReport(ReportItem item) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    if (res.statusCode == 201) {
      return ReportItem.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to submit report');
  }
}

