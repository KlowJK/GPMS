// filepath: lib/features/student/models/report_item.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum ReportStatus { pending, approved, rejected }

ReportStatus _statusFromString(String? s) {
  if (s == null) return ReportStatus.pending;
  final low = s.toLowerCase().trim();

  // Normalize separators to spaces
  final normalized = low.replaceAll(RegExp(r"[_\-\s]+"), " ");
  // Compact (letters+digits only) to catch concatenated forms like 'tuchoi' or 'choduyet'
  final compact = low.replaceAll(RegExp(r"[^a-z0-9áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ]+"), "");

  // If the string is numeric, map common codes (best-effort)
  final numVal = int.tryParse(low);
  if (numVal != null) {
    // guess: 1=approved, 2=rejected, 0 or others = pending (adjust if backend uses different codes)
    if (numVal == 1) return ReportStatus.approved;
    if (numVal == 2) return ReportStatus.rejected;
    return ReportStatus.pending;
  }

  // Explicit rejected indicators (check first to avoid substring collisions like 'cho' inside 'tuchoi')
  if (normalized.contains('tu choi') || normalized.contains('từ chối') || normalized.contains('tu_choi') || compact.contains('tuchoi') || normalized.contains('reject') || normalized.contains('refuse') || normalized.contains('denied')) {
    return ReportStatus.rejected;
  }

  // Prioritize explicit pending indicators but only match specific phrases to avoid false positives
  if (normalized.contains('cho duyet') || normalized.contains('chờ duyệt') || compact.contains('choduyet') || normalized.contains('pending')) {
    return ReportStatus.pending;
  }

  // Broader: if response contains the token 'cho' or 'chờ' (e.g. 'CHO_DUYET' or 'CHODUYET'),
  // treat as pending. Rejected is already handled above, and approved requires explicit 'đã'/'da' or 'approved'.
  if (normalized.contains('cho') || normalized.contains('chờ')) {
    return ReportStatus.pending;
  }

  // Only treat as approved when server indicates confirmed approval: e.g. 'da duyet', 'đã duyệt', 'approved', 'accepted'
  if (normalized.contains('da duyet') || normalized.contains('đã duyệt') || normalized.contains('da duyet') || normalized.contains('đa duyet') || normalized.contains('approved') || normalized.contains('accepted') || normalized.contains('accept')) return ReportStatus.approved;

  // Fallback: pending
  return ReportStatus.pending;
}

class ReportItem {
  final int? id;
  final String? idDeTai;
  final String? rawStatus; // the original status value from API (debug/inspection)
  final String fileName;
  final DateTime createdAt;
  final int version;
  final ReportStatus status;
  final String? note;

  ReportItem({
    this.id,
    this.idDeTai,
    this.rawStatus,
    required this.fileName,
    required this.createdAt,
    required this.version,
    required this.status,
    this.note,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    // server may return duongDanFile (full url) or fileName field
    String fileName = '';
    if (json['fileName'] != null) {
      fileName = json['fileName'].toString();
    } else if (json['duongDanFile'] != null) {
      final url = json['duongDanFile'].toString();
      final parts = url.split(RegExp(r"[\\\\/]"));
      fileName = parts.isNotEmpty ? parts.last : url;
    } else if (json['tenFile'] != null) {
      fileName = json['tenFile'].toString();
    }

    DateTime createdAt = DateTime.now();
    try {
      final raw = json['ngayNop'] ?? json['createdAt'] ?? json['created_at'];
      if (raw != null) createdAt = DateTime.parse(raw.toString());
    } catch (_) {}

    int version = 1;
    try {
      if (json['phienBan'] != null) version = int.parse(json['phienBan'].toString());
      else if (json['version'] != null) version = int.parse(json['version'].toString());
    } catch (_) {}

    // Determine status raw value from multiple possible server shapes
    String? statusRaw;
    final st = json['trangThai'] ?? json['status'];
    if (st == null) {
      statusRaw = null;
    } else if (st is int) {
      statusRaw = st.toString();
    } else if (st is String) {
      statusRaw = st;
    } else if (st is Map) {
      // try common keys
      statusRaw = (st['name'] ?? st['ten'] ?? st['text'] ?? st['value'] ?? st['code'])?.toString();
      if (statusRaw == null) {
        // flatten map values to a string
        statusRaw = st.values.map((e) => e?.toString() ?? '').join(' ');
      }
    } else {
      statusRaw = st.toString();
    }

    final status = _statusFromString(statusRaw);
    if (kDebugMode) {
      try {
        print('[ReportItem.fromJson] id=${json["id"]} fileName=$fileName statusRaw=$statusRaw -> mapped=$status');
      } catch (_) {}
    }

    return ReportItem(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      idDeTai: json['idDeTai']?.toString(),
      rawStatus: statusRaw,
      fileName: fileName,
      createdAt: createdAt,
      version: version,
      status: status,
      note: json['nhanXet']?.toString() ?? json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (idDeTai != null) 'idDeTai': idDeTai,
        if (rawStatus != null) 'rawStatus': rawStatus,
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'version': version,
        'status': status.toString().split('.').last,
        if (note != null) 'note': note,
      };

  @override
  String toString() => jsonEncode(toJson());
}

class SubmittedReportRaw {
  final String? tenGiangVienHuongDan;
  final double? diemBaoCao;
  final String? duongDanFile;

  SubmittedReportRaw({this.tenGiangVienHuongDan, this.diemBaoCao, this.duongDanFile});

  factory SubmittedReportRaw.fromJson(Map<String, dynamic> json) {
    double? diem;
    try {
      if (json['diemBaoCao'] != null) diem = double.tryParse(json['diemBaoCao'].toString());
    } catch (_) {}
    return SubmittedReportRaw(
      tenGiangVienHuongDan: json['tenGiangVienHuongDan']?.toString() ?? json['tenGiangVienHuongDan']?.toString(),
      diemBaoCao: diem,
      duongDanFile: json['duongDanFile']?.toString() ?? json['duong_dan_file']?.toString(),
    );
  }
}
