import 'package:flutter/material.dart';

class TienDo extends StatefulWidget {
  const TienDo({super.key});

  @override
  State<TienDo> createState() => TienDoState();
}

class TienDoState extends State<TienDo> {
  final students = <StudentProgress>[
    StudentProgress(
      name: 'Hà Văn Thắng',
      studentId: '2251172490',
      className: '64KTPM4',
      topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      status: SubmitStatus.submitted,
    ),
    StudentProgress(
      name: 'Lê Đức Anh',
      studentId: '2251172491',
      className: '64KTPM4',
      topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      status: SubmitStatus.missing,
    ),
    StudentProgress(
      name: 'Nguyễn Văn A',
      studentId: '2251172001',
      className: '64KTPM4',
      topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      status: SubmitStatus.submitted,
    ),
    StudentProgress(
      name: 'Trần Thị B',
      studentId: '2251172333',
      className: '64KTPM4',
      topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      status: SubmitStatus.missing,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Tiến độ'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header thời gian nộp
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _WeekHeader(
                  from: DateTime(2025, 9, 15, 10, 0, 0),
                  to: DateTime(2025, 9, 21, 23, 59, 33),
                  note: 'Thời hạn nộp nhật ký Tuần 2 :',
                ),
              ),
            ),
            // Tiêu đề danh sách
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Danh sách sinh viên:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            // List sinh viên
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _StudentCard(
                  info: students[i],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProgressDetailScreen(student: students[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info, this.onTap});
  final StudentProgress info;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color statusColor(SubmitStatus s) => s == SubmitStatus.submitted
        ? const Color(0xFF00C409)
        : const Color(0xFFFFDD00);
    String statusText(SubmitStatus s) =>
        s == SubmitStatus.submitted ? 'Đã nộp' : 'Chưa nộp';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: const Color(0xFFE4F6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          info.studentId,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        info.className,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Trạng thái: '),
                            TextSpan(
                              text: statusText(info.status),
                              style: TextStyle(
                                color: statusColor(info.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Đề tài: ${info.topic}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                      MÀN 2: CHI TIẾT TIẾN ĐỘ & NHẬN XÉT                   */
/* -------------------------------------------------------------------------- */

class ProgressDetailScreen extends StatefulWidget {
  const ProgressDetailScreen({super.key, required this.student});
  final StudentProgress student;

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  final weeks = List.generate(15, (i) => 'Tuần ${i + 1}');
  String selectedWeek = 'Tuần 2';

  // mock dữ liệu 3 tuần giống ảnh
  late final List<WeeklyEntry> entries = [
    WeeklyEntry(
      weekLabel: 'Tuần : 3',
      dateRange: '22/09/2025 - 28/09/2025',
      work: 'hoàn thiện đề  - vẽ ERD lần 1',
      fileName: '225117362_DuongVanHung_3.pdf',
    ),
    WeeklyEntry(
      weekLabel: 'Tuần : 2',
      dateRange: '22/09/2025 - 28/09/2025',
      work: 'hoàn thiện đề  - vẽ ERD lần 1',
      fileName: '225117362_DuongVanHung_2.pdf',
    ),
    WeeklyEntry(
      weekLabel: 'Tuần : 1',
      dateRange: '15/09/2025 - 21/09/2025',
      work: 'Tìm tài liệu tham khảo - xây dựng đề cương',
      fileName: '225117362_DuongVanHung_1.pdf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        centerTitle: true,

        title: const Text(
          'Tiến độ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          // 3 ô thống kê giống ảnh
          const Row(
            children: [
              _StatCard(value: '8', label: 'Tuần nộp đúng hạn'),
              SizedBox(width: 10),
              _StatCard(value: '1', label: 'Tuần nộp muộn'),
              SizedBox(width: 10),
              _StatCard(value: '52%', label: 'Hoàn thành'),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Tiến độ từng tuần:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 10),

          // các thẻ tuần
          for (final e in entries) ...[
            _WeekCard(
              entry: e,
              onReview: () => _showReviewDialog(context, widget.student, e),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/* -------------------------------- WIDGET PHỤ ------------------------------- */

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2F6BFF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2F6BFF),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.entry, required this.onReview});
  final WeeklyEntry entry;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),

        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(2, 6, 23, .08), blurRadius: 10),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE4F6FF),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowLabelValue('', entry.weekLabel, isTitle: true),
            const SizedBox(height: 6),
            _rowLabelValue('Thời gian:  ', entry.dateRange),
            const SizedBox(height: 6),
            _rowLabelValue('Nội dung công việc đã thực hiện:  ', entry.work),
            const SizedBox(height: 6),
            const Text(
              'Kết quả đã thực hiện:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.57,
                letterSpacing: -0.41,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text(
                  'File:  ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.57,
                    letterSpacing: -0.41,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0090FF),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ActionButton(label: 'Nhận xét', onTap: onReview),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowLabelValue(String label, String value, {bool isTitle = false}) {
    const labelStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.57,
      letterSpacing: -0.41,
    );
    final valueStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.41,
    );

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Roboto'),
        children: [
          if (label.isNotEmpty) TextSpan(text: label, style: labelStyle),
          TextSpan(text: value, style: valueStyle),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF155EEF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            'Nhận xét',

            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.from, required this.to, required this.note});
  final DateTime from;
  final DateTime to;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BulletList(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ngày bắt đầu : ${_fmtDateTime(from)}\n'
                'Ngày kết thúc : ${_fmtDateTime(to)}\n'
                '$note',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList();

  @override
  Widget build(BuildContext context) {
    Widget dot() => Opacity(
      opacity: 0.5,
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1.5, color: const Color(0xFFFFDD00)),
        ),
      ),
    );
    return Column(children: [dot(), dot(), dot()]);
  }
}

/* --------------------------------- DIALOG --------------------------------- */

Future<void> _showReviewDialog(
  BuildContext context,
  StudentProgress student,
  WeeklyEntry week,
) async {
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: const Center(
        child: Text(
          'Nhận xét',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Đưa ra nhận xét ...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF94A3B8)),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 120,
              height: 34,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF155EEF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã lưu nhận xét cho ${student.name} - ${week.weekLabel}',
                      ),
                    ),
                  );
                },
                child: const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  controller.dispose();
}

/* --------------------------------- MODELS --------------------------------- */

enum SubmitStatus { submitted, missing }

class StudentProgress {
  final String name;
  final String studentId;
  final String className;
  final String topic;
  final SubmitStatus status;

  StudentProgress({
    required this.name,
    required this.studentId,
    required this.className,
    required this.topic,
    required this.status,
  });
}

class WeeklyEntry {
  final String weekLabel;
  final String dateRange;
  final String work;
  final String fileName;

  WeeklyEntry({
    required this.weekLabel,
    required this.dateRange,
    required this.work,
    required this.fileName,
  });
}
