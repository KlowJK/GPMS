class TuanItem {
  final int tuan;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;

  TuanItem({required this.tuan, this.ngayBatDau, this.ngayKetThuc});

  factory TuanItem.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return TuanItem(
      tuan: (json['tuan'] is int) ? json['tuan'] as int : int.tryParse(json['tuan']?.toString() ?? '') ?? 0,
      ngayBatDau: tryParse(json['ngayBatDau']?.toString()),
      ngayKetThuc: tryParse(json['ngayKetThuc']?.toString()),
    );
  }
}

