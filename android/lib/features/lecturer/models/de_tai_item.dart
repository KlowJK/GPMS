// lib/features/lecturer/models/de_tai_item.dart
enum TopicStatus { pending, approved, rejected }

TopicStatus mapTrangThai(String? s) {
  switch (s) {
    case 'DA_DUYET':
      return TopicStatus.approved;
    case 'TU_CHOI':
      return TopicStatus.rejected;
    case 'CHO_DUYET':
      return TopicStatus.pending;
    default:
      return TopicStatus.pending;
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String? _firstString(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final val = j[k];
    if (val == null) continue;
    final s = val.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

class DeTaiItem {
  final int id;
  final String title;
  final TopicStatus status;
  final String? comment;
  final String? studentName;
  final String? studentId;
  final String? overviewFileName;
  final String? duongDanCv;

  DeTaiItem({
    required this.id,
    required this.title,
    required this.status,
    this.comment,
    this.studentName,
    this.studentId,
    this.overviewFileName,
    this.duongDanCv,
  });

  DeTaiItem copyWith({TopicStatus? status, String? comment}) => DeTaiItem(
    id: id,
    title: title,
    status: status ?? this.status,
    comment: comment ?? this.comment,
    studentName: studentName,
    studentId: studentId,
    overviewFileName: overviewFileName,
    duongDanCv: duongDanCv,
  );

  factory DeTaiItem.fromJson(Map<String, dynamic> j) {
    final idVal =
        j['id'] ??
        j['idDeTai'] ??
        j['id_de_tai'] ??
        j['idDetai'] ??
        j['idDeTaiString'];
    final parsedId = _toInt(idVal);

    final title =
        _firstString(j, [
          'tenDeTai',
          'ten_de_tai',
          'title',
          'tenDeTaiString',
        ]) ??
        '';

    final statusStr = _firstString(j, ['trangThai', 'trang_thai', 'status']);

    final comment = _firstString(j, ['nhanXet', 'nhan_xet', 'comment']);

    final studentId = _firstString(j, [
      'maSV',
      'ma_sinh_vien',
      'studentId',
      'sinhVienId',
      'idSinhVien',
    ]);

    final studentName = _firstString(j, [
      'hoTen',
      'ho_ten',
      'sinhVienTen',
      'studentName',
    ]);

    final overview = _firstString(j, [
      'tongQuanDeTaiUrl',
      'tongQuanFilename',
      'tongQuanDeTai',
      'overviewUrl',
      'overviewFileName',
      'tongQuanDeTaiUrlString',
    ]);

    final duongDanCv = _firstString(j, [
      'duongDanCv',
      'cvUrl',
      'cv_file',
      'cvFileName',
      'cvUrlString',
    ]);

    return DeTaiItem(
      id: parsedId,
      title: title,
      status: mapTrangThai(statusStr),
      comment: comment,
      studentId: studentId,
      studentName: studentName,
      overviewFileName: overview,
      duongDanCv: duongDanCv,
    );
  }
}
