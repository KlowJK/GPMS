import 'package:flutter/material.dart';

enum DeCuongStatus { pending, approved, rejected }

DeCuongStatus mapDeCuongStatus(String? s) {
  switch (s) {
    case 'DA_DUYET':
      return DeCuongStatus.approved;
    case 'TU_CHOI':
      return DeCuongStatus.rejected;
    default:
      return DeCuongStatus.pending;
  }
}

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

Color deCuongStatusColor(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.approved:
      return const Color(0xFF16A34A);
    case DeCuongStatus.rejected:
      return const Color(0xFFDC2626);
    case DeCuongStatus.pending:
    default:
      return const Color(0xFFC9B325);
  }
}

class DeCuongItem {
  final int id;
  final String? fileName;
  final DateTime? ngayNop;
  final DeCuongStatus status;
  final String? nhanXet;

  // Thông tin SV (tuỳ API có/không)
  final int? sinhVienId;
  final String? sinhVienTen;
  final String? maSV;

  // Số lần nộp (API có thể là lanNop / soLanNop)
  final int? lanNop;

  DeCuongItem({
    required this.id,
    required this.status,
    this.fileName,
    this.ngayNop,
    this.nhanXet,
    this.sinhVienId,
    this.sinhVienTen,
    this.maSV,
    this.lanNop,
  });

  DeCuongItem copyWith({
    int? id,
    String? fileName,
    DateTime? ngayNop,
    DeCuongStatus? status,
    String? nhanXet,
    int? sinhVienId,
    String? sinhVienTen,
    String? maSV,
    int? lanNop,
  }) {
    return DeCuongItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      ngayNop: ngayNop ?? this.ngayNop,
      status: status ?? this.status,
      nhanXet: nhanXet ?? this.nhanXet,
      sinhVienId: sinhVienId ?? this.sinhVienId,
      sinhVienTen: sinhVienTen ?? this.sinhVienTen,
      maSV: maSV ?? this.maSV,
      lanNop: lanNop ?? this.lanNop,
    );
  }

  factory DeCuongItem.fromJson(Map<String, dynamic> j) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return DeCuongItem(
      id: (j['id'] as num).toInt(),
      fileName: j['fileName'] ?? j['tenFile'] ?? j['file'],
      ngayNop: parseDate(j['ngayNop']),
      status: mapDeCuongStatus(j['trangThai']?.toString()),
      nhanXet: j['nhanXet'] as String?,
      sinhVienId: j['sinhVienId'] is num ? (j['sinhVienId'] as num).toInt() : null,
      sinhVienTen: j['sinhVienTen'] as String?,
      maSV: j['maSV'] as String?,
      lanNop: j['lanNop'] is num
          ? (j['lanNop'] as num).toInt()
          : (j['soLanNop'] is num ? (j['soLanNop'] as num).toInt() : null),
    );
  }
}
