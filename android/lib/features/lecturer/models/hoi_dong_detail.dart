import 'package:GPMS/features/lecturer/models/sinh_vien.dart';

class HoiDongDetail {
  final int id;
  final String tenHoiDong;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final String diaDiem;
  final String chuTich;
  final String thuKy;
  final List<String> giangVienPhanBien;
  final List<SinhVien> sinhVienList;

  HoiDongDetail({
    required this.id,
    required this.tenHoiDong,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    required this.diaDiem,
    required this.chuTich,
    required this.thuKy,
    required this.giangVienPhanBien,
    required this.sinhVienList,
  });

  factory HoiDongDetail.fromJson(Map<String, dynamic> json) => HoiDongDetail(
    id: (json['id'] is int)
        ? json['id'] as int
        : int.tryParse('${json['id']}') ?? 0,
    tenHoiDong: json['tenHoiDong'] as String? ?? '',
    thoiGianBatDau: _parseDate(json['thoiGianBatDau']),
    thoiGianKetThuc: _parseDate(json['thoiGianKetThuc']),
    diaDiem: json['diaDiem'] as String? ?? '',
    chuTich: json['chuTich'] as String? ?? '',
    thuKy: json['thuKy'] as String? ?? '',
    giangVienPhanBien:
        (json['giangVienPhanBien'] as List<dynamic>?)
            ?.map((e) => e?.toString() ?? '')
            .toList() ??
        <String>[],
    sinhVienList:
        (json['sinhVienList'] as List<dynamic>?)
            ?.map((e) => SinhVien.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <SinhVien>[],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenHoiDong': tenHoiDong,
    'thoiGianBatDau': thoiGianBatDau?.toIso8601String(),
    'thoiGianKetThuc': thoiGianKetThuc?.toIso8601String(),
    'diaDiem': diaDiem,
    'chuTich': chuTich,
    'thuKy': thuKy,
    'giangVienPhanBien': giangVienPhanBien,
    'sinhVienList': sinhVienList.map((s) => s.toJson()).toList(),
  };

  HoiDongDetail copyWith({
    int? id,
    String? tenHoiDong,
    DateTime? thoiGianBatDau,
    DateTime? thoiGianKetThuc,
    String? diaDiem,
    String? chuTich,
    String? thuKy,
    List<String>? giangVienPhanBien,
    List<SinhVien>? sinhVienList,
  }) {
    return HoiDongDetail(
      id: id ?? this.id,
      tenHoiDong: tenHoiDong ?? this.tenHoiDong,
      thoiGianBatDau: thoiGianBatDau ?? this.thoiGianBatDau,
      thoiGianKetThuc: thoiGianKetThuc ?? this.thoiGianKetThuc,
      diaDiem: diaDiem ?? this.diaDiem,
      chuTich: chuTich ?? this.chuTich,
      thuKy: thuKy ?? this.thuKy,
      giangVienPhanBien: giangVienPhanBien ?? this.giangVienPhanBien,
      sinhVienList: sinhVienList ?? this.sinhVienList,
    );
  }

  @override
  String toString() {
    return 'HoiDongDetail(id: $id, tenHoiDong: $tenHoiDong, sinhVienCount: ${sinhVienList.length})';
  }

  static DateTime? _parseDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input;
    final s = input.toString();
    return DateTime.tryParse(s);
  }
}
