enum TrangThaiDeNghi { CHO_DUYET, DA_DUYET, TU_CHOI }

class DeNghiHoanModel {
  final int id;
  final int sinhVienId;
  final TrangThaiDeNghi trangThai;
  final String lyDo;
  final String? minhChungUrl;
  final DateTime requestedAt;
  final DateTime? decidedAt;
  final int? nguoiPheDuyetId;
  final String? ghiChuQuyetDinh;

  DeNghiHoanModel({
    required this.id,
    required this.sinhVienId,
    required this.trangThai,
    required this.lyDo,
    this.minhChungUrl,
    required this.requestedAt,
    this.decidedAt,
    this.nguoiPheDuyetId,
    this.ghiChuQuyetDinh,
  });

  factory DeNghiHoanModel.fromJson(Map<String, dynamic> json) {
    return DeNghiHoanModel(
      id: json['id'],
      sinhVienId: json['sinhVienId'],
      trangThai: TrangThaiDeNghi.values.firstWhere(
        (e) => e.name == json['trangThai'],
        orElse: () => TrangThaiDeNghi.CHO_DUYET,
      ),
      lyDo: json['lyDo'] ?? '',
      minhChungUrl: json['minhChungUrl'],
      requestedAt: DateTime.parse(json['requestedAt']),
      decidedAt: json['decidedAt'] != null ? DateTime.parse(json['decidedAt']) : null,
      nguoiPheDuyetId: json['nguoiPheDuyetId'],
      ghiChuQuyetDinh: json['ghiChuQuyetDinh'],
    );
  }
}
