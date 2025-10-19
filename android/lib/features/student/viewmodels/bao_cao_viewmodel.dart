// filepath: lib/features/student/viewmodels/bao_cao_viewmodel.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/report_item.dart';
import '../services/bao_cao_service.dart';

class BaoCaoViewModel extends ChangeNotifier {
  final BaoCaoService service;

  BaoCaoViewModel({required this.service});

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<ReportItem> _items = [];
  List<ReportItem> get items => _items;

  // last raw response from submit
  SubmittedReportRaw? lastSubmittedRaw;

  int _bytesSent = 0;
  int _bytesTotal = 0;
  int get bytesSent => _bytesSent;
  int get bytesTotal => _bytesTotal;
  double get progress => (_bytesTotal > 0) ? (_bytesSent / _bytesTotal) : 0.0;

  bool get hasTopic {
    // if no items and server may return special error elsewhere; for now infer from items presence
    return true; // default to true; other code may set _error to indicate no topic
  }

  /// Latest report by createdAt (fallback to version)
  ReportItem? get latestReport {
    if (_items.isEmpty) return null;
    ReportItem latest = _items.first;
    for (final r in _items) {
      if (r.createdAt.isAfter(latest.createdAt)) {
        latest = r;
      } else if (r.createdAt.isAtSameMomentAs(latest.createdAt) && r.version > latest.version) {
        latest = r;
      }
    }
    return latest;
  }

  /// Whether user can submit a new report: true only when latest report status == rejected
  bool get canSubmitNew {
    final latest = latestReport;
    if (latest == null) return false; // if no reports, do not allow adding (follow strict rule)
    return latest.status == ReportStatus.rejected;
  }

  Future<void> fetchReports() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await service.fetchReports();
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport(ReportItem report, {String? filePath, Uint8List? fileBytes, String? fileName}) async {
    _bytesSent = 0;
    _bytesTotal = 0;
    _error = null;
    notifyListeners();

    try {
      final raw = await service.submitReport(
        report: report,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        onSendProgress: (sent, total) {
          _bytesSent = sent;
          _bytesTotal = total;
          notifyListeners();
        },
      );

      lastSubmittedRaw = raw;

      // Refresh list after successful submission
      await fetchReports();

      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('[BaoCaoViewModel] submitReport error: $_error');
      notifyListeners();
      return false;
    } finally {
      _bytesSent = 0;
      _bytesTotal = 0;
      notifyListeners();
    }
  }
}
