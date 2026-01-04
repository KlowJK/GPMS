class GiangVienProfile {
  final String? maGiangVien;
  final String? hoTen;
  final String? soDienThoai;
  final String? email;
  final String? hocVi;
  final String? hocHam;
  final String? tenBoMon;
  final String? boMonId;
  final String? avatarUrl; // nếu BE có trả

  const GiangVienProfile({
    this.maGiangVien,
    this.hoTen,
    this.soDienThoai,
    this.email,
    this.hocVi,
    this.hocHam,
    this.tenBoMon,
    this.boMonId,
    this.avatarUrl,
  });

  GiangVienProfile copyWith({
    String? maGiangVien,
    String? hoTen,
    String? soDienThoai,
    String? email,
    String? hocVi,
    String? hocHam,
    String? tenBoMon,
    String? boMonId,
    String? avatarUrl,
  }) {
    return GiangVienProfile(
      maGiangVien: maGiangVien ?? this.maGiangVien,
      hoTen: hoTen ?? this.hoTen,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      email: email ?? this.email,
      hocVi: hocVi ?? this.hocVi,
      hocHam: hocHam ?? this.hocHam,
      tenBoMon: tenBoMon ?? this.tenBoMon,
      boMonId: boMonId ?? this.boMonId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory GiangVienProfile.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    return GiangVienProfile(
      maGiangVien: s('maGiangVien'),
      hoTen: s('hoTen'),
      soDienThoai: s('soDienThoai'),
      email: s('email'),
      hocVi: s('hocVi'),
      hocHam: s('hocHam'),
      tenBoMon: s('tenBoMon'),
      boMonId: s('boMonId'),
      avatarUrl: s('duongDanAvt'),
    );
  }
}
