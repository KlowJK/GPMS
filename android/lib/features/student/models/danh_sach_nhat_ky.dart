class DiaryItem {
  final int id;
  final int? tuan;
  final String? deTai;
  final String? maSinhVien;
  final String? lop;
  final int? idDeTai;
  final String? hoTen;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String? trangThaiNhatKy;
  final String? noiDung;
  final String? duongDanFile;
  final String? nhanXet;

  DiaryItem({
    required this.id,
    this.tuan,
    this.deTai,
    this.maSinhVien,
    this.lop,
    this.idDeTai,
    this.hoTen,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.trangThaiNhatKy,
    this.noiDung,
    this.duongDanFile,
    this.nhanXet,
  });

  factory DiaryItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return DiaryItem(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tuan: (json['tuan'] is int) ? json['tuan'] as int : int.tryParse(json['tuan']?.toString() ?? ''),
      deTai: json['deTai']?.toString(),
      maSinhVien: json['maSinhVien']?.toString(),
      lop: json['lop']?.toString(),
      idDeTai: (json['idDeTai'] is int) ? json['idDeTai'] as int : int.tryParse(json['idDeTai']?.toString() ?? ''),
      hoTen: json['hoTen']?.toString(),
      ngayBatDau: parseDate(json['ngayBatDau']),
      ngayKetThuc: parseDate(json['ngayKetThuc']),
      trangThaiNhatKy: json['trangThaiNhatKy']?.toString(),
      noiDung: json['noiDung']?.toString(),
      duongDanFile: json['duongDanFile']?.toString(),
      nhanXet: json['nhanXet']?.toString(),
    );
  }
}

