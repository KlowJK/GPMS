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

    final user = _asMap(json['user']); // có thể rỗng

    final token = (json['token'] ?? json['accessToken'] ?? '').toString();
    final email = (user['email'] ?? json['email'] ?? '').toString();
    final role = (user['role'] ?? json['role'] ?? '').toString();
    final id = _toInt(user['id'] ?? json['id']) ?? 0;
    final typeToken = (json['typeToken'] ?? json['tokenType'] ?? '').toString();
    final expiresAt = (json['expiresAt'] ?? json['expires_in'] ?? '')
        .toString();
    final duongDanAvt = (user['duongDanAvt'] ?? json['duongDanAvt'])
        ?.toString();

    return UserEntity(
      token: token,
      typeToken: typeToken,
      expiresAt: expiresAt,
      id: id,
      fullName: (user['fullName'] ?? json['fullName'])?.toString(),
      email: email,
      role: role,
      duongDanAvt: duongDanAvt,
      teacherId: _toInt(user['teacherId'] ?? json['teacherId']),
      studentId: _toInt(user['studentId'] ?? json['studentId']),
    );
  }
}
