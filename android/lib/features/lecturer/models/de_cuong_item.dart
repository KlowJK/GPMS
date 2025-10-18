// ignore_for_file: public_member_api_docs
import 'package:flutter/foundation.dart';

enum DeCuongStatus { pending, approved, rejected }

DeCuongStatus mapDeCuongStatus(String? s) {
  switch (s) {
    case 'DA_DUYET':
      return DeCuongStatus.approved;
    case 'TU_CHOI':
      return DeCuongStatus.rejected;
    default:
      return DeCuongStatus.pending; // CHO_DUYET / null
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class DeCuongComment {
  final String content;        // nhanXet
  final String gvName;         // hoTenGiangVien
  final DateTime? createdAt;   // createdAt

  DeCuongComment({
    required this.content,
    required this.gvName,
    this.createdAt,
  });

  factory DeCuongComment.fromJson(Map<String, dynamic> j) => DeCuongComment(
    content: (j['nhanXet'] ?? '') as String,
    gvName: (j['hoTenGiangVien'] ?? '') as String,
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
  );
}

class DeCuongItem {
  final int id;
  final String? fileName;      // deCuongUrl
  final int? lanNop;           // phienBan
  final DeCuongStatus status;  // trangThaiDeCuong
  final String? nhanXet;       // 1 nhận xét đơn lẻ (nếu BE trả)
  final String? sinhVienTen;   // hoTenSinhVien
  final String? maSV;          // maSinhVien
  final DateTime? ngayNop;
  final List<DeCuongComment> comments; // nhanXets[]

  DeCuongItem({
    required this.id,
    required this.status,
    this.fileName,
    this.lanNop,
    this.nhanXet,
    this.sinhVienTen,
    this.maSV,
    this.ngayNop,
    this.comments = const [],
  });

  DeCuongItem copyWith({
    DeCuongStatus? status,
    String? nhanXet,
    List<DeCuongComment>? comments,
  }) =>
      DeCuongItem(
        id: id,
        status: status ?? this.status,
        fileName: fileName,
        lanNop: lanNop,
        nhanXet: nhanXet ?? this.nhanXet,
        sinhVienTen: sinhVienTen,
        maSV: maSV,
        ngayNop: ngayNop,
        comments: comments ?? this.comments,
      );

  factory DeCuongItem.fromJson(Map<String, dynamic> j) {
    final nx = (j['nhanXets'] as List?)
        ?.whereType<Map>()
        .map((e) => DeCuongComment.fromJson(Map<String, dynamic>.from(e)))
        .toList() ??
        const <DeCuongComment>[];

    return DeCuongItem(
      id: _toInt(j['id']),
      fileName: j['deCuongUrl'] as String? ?? j['fileName'] as String?,
      lanNop: j['phienBan'] == null ? null : _toInt(j['phienBan']),
      status: mapDeCuongStatus(
        (j['trangThaiDeCuong'] ?? j['trangThai'])?.toString(),
      ),
      nhanXet: j['nhanXet'] as String?,
      sinhVienTen: j['hoTenSinhVien'] as String? ?? j['sinhVienTen'] as String?,
      maSV: j['maSinhVien'] as String? ?? j['maSV'] as String?,
      ngayNop: null, // map nếu BE có trường ngày nộp riêng
      comments: nx,
    );
  }

  @override
  String toString() => 'DeCuongItem(id=$id, status=$status, sv=$sinhVienTen)';
}
