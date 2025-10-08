class NhanXet {
  final int id;
  final String? noiDung;
  final String? nguoiNhanXet;
  final String? thoiGian;

  NhanXet({
    required this.id,
    this.noiDung,
    this.nguoiNhanXet,
    this.thoiGian,
  });

  factory NhanXet.fromJson(Map<String, dynamic> json) {
    return NhanXet(
      id: json['id'],
      noiDung: json['noiDung'],
      nguoiNhanXet: json['nguoiNhanXet'],
      thoiGian: json['thoiGian'],
    );
  }
}
