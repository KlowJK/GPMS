class SinhVienItem {
  final String maSV;
  final String hoTen;
  final String tenLop;
  final String? soDienThoai;
  final String? cvUrl;
  final String? tenDeTai;

  SinhVienItem({
    required this.maSV,
    required this.hoTen,
    required this.tenLop,
    this.soDienThoai,
    this.cvUrl,
    this.tenDeTai,
  });

  factory SinhVienItem.fromJson(Map<String, dynamic> j) {
    String firstNonEmpty(List<String> keys, String fallback) {
      for (final k in keys) {
        final v = j[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty) return s;
        }
      }
      return fallback;
    }

    String? toNullableString(String key) {
      final v = j[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return SinhVienItem(
      maSV: firstNonEmpty(['maSV', 'studentCode'], '—'),
      hoTen: firstNonEmpty(['hoTen', 'fullName'], 'Sinh viên'),
      tenLop: firstNonEmpty(['tenLop', 'lop'], '—'),
      soDienThoai: toNullableString('soDienThoai'),
      cvUrl: toNullableString('cvUrl'),
      tenDeTai: toNullableString('tenDeTai'),
    );
  }
}
