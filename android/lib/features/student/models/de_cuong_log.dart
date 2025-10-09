import './nhan_xet.dart';

class DeCuongLog {
  final int id;
  final String? deCuongUrl;
  final String? trangThai;
  final int? phienBan;
  final String? tenDeTai;
  final String? msv;
  final String? hoTenSinhVien;
  final String? hoTenGiangVienHuongDan;
  final String? hoTenGiangVienPhanBien;
  final String? hoTenTruongBoMon;
  final List<NhanXet> nhanXets;
  final String? createdAt;

  DeCuongLog({
    required this.id,
    this.deCuongUrl,
    this.trangThai,
    this.phienBan,
    this.tenDeTai,
    this.msv,
    this.hoTenSinhVien,
    this.hoTenGiangVienHuongDan,
    this.hoTenGiangVienPhanBien,
    this.hoTenTruongBoMon,
    this.nhanXets = const [],
    this.createdAt,
  });

  factory DeCuongLog.fromJson(Map<String, dynamic> json) {
    var nhanXetsList = json['nhanXets'] as List? ?? [];
    List<NhanXet> nhanXets = nhanXetsList.map((i) => NhanXet.fromJson(i)).toList();

    return DeCuongLog(
      id: json['id'],
      deCuongUrl: json['deCuongUrl'],
      trangThai: json['trangThai'],
      phienBan: json['phienBan'],
      tenDeTai: json['tenDeTai'],
      msv: json['msv'],
      hoTenSinhVien: json['hoTenSinhVien'],
      hoTenGiangVienHuongDan: json['hoTenGiangVienHuongDan'],
      hoTenGiangVienPhanBien: json['hoTenGiangVienPhanBien'],
      hoTenTruongBoMon: json['hoTenTruongBoMon'],
      nhanXets: nhanXets,
      createdAt: json['createdAt'],
    );
  }
}
