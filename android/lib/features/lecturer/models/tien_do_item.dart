// lib/features/lecturer/models/tien_do_item.dart
import 'package:flutter/foundation.dart';

/// Trạng thái nộp nhật ký
enum SubmitStatus { submitted, notSubmitted }

SubmitStatus parseSubmitStatus(dynamic v) {
  if (v == null) return SubmitStatus.notSubmitted;
  if (v is bool) return v ? SubmitStatus.submitted : SubmitStatus.notSubmitted;
  final s = v.toString().toUpperCase();
  // các khả năng BE trả về
  if (s.contains('DA_NOP') || s.contains('DA NOP') || s.contains('SUBMIT') || s == 'DA_NAP') {
    return SubmitStatus.submitted;
  }
  return SubmitStatus.notSubmitted;
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.tryParse(v.toString());
  } catch (_) {
    return null;
  }
}

/// 1) Dòng sinh viên trong list theo tuần
class ProgressStudent {
  final String maSinhVien;
  final String hoTen;
  final String lop;
  final String deTai;
  final SubmitStatus status;
  final int? idDeTai;

  ProgressStudent({
    required this.maSinhVien,
    required this.hoTen,
    required this.lop,
    required this.deTai,
    required this.status,
    this.idDeTai,
  });

  factory ProgressStudent.fromJson(Map<String, dynamic> j) {
    return ProgressStudent(
      maSinhVien: (j['maSinhVien'] ?? j['maSV'] ?? '').toString(),
      hoTen: (j['hoTen'] ?? j['ten'] ?? j['sinhVienTen'] ?? '').toString(),
      lop: (j['lop'] ?? j['tenLop'] ?? '').toString(),
      deTai: (j['tenDeTai'] ?? j['deTai'] ?? j['tenDT'] ?? '').toString(),
      status: parseSubmitStatus(j['trangThai'] ?? j['status'] ?? j['daNop']),
      idDeTai: _toInt(j['idDeTai'] ?? j['deTaiId']),
    );
  }
}

/// 2) Nhật ký từng tuần của một SV
class WeeklyEntry {
  final int id;
  final int tuan;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String noiDung;
  final String duongDanFile;
  final String? nhanXet;

  WeeklyEntry({
    required this.id,
    required this.tuan,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.noiDung,
    required this.duongDanFile,
    this.nhanXet,
  });

  factory WeeklyEntry.fromJson(Map<String, dynamic> j) {
    return WeeklyEntry(
      id: _toInt(j['id']),
      tuan: _toInt(j['tuan'] ?? j['week']),
      ngayBatDau: _toDate(j['ngayBatDau'] ?? j['startDate']),
      ngayKetThuc: _toDate(j['ngayKetThuc'] ?? j['endDate']),
      noiDung: (j['noiDung'] ??
          j['noiDungCongViec'] ??
          j['noiDungCongViecDaThucHien'] ??
          '')
          .toString(),
      duongDanFile:
      (j['duongDanFile'] ?? j['file'] ?? j['fileUrl'] ?? '').toString(),
      nhanXet: (j['nhanXet'] ?? j['ghiChu'] ?? j['comment'])?.toString(),
    );
  }

  WeeklyEntry copyWith({String? nhanXet}) => WeeklyEntry(
    id: id,
    tuan: tuan,
    ngayBatDau: ngayBatDau,
    ngayKetThuc: ngayKetThuc,
    noiDung: noiDung,
    duongDanFile: duongDanFile,
    nhanXet: nhanXet ?? this.nhanXet,
  );
}
