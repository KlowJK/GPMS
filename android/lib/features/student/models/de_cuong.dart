class DeCuong {
  final int id;
  final String? deCuongUrl;
  final int soLanNop;
  final String? tenDeTai;
  final String? mssv;
  final String? hoTenSinhVien;
  final String? hoTenGiangVien;

  DeCuong({
    required this.id,
    this.deCuongUrl,
    required this.soLanNop,
    this.tenDeTai,
    this.mssv,
    this.hoTenSinhVien,
    this.hoTenGiangVien,
  });

  factory DeCuong.fromJson(Map<String, dynamic> json) {
    // Helper to parse ints robustly
    int _parseInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is String) {
        return int.tryParse(v) ?? fallback;
      }
      if (v is double) return v.toInt();
      return fallback;
    }

    final idVal = _parseInt(json['id'], fallback: 0);
    final soLan = _parseInt(json['soLanNop'] ?? json['phienBan'] ?? json['soLan'] ?? json['phien_ban'], fallback: 0);
    return DeCuong(
      id: idVal,
      deCuongUrl: json['deCuongUrl'],
      soLanNop: soLan,
      tenDeTai: json['tenDeTai'],
      mssv: json['mssv'],
      hoTenSinhVien: json['hoTenSinhVien'],
      hoTenGiangVien: json['hoTenGiangVien'],
    );
  }
}
