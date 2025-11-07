class SinhVien {
  final String hoTen;
  final String maSV;
  final String lop;
  final String idDeTai;
  final String tenDeTai;
  final String gvhd;
  final String idBoMon;
  final String boMon;

  SinhVien({
    required this.hoTen,
    required this.maSV,
    required this.lop,
    required this.idDeTai,
    required this.tenDeTai,
    required this.gvhd,
    required this.idBoMon,
    required this.boMon,
  });

  factory SinhVien.fromJson(Map<String, dynamic> json) => SinhVien(
    hoTen: json['hoTen'] as String? ?? '',
    maSV: json['maSV'] as String? ?? '',
    lop: json['lop'] as String? ?? '',
    idDeTai: json['idDeTai'] as String? ?? '',
    tenDeTai: json['tenDeTai'] as String? ?? '',
    gvhd: json['gvhd'] as String? ?? '',
    idBoMon: json['idBoMon'] as String? ?? '',
    boMon: json['boMon'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'hoTen': hoTen,
    'maSV': maSV,
    'lop': lop,
    'idDeTai': idDeTai,
    'tenDeTai': tenDeTai,
    'gvhd': gvhd,
    'idBoMon': idBoMon,
    'boMon': boMon,
  };

  SinhVien copyWith({
    String? hoTen,
    String? maSV,
    String? lop,
    String? idDeTai,
    String? tenDeTai,
    String? gvhd,
    String? idBoMon,
    String? boMon,
  }) {
    return SinhVien(
      hoTen: hoTen ?? this.hoTen,
      maSV: maSV ?? this.maSV,
      lop: lop ?? this.lop,
      idDeTai: idDeTai ?? this.idDeTai,
      tenDeTai: tenDeTai ?? this.tenDeTai,
      gvhd: gvhd ?? this.gvhd,
      idBoMon: idBoMon ?? this.idBoMon,
      boMon: boMon ?? this.boMon,
    );
  }

  @override
  String toString() {
    return 'SinhVien(hoTen: $hoTen, maSV: $maSV, lop: $lop, idDeTai: $idDeTai)';
  }
}
