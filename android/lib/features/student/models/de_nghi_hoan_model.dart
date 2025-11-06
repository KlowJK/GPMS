enum TrangThaiDeNghi { CHO_DUYET, DA_DUYET, TU_CHOI }

class DeNghiHoanModel {
  final int id;
  final int sinhVienId;
  final TrangThaiDeNghi trangThai;
  final String lyDo;
  final String? minhChungUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? nguoiPheDuyetId;
  final String? ghiChuQuyetDinh;

  DeNghiHoanModel({
    required this.id,
    required this.sinhVienId,
    required this.trangThai,
    required this.lyDo,
    this.minhChungUrl,
    required this.createdAt,
    this.updatedAt,
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
      // Safely parse requestedAt, fallback to current time if null
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      nguoiPheDuyetId: json['nguoiPheDuyetId'],
      ghiChuQuyetDinh: json['ghiChuQuyetDinh'],
    );
  }
}
