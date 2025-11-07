class WeeklyEntry {
  final int? id;
  final String? studentName;
  final String weekLabel;
  final String dateRange;
  final String work;
  final String fileName;
  final String? status;
  final String? review;

  WeeklyEntry({
    this.id,
    this.studentName,
    required this.weekLabel,
    required this.dateRange,
    required this.work,
    required this.fileName,
    this.status,
    this.review,
  });
}
