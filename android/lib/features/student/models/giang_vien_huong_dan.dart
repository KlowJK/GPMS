// Model cho Advisor
class GiangVienHuongDan {
  final int id;
  final String hoTen;

  GiangVienHuongDan({required this.id, required this.hoTen});

  factory GiangVienHuongDan.fromJson(Map<String, dynamic> json) =>
      GiangVienHuongDan(id: json['id'], hoTen: json['hoTen']);
}
