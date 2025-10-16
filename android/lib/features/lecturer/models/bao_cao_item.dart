// Model cho dòng trong danh sách Báo cáo

enum ReportSubmitStatus { submitted, notSubmitted }

ReportSubmitStatus _mapSubmitStatus(String? s) {
  switch ((s ?? '').toUpperCase()) {
    case 'DA_NOP':
    case 'SUBMITTED':
    case 'DONE':
      return ReportSubmitStatus.submitted;
    default:
      return ReportSubmitStatus.notSubmitted;
  }
}

class BaoCaoItem {
  final String maSV;     // mã sinh viên
  final String hoTen;    // tên sinh viên
  final String tenLop;   // lớp
  final String deTai;    // tên đề tài
  final ReportSubmitStatus trangThai; // đã nộp / chưa nộp

  BaoCaoItem({
    required this.maSV,
    required this.hoTen,
    required this.tenLop,
    required this.deTai,
    required this.trangThai,
  });

  factory BaoCaoItem.fromJson(Map<String, dynamic> j) => BaoCaoItem(
    maSV: (j['maSV'] ?? j['mssv'] ?? '').toString(),
    hoTen: (j['hoTen'] ?? j['sinhVienTen'] ?? 'Sinh viên').toString(),
    tenLop: (j['tenLop'] ?? j['lop'] ?? '').toString(),
    deTai: (j['tenDeTai'] ?? j['deTai'] ?? '').toString(),
    trangThai: _mapSubmitStatus(j['trangThai']?.toString()),
  );
}
