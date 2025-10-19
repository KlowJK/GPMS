import 'package:flutter/material.dart';
import 'package:GPMS/features/student/models/nhan_xet.dart';

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
  final DeCuongStatus status;
  final String? nhanXet; // convenience: first comment text
  final List<NhanXet>? nhanXets; // full parsed comments

  // Giảng viên / vai trò
  final String? hoTenGiangVienHuongDan;
  final String? hoTenGiangVienPhanBien;
  final String? hoTenTruongBoMon;

  // Thông tin SV (tuỳ API có/không)
  final int? sinhVienId;
  final String? sinhVienTen;
  final String? maSV;

  // Số lần nộp (API có thể là lanNop / soLanNop)
  final int? lanNop;

  final DeCuongStatus? gvPhanBienDuyet;
  final DeCuongStatus? tbmDuyet;

  DeCuongItem({
    required this.id,
    required this.status,
    this.fileName,
    this.lanNop,
    this.nhanXet,
    this.nhanXets,
    this.hoTenGiangVienHuongDan,
    this.hoTenGiangVienPhanBien,
    this.hoTenTruongBoMon,
    this.sinhVienId,
    this.sinhVienTen,
    this.maSV,
    this.lanNop,
    this.gvPhanBienDuyet,
    this.tbmDuyet,
  });

  DeCuongItem copyWith({
    DeCuongStatus? status,
    String? nhanXet,
    List<NhanXet>? nhanXets,
    String? hoTenGiangVienHuongDan,
    String? hoTenGiangVienPhanBien,
    String? hoTenTruongBoMon,
    int? sinhVienId,
    String? sinhVienTen,
    String? maSV,
    int? lanNop,
    String? gvPhanBienDuyet,
    String? tbmDuyet,
  }) {
    return DeCuongItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      ngayNop: ngayNop ?? this.ngayNop,
      status: status ?? this.status,
      nhanXet: nhanXet ?? this.nhanXet,
      nhanXets: nhanXets ?? this.nhanXets,
      hoTenGiangVienHuongDan:
          hoTenGiangVienHuongDan ?? this.hoTenGiangVienHuongDan,
      hoTenGiangVienPhanBien:
          hoTenGiangVienPhanBien ?? this.hoTenGiangVienPhanBien,
      hoTenTruongBoMon: hoTenTruongBoMon ?? this.hoTenTruongBoMon,
      sinhVienId: sinhVienId ?? this.sinhVienId,
      sinhVienTen: sinhVienTen ?? this.sinhVienTen,
      maSV: maSV ?? this.maSV,
      lanNop: lanNop ?? this.lanNop,
      gvPhanBienDuyet: gvPhanBienDuyet != null
          ? mapDeCuongStatus(gvPhanBienDuyet)
          : this.gvPhanBienDuyet,
      tbmDuyet: tbmDuyet != null ? mapDeCuongStatus(tbmDuyet) : this.tbmDuyet,
    );
  }

  factory DeCuongItem.fromJson(Map<String, dynamic> j) {
    int? tryParseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    List<NhanXet>? parseNhanXets(dynamic v) {
      if (v == null) return null;
      if (v is List) {
        return v
            .map((e) {
              if (e is Map)
                return NhanXet.fromJson(Map<String, dynamic>.from(e));
              return null;
            })
            .whereType<NhanXet>()
            .toList();
      }
      if (v is Map) {
        return [NhanXet.fromJson(Map<String, dynamic>.from(v))];
      }
      return null;
    }

    String? firstNonEmpty(List<String> keys) {
      for (final k in keys) {
        final val = j[k];
        if (val == null) continue;
        final s = val.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return null;
    }

    final idVal = j['id'];
    final parsedId = tryParseInt(idVal);
    if (parsedId == null) {
      throw FormatException('Missing or invalid "id" in DeCuongItem JSON');
    }

    final fileNameVal = firstNonEmpty(['deCuongUrl']);
    final ngayNopVal = j['createdAt'];
    final statusVal = j['trangThai'];
    final sinhVienIdVal =
        j['sinhVienId'] ?? j['sinh_vien_id'] ?? j['studentId'];
    final sinhVienTenVal = firstNonEmpty([
      'sinhVienTen',
      'hoTenSinhVien',
      'hoTen',
      'studentName',
    ]);
    final maSVVal = firstNonEmpty(['maSV']);
    final lanNopVal = j['phienBan'];

    // reviewer/advisor/head name variants
    final hoTenGiangVienHuongDanVal = firstNonEmpty(['hoTenGiangVienHuongDan']);
    final hoTenGiangVienPhanBienVal = firstNonEmpty(['hoTenGiangVienPhanBien']);
    final hoTenTruongBoMonVal = firstNonEmpty(['hoTenTruongBoMon']);
    final parsedNhanXets = parseNhanXets(j['nhanXets']);
    final singleNhanXet = j['nhanXet'] is String
        ? j['nhanXet'].toString().trim()
        : (j['comment'] is String ? j['comment'].toString().trim() : null);
    final firstFromList = parsedNhanXets != null && parsedNhanXets.isNotEmpty
        ? parsedNhanXets.first.noiDung?.trim()
        : null;
    final gvPhanBienDuyet = j['gvPhanBienDuyet'];
    final tbmDuyet = j['tbmDuyet'];

    return DeCuongItem(
      id: parsedId,
      fileName: fileNameVal,
      ngayNop: parseDate(ngayNopVal),
      status: mapDeCuongStatus(statusVal?.toString()),
      nhanXet: singleNhanXet ?? firstFromList,
      nhanXets: parsedNhanXets,
      hoTenGiangVienHuongDan: hoTenGiangVienHuongDanVal,
      hoTenGiangVienPhanBien: hoTenGiangVienPhanBienVal,
      hoTenTruongBoMon: hoTenTruongBoMonVal,
      sinhVienId: tryParseInt(sinhVienIdVal),
      sinhVienTen: sinhVienTenVal,
      maSV: maSVVal,
      lanNop: tryParseInt(lanNopVal),
      gvPhanBienDuyet: gvPhanBienDuyet != null
          ? mapDeCuongStatus(gvPhanBienDuyet)
          : null,
      tbmDuyet: tbmDuyet != null ? mapDeCuongStatus(tbmDuyet) : null,
    );
  }

  @override
  String toString() => 'DeCuongItem(id=$id, status=$status, sv=$sinhVienTen)';
}
