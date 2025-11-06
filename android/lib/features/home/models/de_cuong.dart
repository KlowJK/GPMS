class DeCuong {
  final int id;
  final String duongDan;
  final String phienBan;

  DeCuong({required this.id, required this.duongDan, required this.phienBan});

  factory DeCuong.fromJson(Map<String, dynamic> json) {
    return DeCuong(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      duongDan: json['duongDan'] ?? '',
      phienBan: json['phienBan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'duongDan': duongDan, 'phienBan': phienBan};
  }

  static List<DeCuong> listFromJson(dynamic json) {
    if (json is! List) return <DeCuong>[];
    return json
        .map((e) => DeCuong.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
