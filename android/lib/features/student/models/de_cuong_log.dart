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
    int _parseInt(dynamic v, {int? fallback}) {
      if (v == null) return fallback ?? 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? (fallback ?? 0);
      if (v is double) return v.toInt();
      return fallback ?? 0;
    }

    final idVal = _parseInt(json['id'], fallback: 0);
    final phienBanVal = json.containsKey('phienBan') ? (json['phienBan'] == null ? null : _parseInt(json['phienBan'], fallback: 0)) : null;

    final nhanXetsRaw = json['nhanXets'];
    final List<NhanXet> nhanXets = <NhanXet>[];
    if (nhanXetsRaw is List) {
      for (final item in nhanXetsRaw) {
        if (item is Map<String, dynamic>) {
          try {
            nhanXets.add(NhanXet.fromJson(item));
          } catch (_) {
            // ignore malformed item
          }
        }
      }
    }

    return DeCuongLog(
      id: idVal,
      deCuongUrl: json['deCuongUrl'],
      trangThai: json['trangThai'],
      phienBan: phienBanVal,
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
