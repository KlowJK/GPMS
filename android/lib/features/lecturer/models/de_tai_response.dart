class DeTaiResponse {
  final int id;
  final String tenDeTai;
  final String trangThai;
  final String? nhanXet;
  final int? gvhdId;
  final String? sinhVienId;
  final String? gvhdTen;
  final String? tongQuanDeTaiUrl;
  final String? tongQuanFilename;

  DeTaiResponse({
    required this.id,
    required this.tenDeTai,
    required this.trangThai,
    this.nhanXet,
    this.gvhdId,
    this.sinhVienId,
    this.gvhdTen,
    this.tongQuanDeTaiUrl,
    this.tongQuanFilename,
  });

  factory DeTaiResponse.fromJson(Map<String, dynamic> json) {
    return DeTaiResponse(
      id: (json['id'] ?? 0).toInt(),
      tenDeTai: json['tenDeTai'] ?? '',
      trangThai: json['trangThai'] ?? '',
      nhanXet: json['nhanXet'],
      gvhdId: json['gvhdId'],
      sinhVienId: json['sinhVienId'],
      gvhdTen: json['gvhdTen'],
      tongQuanDeTaiUrl: json['tongQuanDeTaiUrl'],
      tongQuanFilename: json['tongQuanFilename'],
    );
  }
}
