import 'dart:convert';

class ReportSubmission {
  final int? id;
  final String? idDeTai;
  final String? tenDeTai;
  final String? maSinhVien;
  final String? tenSinhVien;
  final String? trangThai;
  final int? phienBan;
  final DateTime? ngayNop;
  final String? duongDanFile;
  final double? diemBaoCao;
  final String? tenGiangVienHuongDan;
  final String? nhanXet;
  final String? lop;

  const ReportSubmission({
    this.id,
    this.idDeTai,
    this.tenDeTai,
    this.maSinhVien,
    this.tenSinhVien,
    this.trangThai,
    this.phienBan,
    this.ngayNop,
    this.duongDanFile,
    this.diemBaoCao,
    this.tenGiangVienHuongDan,
    this.nhanXet,
    this.lop,
  });

  factory ReportSubmission.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ReportSubmission(
      id: parseInt(json['id']),
      idDeTai: json['idDeTai']?.toString() ?? '',
      tenDeTai: json['tenDeTai']?.toString() ?? '',
      maSinhVien: json['maSinhVien']?.toString() ?? '',
      tenSinhVien: json['tenSinhVien']?.toString() ?? '',
      trangThai: json['trangThai']?.toString() ?? '',
      phienBan: parseInt(json['phienBan']),
      ngayNop: parseDate(json['createdAt']),
      duongDanFile: json['duongDanFile']?.toString() ?? '',
      diemBaoCao: parseDouble(json['diemBaoCao']),
      tenGiangVienHuongDan: json['tenGiangVienHuongDan']?.toString() ?? '',
      nhanXet: json['nhanXet']?.toString() ?? '',
      lop: json['lop']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'idDeTai': idDeTai,
    'tenDeTai': tenDeTai,
    'maSinhVien': maSinhVien,
    'tenSinhVien': tenSinhVien,
    'trangThai': trangThai,
    'phienBan': phienBan,
    'createdAt': ngayNop?.toUtc().toIso8601String(),
    'duongDanFile': duongDanFile,
    'diemBaoCao': diemBaoCao,
    'tenGiangVienHuongDan': tenGiangVienHuongDan,
    'nhanXet': nhanXet,
    'lop': lop,
  };

  ReportSubmission copyWith({
    int? id,
    String? idDeTai,
    String? tenDeTai,
    String? maSinhVien,
    String? tenSinhVien,
    String? trangThai,
    int? phienBan,
    DateTime? ngayNop,
    String? duongDanFile,
    double? diemBaoCao,
    String? tenGiangVienHuongDan,
    String? nhanXet,
    String? lop,
  }) {
    return ReportSubmission(
      id: id ?? this.id,
      idDeTai: idDeTai ?? this.idDeTai,
      tenDeTai: tenDeTai ?? this.tenDeTai,
      maSinhVien: maSinhVien ?? this.maSinhVien,
      tenSinhVien: tenSinhVien ?? this.tenSinhVien,
      trangThai: trangThai ?? this.trangThai,
      phienBan: phienBan ?? this.phienBan,
      ngayNop: ngayNop ?? this.ngayNop,
      duongDanFile: duongDanFile ?? this.duongDanFile,
      diemBaoCao: diemBaoCao ?? this.diemBaoCao,
      tenGiangVienHuongDan: tenGiangVienHuongDan ?? this.tenGiangVienHuongDan,
      nhanXet: nhanXet ?? this.nhanXet,
      lop: lop ?? this.lop,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportSubmission &&
        other.id == id &&
        other.idDeTai == idDeTai &&
        other.tenDeTai == tenDeTai &&
        other.maSinhVien == maSinhVien &&
        other.tenSinhVien == tenSinhVien &&
        other.trangThai == trangThai &&
        other.phienBan == phienBan &&
        other.ngayNop == ngayNop &&
        other.duongDanFile == duongDanFile &&
        other.diemBaoCao == diemBaoCao &&
        other.tenGiangVienHuongDan == tenGiangVienHuongDan &&
        other.nhanXet == nhanXet &&
        other.lop == lop;
  }

  @override
  int get hashCode => Object.hash(
    id,
    idDeTai,
    tenDeTai,
    maSinhVien,
    tenSinhVien,
    trangThai,
    phienBan,
    ngayNop,
    duongDanFile,
    diemBaoCao,
    tenGiangVienHuongDan,
    nhanXet,
    lop,
  );

  @override
  String toString() => 'ReportSubmission(${jsonEncode(toJson())})';
}
