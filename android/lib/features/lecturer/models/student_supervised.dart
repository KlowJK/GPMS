class StudentSupervised {
  final String? maSV;
  final String? hoTen;
  final String? tenLop;
  final String? tenDeTai;
  final String? trangThaiBaoCao;

  const StudentSupervised({
    this.maSV,
    this.hoTen,
    this.tenLop,
    this.tenDeTai,
    this.trangThaiBaoCao,
  });

  factory StudentSupervised.fromJson(Map<String, dynamic> json) {
    return StudentSupervised(
      maSV: json['maSV']?.toString(),
      hoTen: json['hoTen']?.toString(),
      tenLop: json['tenLop']?.toString(),
      tenDeTai: json['tenDeTai']?.toString(),
      trangThaiBaoCao: json['trangThaiBaoCao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'maSV': maSV,
    'hoTen': hoTen,
    'tenLop': tenLop,
    'tenDeTai': tenDeTai,
    'trangThaiBaoCao': trangThaiBaoCao,
  };

  @override
  String toString() => 'StudentSupervised(${toJson()})';
}
