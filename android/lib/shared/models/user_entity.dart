class UserEntity {
  final String token;
  final String typeToken;
  final String expiresAt;
  final int id;
  final String? fullName;
  final String email;
  final String role;
  final String? duongDanAvt;
  final int? teacherId;
  final int? studentId;

  UserEntity({
    required this.token,
    required this.typeToken,
    required this.expiresAt,
    required this.id,
    this.fullName,
    required this.email,
    required this.role,
    this.duongDanAvt,
    this.teacherId,
    this.studentId,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    // Ép kiểu map an toàn
    Map<String, dynamic> _asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v as Map) : <String, dynamic>{};

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    // Cho phép truyền vào: data (có result) HOẶC result trực tiếp
    final root = _asMap(json['result'] ?? json);
    final user = _asMap(root['user']);

    // Lấy các trường từ root trước, nếu thiếu thì fallback sang user (hoặc ngược lại khi hợp lý)
    final token = (root['accessToken'] ?? root['token'] ?? '').toString();
    final typeToken = (root['tokenType'] ?? root['typeToken'] ?? '').toString();
    final expiresAt = (root['expiresAt'] ?? root['expires_in'] ?? '')
        .toString();

    final id = _toInt(user['id'] ?? root['id']) ?? 0;
    final fullName = (user['fullName'] ?? root['fullName'])?.toString();
    final email = (user['email'] ?? root['email'] ?? '').toString();
    final role = (user['role'] ?? root['role'] ?? '').toString();
    final duongDanAvt = (user['duongDanAvt'] ?? root['duongDanAvt'])
        ?.toString();

    final teacherId = _toInt(user['teacherId'] ?? root['teacherId']);
    final studentId = _toInt(user['studentId'] ?? root['studentId']);

    return UserEntity(
      token: token,
      typeToken: typeToken,
      expiresAt: expiresAt,
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      duongDanAvt: duongDanAvt,
      teacherId: teacherId,
      studentId: studentId,
    );
  }
}
