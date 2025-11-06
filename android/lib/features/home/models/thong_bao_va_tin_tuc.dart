class ThongBaoVaTinTuc {
  final String tieuDe;
  final String noiDung;
  final String duongDanFile;
  final DateTime ngayDang; // Thay String bằng DateTime
  final String loaiThongBao;

  ThongBaoVaTinTuc({
    required this.tieuDe,
    required this.noiDung,
    required this.duongDanFile,
    required this.ngayDang,
    required this.loaiThongBao,
  });

  factory ThongBaoVaTinTuc.fromJson(Map<String, dynamic> json) {
    return ThongBaoVaTinTuc(
      tieuDe: json['tieuDe'] ?? '',
      noiDung: json['noiDung'] ?? '',
      duongDanFile: json['fileUrl'] ?? '',
      ngayDang: DateTime.parse(
        json['createdAt'] ?? '',
      ), // Parse chuỗi thành DateTime
      loaiThongBao: json['loaiThongBao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'ngayDang': ngayDang.toIso8601String(),
      'fileUrl': duongDanFile,
      'loaiThongBao': loaiThongBao,
    };
  }
}
