// lib/features/lecturer/models/hoi_dong_item.dart
class HoiDongItem {
  final int id;
  final String tenHoiDong;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final String? chuTich;
  final String? thuKy;

  HoiDongItem({
    required this.id,
    required this.tenHoiDong,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.chuTich,
    this.thuKy,
  });

  static int _safeInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0; // <— nếu null thì về 0, tránh crash
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) {
      // server có thể trả '2025-10-01' hoặc '2025-10-01T00:00:00'
      try { return DateTime.parse(v); } catch (_) {}
    }
    return null;
  }

  factory HoiDongItem.fromJson(Map<String, dynamic> j) {
    return HoiDongItem(
      id: _safeInt(j['id']),
      tenHoiDong: (j['tenHoiDong'] ?? '').toString(),
      thoiGianBatDau: _parseDate(j['thoiGianBatDau']),
      thoiGianKetThuc: _parseDate(j['thoiGianKetThuc']),
      chuTich: j['chuTich']?.toString(),
      thuKy: j['thuKy']?.toString(),
    );
  }
}
