class StudentProfile {
  final String? maSV;
  final String? hoTen;
  final String? soDienThoai;
  final String? email;
  final String? tenLop;
  final String? tenKhoa;
  final String? tenNganh;
  final String? cvUrl;
  final String? diaChi;
  final String? ngaySinh;
  final String? avatarUrl; // nếu BE có trả

  const StudentProfile({
    this.maSV,
    this.hoTen,
    this.soDienThoai,
    this.email,
    this.tenLop,
    this.tenKhoa,
    this.tenNganh,
    this.cvUrl,
    this.diaChi,
    this.ngaySinh,
    this.avatarUrl,
  });

  StudentProfile copyWith({
    String? maSV,
    String? hoTen,
    String? soDienThoai,
    String? email,
    String? tenLop,
    String? tenKhoa,
    String? tenNganh,
    String? cvUrl,
    String? diaChi,
    String? ngaySinh,
    String? avatarUrl,
  }) {
    return StudentProfile(
      maSV: maSV ?? this.maSV,
      hoTen: hoTen ?? this.hoTen,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      email: email ?? this.email,
      tenLop: tenLop ?? this.tenLop,
      tenKhoa: tenKhoa ?? this.tenKhoa,
      tenNganh: tenNganh ?? this.tenNganh,
      cvUrl: cvUrl ?? this.cvUrl,
      diaChi: diaChi ?? this.diaChi,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    return StudentProfile(
      maSV: s('maSV'),
      hoTen: s('hoTen'),
      soDienThoai: s('soDienThoai'),
      email: s('email'),
      tenLop: s('tenLop'),
      tenKhoa: s('tenKhoa'),
      tenNganh: s('tenNganh'),
      cvUrl: s('cvUrl'),
      diaChi: s('diaChi'),
      ngaySinh: s('ngaySinh'),
      avatarUrl: s('avatarUrl'),
    );
  }
}
