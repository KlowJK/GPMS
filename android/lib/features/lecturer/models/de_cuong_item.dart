import 'package:flutter/material.dart';

/// Trạng thái đề cương
enum DeCuongStatus { pending, approved, rejected }

/// Map chuỗi API -> enum
DeCuongStatus deCuongStatusFromString(String? s) {
  switch (s) {
    case 'DA_DUYET':
      return DeCuongStatus.approved;
    case 'TU_CHOI':
      return DeCuongStatus.rejected;
    case 'CHO_DUYET':
    default:
      return DeCuongStatus.pending;
  }
}

/// Hiển thị chữ theo trạng thái (dùng trong UI)
String deCuongStatusText(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.pending:
      return 'Đang chờ duyệt';
    case DeCuongStatus.approved:
      return 'Đã duyệt';
    case DeCuongStatus.rejected:
      return 'Từ chối';
  }
}

/// Màu chữ theo trạng thái (dùng trong UI)
Color deCuongStatusColor(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.pending:
      return const Color(0xFFC9B325);
    case DeCuongStatus.approved:
      return const Color(0xFF16A34A);
    case DeCuongStatus.rejected:
      return const Color(0xFFDC2626);
  }
}

/// Model item cho danh sách Đề cương
class DeCuongItem {
  final int id;
  final int? soLanNop;
  final DateTime? ngayNop;
  final String? fileName;
  final DeCuongStatus status;
  final String? nhanXet;

  // Thông tin SV minh hoạ/tuỳ API có trả
  final int? sinhVienId;
  final String? sinhVienTen;
  final String? maSV;

  DeCuongItem({
    required this.id,
    required this.status,
    this.soLanNop,
    this.ngayNop,
    this.fileName,
    this.nhanXet,
    this.sinhVienId,
    this.sinhVienTen,
    this.maSV,
  });

  factory DeCuongItem.fromJson(Map<String, dynamic> j) {
    // hỗ trợ nhiều key tên khác nhau tuỳ backend
    final file =
    (j['fileName'] ?? j['tenFile'] ?? j['file'] ?? j['file_name']) as String?;

    final ngay = j['ngayNop']?.toString();

    return DeCuongItem(
      id: (j['id'] as num).toInt(),
      soLanNop: (j['soLanNop'] as num?)?.toInt(),
      ngayNop: ngay == null ? null : DateTime.tryParse(ngay),
      fileName: file,
      status: deCuongStatusFromString(j['trangThai']?.toString()),
      nhanXet: j['nhanXet'] as String?,
      sinhVienId: (j['sinhVienId'] as num?)?.toInt(),
      sinhVienTen: j['sinhVienTen'] as String?,
      maSV: j['maSV']?.toString(),
    );
  }
}
