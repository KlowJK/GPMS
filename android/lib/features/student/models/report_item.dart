enum ReportStatus { pending, approved, rejected }

class ReportItem {
  final String fileName;
  final DateTime createdAt;
  final int version;
  final ReportStatus status;
  final String? note;

  const ReportItem({
    required this.fileName,
    required this.createdAt,
    required this.version,
    this.status = ReportStatus.pending,
    this.note,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      fileName: json['fileName'],
      createdAt: DateTime.parse(json['createdAt']),
      version: json['version'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => ReportStatus.pending,
      ),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'createdAt': createdAt.toIso8601String(),
    'version': version,
    'status': status.name,
    'note': note,
  };
}

