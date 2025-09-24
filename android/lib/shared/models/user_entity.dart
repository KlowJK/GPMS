class UserEntity {
  final String email;
  final String token;
  final String role;
  final int id;
  final int? teacherId;
  final int? studentId;
  final String? fullName;

  UserEntity({
    required this.email,
    required this.token,
    required this.role,
    required this.id,
    this.teacherId,
    this.studentId,
    this.fullName,
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

    return UserEntity(
      email: email,
      token: token,
      role: role,
      id: id,
      teacherId: _toInt(user['teacherId'] ?? json['teacherId']),
      studentId: _toInt(user['studentId'] ?? json['studentId']),
      fullName: (user['fullName'] ?? json['fullName'])?.toString(),
    );
  }
}
