enum TopicStatus { pending, approved, rejected }

TopicStatus mapTrangThai(String? s) {
  switch (s) {
    case 'DA_DUYET': return TopicStatus.approved;
    case 'TU_CHOI':  return TopicStatus.rejected;
    default:         return TopicStatus.pending;
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
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

  DeTaiItem copyWith({
    TopicStatus? status,
    String? comment,
  }) => DeTaiItem(
    id: id,
    title: title,
    status: status ?? this.status,
    comment: comment ?? this.comment,
    studentName: studentName,
    studentId: studentId,
    overviewFileName: overviewFileName,
  );

  factory DeTaiItem.fromJson(Map<String, dynamic> j) => DeTaiItem(
    id: _toInt(j['id']),
    title: (j['tenDeTai'] ?? '') as String,
    status: mapTrangThai(j['trangThai'] as String?),
    comment: j['nhanXet'] as String?,
    studentId: j['sinhVienId']?.toString(),
    studentName: j['sinhVienTen'] as String?,
    overviewFileName: j['tongQuanFilename'] as String?,
  );
}
