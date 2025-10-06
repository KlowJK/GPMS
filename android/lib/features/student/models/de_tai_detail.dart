import 'package:flutter/material.dart';

class DeTaiDetail {
  final int id;
  final String tenDeTai;
  final String trangThai;
  final String? nhanXet;
  final int gvhdId;
  final String gvhdTen;
  final int sinhVienId;
  final String tongQuanDeTaiUrl;
  final String tongQuanFilename;

  DeTaiDetail({
    required this.id,
    required this.tenDeTai,
    required this.trangThai,
    required this.nhanXet,
    required this.gvhdId,
    required this.gvhdTen,
    required this.sinhVienId,
    required this.tongQuanDeTaiUrl,
    required this.tongQuanFilename,
  });

  factory DeTaiDetail.fromJson(Map<String, dynamic> json) {
    return DeTaiDetail(
      id: json['id'],
      tenDeTai: json['tenDeTai'],
      trangThai: json['trangThai'],
      nhanXet: json['nhanXet'],
      gvhdId: json['gvhdId'],
      gvhdTen: json['gvhdTen'],
      sinhVienId: json['sinhVienId'],
      tongQuanDeTaiUrl: json['tongQuanDeTaiUrl'],
      tongQuanFilename: json['tongQuanFilename'],
    );
  }
}
