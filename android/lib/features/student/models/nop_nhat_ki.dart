enum DiaryStatus { HOAN_THANH, DA_NOP, CHUA_NOP }

/// Local diary entry model used by the UI when creating/submitting diaries.
class DiaryEntry {
  final int week;
  final String timeRange;
  final String content;
  final String? resultFileName;
  final DiaryStatus status;
  final String? teacherNote;

  const DiaryEntry({
    required this.week,
    required this.timeRange,
    required this.content,
    this.resultFileName,
    this.status = DiaryStatus.CHUA_NOP,
    this.teacherNote,
  });
}
