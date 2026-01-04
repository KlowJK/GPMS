class ChiTietDeTaiArgs {
  final String maSV;
  final String hoTen;
  final String tenLop;
  final String soDienThoai;
  final String tenDeTai;
  final String? cvUrl;
  final int? sinhVienId;

  const ChiTietDeTaiArgs({
    required this.maSV,
    required this.hoTen,
    required this.tenLop,
    required this.soDienThoai,
    required this.tenDeTai,
    this.cvUrl,
    this.sinhVienId,
  });
}
