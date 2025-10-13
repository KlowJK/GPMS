class SinhVienItem {
  final int id;
  final String hoTen;
  final String maSV;
  final String tenLop;
  final String? soDienThoai;
  final String? cvUrl;
  final String? tenDeTai;

  SinhVienItem({
    required this.id,
    required this.hoTen,
    required this.maSV,
    required this.tenLop,
    this.soDienThoai,
    this.cvUrl,
    this.tenDeTai,
  });

  factory SinhVienItem.fromJson(Map<String, dynamic> j) => SinhVienItem(
    id: (j['id'] ?? j['sinhVienId'] ?? 0 as num).toInt(),
    hoTen: (j['hoTen'] ?? j['fullName'] ?? 'Sinh viên') as String,
    maSV: (j['maSV'] ?? j['studentCode'] ?? '—') as String,
    tenLop: (j['tenLop'] ?? j['lop'] ?? '—') as String,
    soDienThoai: j['soDienThoai'] as String?,
    cvUrl: j['cvUrl'] as String?,
    tenDeTai: j['tenDeTai'] as String?,
  );
}
