import 'package:GPMS/features/home/models/de_cuong.dart';

class DeTai {
  final int id;
  final String deTai;
  final String duongDan;
  final int idDotBaoVe;
  final String namHoc;
  final String hocKy;
  final List<DeCuong> deCuongCuaDeTai;

  DeTai({
    required this.id,
    required this.deTai,
    required this.duongDan,
    required this.idDotBaoVe,
    required this.namHoc,
    required this.hocKy,
    required this.deCuongCuaDeTai,
  });

  factory DeTai.fromJson(Map<String, dynamic> json) {
    final rawList = json['deCuongCuaDeTai'];
    final list = (rawList is List)
        ? rawList
              .map((e) => DeCuong.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <DeCuong>[];

    return DeTai(
      id: json['id'] ?? 0,
      deTai: json['deTai'] ?? '',
      duongDan: json['duongDan'] ?? '',
      idDotBaoVe: json['idDotBaoVe'] ?? 0,
      namHoc: json['namHoc'] ?? '',
      hocKy: json['hocKy'] ?? '',
      deCuongCuaDeTai: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deTai': deTai,
      'duongDan': duongDan,
      'idDotBaoVe': idDotBaoVe,
      'namHoc': namHoc,
      'hocKy': hocKy,
      'deCuongCuaDeTai': deCuongCuaDeTai.map((e) => e.toJson()).toList(),
    };
  }
}
