class SinhVienItem {
  final String maSV;
  final String hoTen;
  final String? tenLop;
  final String? soDienThoai;
  final String? tenDeTai;
  final String? cvUrl;

  SinhVienItem({
    required this.maSV,
    required this.hoTen,
    this.tenLop,
    this.soDienThoai,
    this.tenDeTai,
    this.cvUrl,
  });

  factory SinhVienItem.fromJson(Map<String, dynamic> j) {
    return SinhVienItem(
      maSV: (j['maSV'] ?? j['maSinhVien'] ?? j['studentCode'] ?? '').toString(),
      hoTen: (j['hoTen'] ?? j['ten'] ?? j['fullName'] ?? '').toString(),
      tenLop: j['tenLop']?.toString(),
      soDienThoai: j['soDienThoai']?.toString(),
      tenDeTai: j['tenDeTai']?.toString(),
      cvUrl: j['cvUrl']?.toString(),
    );
  }
}
