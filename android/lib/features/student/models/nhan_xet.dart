class NhanXet {
  final int idGiangVienNhanXet;
  final String? noiDung;
  final String? nguoiNhanXet;
  final String? thoiGian;

  NhanXet({
    required this.idGiangVienNhanXet,
    this.noiDung,
    this.nguoiNhanXet,
    this.thoiGian,
  });

  factory NhanXet.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      if (v is double) return v.toInt();
      return fallback;
    }

    final idVal = _parseInt(json['idGiangVien'], fallback: 0);
    return NhanXet(
      idGiangVienNhanXet: idVal,
      noiDung: json['nhanXet'],
      nguoiNhanXet: json['hoTenGiangVien'],
      thoiGian: json['createdAt'],
    );
  }
}
