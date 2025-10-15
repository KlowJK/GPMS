// lib/features/lecturer/models/de_tai_item.dart
enum TopicStatus { pending, approved, rejected }

TopicStatus mapTrangThai(String? s) {
  switch (s) {
    case 'DA_DUYET': return TopicStatus.approved;
    case 'TU_CHOI':  return TopicStatus.rejected;
    default:         return TopicStatus.pending; // CHO_DUYET hoặc null
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String? _pickStr(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v == null) continue;
    if (v is String && v.trim().isNotEmpty) return v.trim();
    if (v is num) return v.toString();
  }
  return null;
}

class DeTaiItem {
  final int id;
  final String title;
  final TopicStatus status;
  final String? comment;

  // Hiển thị ở UI:
  final String? studentName;  // hoTen
  final String? studentId;    // maSV
  final String? overviewUrl;  // tongQuanDeTaiUrl

  DeTaiItem({
    required this.id,
    required this.title,
    required this.status,
    this.comment,
    this.studentName,
    this.studentId,
    this.overviewUrl,
  });

  DeTaiItem copyWith({TopicStatus? status, String? comment}) => DeTaiItem(
    id: id,
    title: title,
    status: status ?? this.status,
    comment: comment ?? this.comment,
    studentName: studentName,
    studentId: studentId,
    overviewUrl: overviewUrl,
  );

  factory DeTaiItem.fromJson(Map<String, dynamic> j) => DeTaiItem(
    // id có thể là "id" (số) hoặc "idDeTai" (string)
    id: _toInt(j['id'] ?? j['idDeTai']),
    title: (j['tenDeTai'] ?? '') as String,
    status: mapTrangThai(j['trangThai'] as String?),
    comment: j['nhanXet'] as String?,
    studentName: _pickStr(j, ['hoTen', 'sinhVienTen', 'tenSinhVien']),
    studentId:   _pickStr(j, ['maSV', 'maSinhVien', 'sinhVienMa']),
    overviewUrl: _pickStr(j, ['tongQuanDeTaiUrl', 'tongQuanUrl', 'tongQuanFilename']),
  );
}
