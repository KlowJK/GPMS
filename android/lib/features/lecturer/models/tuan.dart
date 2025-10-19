class Tuan {
  final int? tuan;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;

  const Tuan({this.tuan, this.ngayBatDau, this.ngayKetThuc});

  factory Tuan.fromJson(Map<String, dynamic> json) {
    return Tuan(
      tuan: json['tuan'] is int
          ? json['tuan'] as int
          : int.tryParse('${json['tuan']}') ?? 0,
      ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'tuan': tuan,
    'ngayBatDau': ngayBatDau?.toIso8601String(),
    'ngayKetThuc': ngayKetThuc?.toIso8601String(),
  };

  Tuan copyWith({int? tuan, DateTime? ngayBatDau, DateTime? ngayKetThuc}) {
    return Tuan(
      tuan: tuan ?? this.tuan,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
    );
  }

  static List<Tuan> listFromJson(List<dynamic> list) =>
      list.map((e) => Tuan.fromJson(e as Map<String, dynamic>)).toList();

  @override
  String toString() =>
      'Tuan(tuan: $tuan, ngayBatDau: $ngayBatDau, ngayKetThuc: $ngayKetThuc)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuan &&
          runtimeType == other.runtimeType &&
          tuan == other.tuan &&
          ngayBatDau == other.ngayBatDau &&
          ngayKetThuc == other.ngayKetThuc;

  @override
  int get hashCode => Object.hash(tuan, ngayBatDau, ngayKetThuc);
}
