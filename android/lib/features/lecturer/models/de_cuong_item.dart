// lib/features/lecturer/models/de_cuong_item.dart
import 'package:flutter/material.dart';

enum DeCuongStatus { pending, approved, rejected }

// Hiển thị text trạng thái cho UI
String deCuongStatusText(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.approved:
      return 'Đã duyệt';
    case DeCuongStatus.rejected:
      return 'Đã từ chối';
    case DeCuongStatus.pending:
    default:
      return 'Đang chờ duyệt';
  }
}

// Màu trạng thái cho UI
Color deCuongStatusColor(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.approved:
      return const Color(0xFF16A34A); // xanh
    case DeCuongStatus.rejected:
      return const Color(0xFFDC2626); // đỏ
    case DeCuongStatus.pending:
    default:
      return const Color(0xFFC9B325); // vàng
  }
}

// -------------------- Model --------------------

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String? _toStr(dynamic v) => v == null ? null : v.toString();

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString();
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

/// Map chuỗi trạng thái từ API -> enum
DeCuongStatus _mapStatus(dynamic s) {
  final v = s?.toString().toUpperCase();
  switch (v) {
    case 'DA_DUYET':
    case 'APPROVED':
      return DeCuongStatus.approved;
    case 'TU_CHOI':
    case 'REJECTED':
      return DeCuongStatus.rejected;
    case 'CHO_DUYET':
    case 'PENDING':
    default:
      return DeCuongStatus.pending;
  }
}

class DeCuongItem {
  final int id;

  // Thông tin hiển thị trên 2 màn:
  final String? sinhVienTen;     // UI dùng: item.sinhVienTen
  final String? maSV;            // UI dùng: item.maSV
  final String? tenDeTai;

  // Log & file:
  final int? lanNop;             // UI dùng: e.lanNop
  final DateTime? ngayNop;       // UI dùng: e.ngayNop
  final String? fileName;        // UI dùng: e.fileName (link)
  final String? nhanXet;         // UI dùng: e.nhanXet

  // Trạng thái:
  final DeCuongStatus status;    // UI dùng: e.status

  DeCuongItem({
    required this.id,
    required this.status,
    this.sinhVienTen,
    this.maSV,
    this.tenDeTai,
    this.lanNop,
    this.ngayNop,
    this.fileName,
    this.nhanXet,
  });

  DeCuongItem copyWith({
    DeCuongStatus? status,
    String? nhanXet,
  }) {
    return DeCuongItem(
      id: id,
      status: status ?? this.status,
      sinhVienTen: sinhVienTen,
      maSV: maSV,
      tenDeTai: tenDeTai,
      lanNop: lanNop,
      ngayNop: ngayNop,
      fileName: fileName,
      nhanXet: nhanXet ?? this.nhanXet,
    );
  }

  /// Chấp nhận nhiều dạng key khác nhau từ API
  factory DeCuongItem.fromJson(Map<String, dynamic> j) {
    // File có thể nằm ở nhiều key:
    final file = _toStr(j['deCuongUrl']) ??
        _toStr(j['duongDanFile']) ??
        _toStr(j['fileUrl']) ??
        _toStr(j['file']) ??
        _toStr(j['tenFile']);

    return DeCuongItem(
      id: _toInt(j['id'] ?? j['deCuongId']),
      status: _mapStatus(j['trangThai']),
      sinhVienTen: _toStr(j['sinhVienTen'] ?? j['hoTenSinhVien'] ?? j['studentName']),
      maSV: _toStr(j['maSV'] ?? j['mssv'] ?? j['maSinhVien'] ?? j['studentId']),
      tenDeTai: _toStr(j['tenDeTai']),
      lanNop: j['soLanNop'] != null ? _toInt(j['soLanNop']) : (j['lanNop'] != null ? _toInt(j['lanNop']) : null),
      ngayNop: _toDate(j['ngayNop'] ?? j['createdAt'] ?? j['thoiGianNop']),
      fileName: file,
      nhanXet: _toStr(j['nhanXet']),
    );
  }

  /// Tên file rút gọn (nếu bạn cần)
  String? get fileBaseName {
    final f = fileName;
    if (f == null || f.isEmpty) return null;
    return Uri.tryParse(f)?.pathSegments.last ?? f.split('/').last;
  }
}
