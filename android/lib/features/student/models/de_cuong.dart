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
    return DeCuong(
      id: json['id'],
      deCuongUrl: json['deCuongUrl'],
      soLanNop: json['soLanNop'],
      tenDeTai: json['tenDeTai'],
      mssv: json['mssv'],
      hoTenSinhVien: json['hoTenSinhVien'],
      hoTenGiangVien: json['hoTenGiangVien'],
    );
  }
}
