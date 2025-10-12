enum TopicStatus { pending, approved, rejected }

TopicStatus mapTrangThai(String s) {
  switch (s) {
    case 'DA_DUYET': return TopicStatus.approved;
    case 'TU_CHOI':  return TopicStatus.rejected;
    default:         return TopicStatus.pending;
  }
}

class DeTaiItem {
  final int id;
  final String title;
  final TopicStatus status;
  final String? comment;
  final String? studentName;
  final String? studentId;
  final String? overviewFileName;

  DeTaiItem({
    required this.id,
    required this.title,
    required this.status,
    this.comment,
    this.studentName,
    this.studentId,
    this.overviewFileName,
  });

  factory DeTaiItem.fromJson(Map<String, dynamic> j) => DeTaiItem(
    id: (j['id'] as num).toInt(),
    title: (j['tenDeTai'] ?? '') as String,
    status: mapTrangThai((j['trangThai'] ?? 'CHO_DUYET') as String),
    comment: j['nhanXet'] as String?,
    studentId: j['sinhVienId']?.toString(),
    studentName: j['sinhVienTen'] as String?,
    overviewFileName: j['tongQuanFilename'] as String?,
  );
}
