class TienDoSinhVien {
  final int id;
  final int tuan;
  final String deTai;
  final String maSinhVien;
  final String lop;
  final int idDeTai;
  final String hoTen;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final String trangThaiNhatKy;
  final String? noiDung;
  final String? duongDanFile;
  final String? nhanXet;

  const TienDoSinhVien({
    required this.id,
    required this.tuan,
    required this.deTai,
    required this.maSinhVien,
    required this.lop,
    required this.idDeTai,
    required this.hoTen,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.trangThaiNhatKy,
    this.noiDung,
    this.duongDanFile,
    this.nhanXet,
  });

  factory TienDoSinhVien.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.parse(v);
      throw FormatException('Invalid date: $v');
    }

    return TienDoSinhVien(
      id: parseInt(json['id']),
      tuan: parseInt(json['tuan']),
      deTai: json['deTai']?.toString() ?? '',
      maSinhVien: json['maSinhVien']?.toString() ?? '',
      lop: json['lop']?.toString() ?? '',
      idDeTai: parseInt(json['idDeTai']),
      hoTen: json['hoTen']?.toString() ?? '',
      ngayBatDau: parseDate(json['ngayBatDau']),
      ngayKetThuc: parseDate(json['ngayKetThuc']),
      trangThaiNhatKy: json['trangThaiNhatKy']?.toString() ?? '',
      noiDung: json['noiDung']?.toString(),
      duongDanFile: json['duongDanFile']?.toString(),
      nhanXet: json['nhanXet']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tuan': tuan,
    'deTai': deTai,
    'maSinhVien': maSinhVien,
    'lop': lop,
    'idDeTai': idDeTai,
    'hoTen': hoTen,
    'ngayBatDau': ngayBatDau.toIso8601String(),
    'ngayKetThuc': ngayKetThuc.toIso8601String(),
    'trangThaiNhatKy': trangThaiNhatKy,
    'noiDung': noiDung,
    'duongDanFile': duongDanFile,
    'nhanXet': nhanXet,
  };

  TienDoSinhVien copyWith({
    int? id,
    int? tuan,
    String? deTai,
    String? maSinhVien,
    String? lop,
    int? idDeTai,
    String? hoTen,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
    String? trangThaiNhatKy,
    String? noiDung,
    String? duongDanFile,
    String? nhanXet,
  }) {
    return TienDoSinhVien(
      id: id ?? this.id,
      tuan: tuan ?? this.tuan,
      deTai: deTai ?? this.deTai,
      maSinhVien: maSinhVien ?? this.maSinhVien,
      lop: lop ?? this.lop,
      idDeTai: idDeTai ?? this.idDeTai,
      hoTen: hoTen ?? this.hoTen,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
      trangThaiNhatKy: trangThaiNhatKy ?? this.trangThaiNhatKy,
      noiDung: noiDung ?? this.noiDung,
      duongDanFile: duongDanFile ?? this.duongDanFile,
      nhanXet: nhanXet ?? this.nhanXet,
    );
  }

  static List<TienDoSinhVien> listFromJson(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .map((e) => TienDoSinhVien.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return 'TienDoSinhVien(id: $id, tuan: $tuan, maSinhVien: $maSinhVien, hoTen: $hoTen)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TienDoSinhVien &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tuan == other.tuan &&
          maSinhVien == other.maSinhVien &&
          hoTen == other.hoTen;

  @override
  int get hashCode => Object.hash(id, tuan, maSinhVien, hoTen);
}
