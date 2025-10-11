// filepath: lib/features/student/models/hoi_dong_item.dart

class HoiDongItem {
  final int id;
  final String tenHoiDong;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final String? trangThai;

  HoiDongItem({
    required this.id,
    required this.tenHoiDong,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.trangThai,
  });

  factory HoiDongItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        // backend may return just a date string ("2025-10-09") or full ISO
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return HoiDongItem(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tenHoiDong: (json['tenHoiDong'] ?? json['tenHoiDong'])?.toString() ?? '',
      thoiGianBatDau: parseDate(json['thoiGianBatDau']),
      thoiGianKetThuc: parseDate(json['thoiGianKetThuc']),
      trangThai: json['trangThai']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenHoiDong': tenHoiDong,
        'thoiGianBatDau': thoiGianBatDau?.toIso8601String(),
        'thoiGianKetThuc': thoiGianKetThuc?.toIso8601String(),
        'trangThai': trangThai,
      };
}

