import 'package:flutter/material.dart';

class BaoCao extends StatelessWidget {
  const BaoCao({super.key});

  @override
  Widget build(BuildContext context) {
    final students = <StudentReport>[
      StudentReport(
        name: 'Hà Văn Thắng',
        studentId: '2251172362',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: ReportStatus.submitted,
      ),
      StudentReport(
        name: 'Lê Đức Anh',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: ReportStatus.notSubmitted,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Báo cáo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _HeaderBlock(
                  from: DateTime(2025, 12, 15, 10, 0, 0),
                  to: DateTime(2025, 12, 17, 23, 59, 33),
                  title: 'Thời hạn nộp báo cáo',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Danh sách sinh viên:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: students.length,
                itemBuilder: (_, i) => _StudentReportCard(
                  info: students[i],
                  onTap: () {
                    final versions = <ReportVersion>[
                      ReportVersion(
                        version: 1,
                        date: '15/12/2025',
                        file: '225117362_DuongVanHung_1.pdf',
                        status: ApproveStatus.pending,
                        score: null,
                      ),
                      ReportVersion(
                        version: 2,
                        date: '16/12/2025',
                        file: '225117362_DuongVanHung_2.pdf',
                        status: ApproveStatus.approved,
                        score: 9.5,
                      ),
                    ];
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(
                          student: students[i],
                          versions: versions,
                        ),
                      ),
                    );
                  },
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.from,
    required this.to,
    required this.title,
  });

  final DateTime from;
  final DateTime to;
  final String title;

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
            const _ThreeBullets(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ngày bắt đầu : ${_fmtDateTime(from)}\n'
                'Ngày kết thúc : ${_fmtDateTime(to)}\n'
                '$title :',

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

class _ThreeBullets extends StatelessWidget {
  const _ThreeBullets();

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

/* ----------------------- Card báo cáo sinh viên (list) -------------------- */

class _StudentReportCard extends StatelessWidget {
  const _StudentReportCard({required this.info, required this.onTap});
  final StudentReport info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color statusColor(ReportStatus s) => s == ReportStatus.submitted
        ? const Color(0xFF00C409)
        : const Color(0xFFFFDD00);

    String statusText(ReportStatus s) =>
        s == ReportStatus.submitted ? 'Đã nộp' : 'Chưa nộp';

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                'Đề tài: ${info.topic}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                        MÀN HÌNH THÔNG TIN CHI TIẾT                         */
/* -------------------------------------------------------------------------- */

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({
    super.key,
    required this.student,
    required this.versions,
  });

  final StudentReport student;
  final List<ReportVersion> versions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Thông tin chi tiết báo cáo'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Đề tài:  ${student.topic}.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),

            child: Text(
              'Thông tin sinh viên thực hiện:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Card(
            margin: const EdgeInsets.only(top: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              children: [
                _InfoRow(label: 'Họ tên', value: student.name),
                const Divider(height: 1),
                const _InfoRow(label: 'Email', value: 'havanthang@e.tlu.vn'),
                const Divider(height: 1),
                const _InfoRow(label: 'Ngày sinh', value: '24/09/2003'),
                const Divider(height: 1),
                const _InfoRow(label: 'Số điện thoại', value: '0123456789'),
                const Divider(height: 1),
                const _InfoRow(label: 'Giới tính', value: 'Nữ'),
                const Divider(height: 1),
                _InfoRow(label: 'Mã sinh viên', value: student.studentId),
                const Divider(height: 1),
                const _InfoRow(label: 'Ngành', value: 'Kỹ thuật phần mềm'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Các phiên bản báo cáo:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...versions
              .map(
                (v) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReportVersionCard(version: v, student: student),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),

      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/* ------------------------ Card phiên bản báo cáo -------------------------- */

enum ApproveStatus { pending, approved, rejected }

class ReportVersion {
  int version;
  String date;
  String file;
  ApproveStatus status;
  double? score;

  ReportVersion({
    required this.version,
    required this.date,
    required this.file,
    required this.status,
    this.score,
  });
}

class ReportVersionCard extends StatefulWidget {
  const ReportVersionCard({
    super.key,
    required this.version,
    required this.student,
  });

  final ReportVersion version;
  final StudentReport student;

  @override
  State<ReportVersionCard> createState() => _ReportVersionCardState();
}

class _ReportVersionCardState extends State<ReportVersionCard> {
  late ApproveStatus _status;
  late double? _score;

  @override
  void initState() {
    super.initState();
    _status = widget.version.status;
    _score = widget.version.score;
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _status == ApproveStatus.approved;
    final isRejected = _status == ApproveStatus.rejected;

    Color borderColor = Colors.grey.shade300;
    if (isApproved) borderColor = const Color(0xFF22C55E);
    if (isRejected) borderColor = const Color(0xFFEF4444);

    return Card(
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phiên bản ${widget.version.version}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),
            Text('Ngày nộp: ${widget.version.date}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('File: '),
                Flexible(
                  child: Text(
                    widget.version.file,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Trạng thái + điểm (khi đã duyệt / từ chối)
            Row(
              children: [
                if (_status != ApproveStatus.pending) ...[
                  Text(
                    _status == ApproveStatus.approved
                        ? 'Trạng thái: Đã duyệt'
                        : 'Trạng thái: Từ chối',
                    style: TextStyle(
                      color: _status == ApproveStatus.approved
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_score != null)
                    Text(
                      'Điểm: ${_score!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Nút hành động (ẩn khi không còn pending)
            if (_status == ApproveStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => setState(() {
                        _status = ApproveStatus.rejected;
                        _score = null;
                      }),
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7CD3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        final total = await showDialog<double>(
                          context: context,
                          builder: (ctx) => GradeSheetDialog(
                            studentName: widget.student.name,
                            studentId: widget.student.studentId,
                            topic: widget.student.topic,
                          ),
                        );
                        if (total != null) {
                          setState(() {
                            _status = ApproveStatus.approved;
                            _score = total;
                          });
                        }
                      },
                      child: const Text('Duyệt'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------- Dialog PHIẾU ĐIỂM ----------------------------- */

class GradeSheetDialog extends StatefulWidget {
  const GradeSheetDialog({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.topic,
  });

  final String studentName;
  final String studentId;
  final String topic;

  @override
  State<GradeSheetDialog> createState() => _GradeSheetDialogState();
}

class _GradeSheetDialogState extends State<GradeSheetDialog> {
  final _f1 = TextEditingController();
  final _f2 = TextEditingController();
  final _f3 = TextEditingController();
  final _f4 = TextEditingController();
  double _total = 0;

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _recalc() {
    setState(() {
      _total = _p(_f1) + _p(_f2) + _p(_f3) + _p(_f4);
    });
  }

  InputDecoration _boxDec() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    border: OutlineInputBorder(),
  );

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _f4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 12),
      contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: const Center(
        child: Text(
          'Phiếu điểm',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin header
              _infoRow('Khoa:', 'Công nghệ thông tin'),
              _infoRow('Ngành:', 'Kỹ thuật phần mềm'),
              _infoRow('Họ tên:', widget.studentName),
              _infoRow('Mã sinh viên:', widget.studentId),
              const SizedBox(height: 6),
              Text('Đề tài:  ${widget.topic}.'),
              const Divider(height: 16),

              // Các mục chấm điểm
              _scoreRow('Hình thức trình bày báo cáo', _f1),
              const SizedBox(height: 8),
              _scoreRow('Nội dung lý thuyết và cơ sở khoa học', _f2),
              const SizedBox(height: 8),
              _scoreRow('Mức độ nghiên cứu và phân tích', _f3),
              const SizedBox(height: 8),
              _scoreRow('Khả năng trình bày', _f4),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Tổng điểm: '),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      readOnly: true,

                      controller: TextEditingController(
                        text: _total.toStringAsFixed(1),
                      ),
                      decoration: _boxDec().copyWith(
                        fillColor: Colors.black12,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 120,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7CD3),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop<double>(context, _total),
                  child: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String left, String right) {
    return Row(
      children: [
        Expanded(child: Text(left)),
        Text(right, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _scoreRow(String label, TextEditingController c) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: _boxDec(),
            onChanged: (_) => _recalc(),
          ),
        ),
      ],
    );
  }
}

/* --------------------------------- Models --------------------------------- */

enum ReportStatus { submitted, notSubmitted }

class StudentReport {
  final String name;
  final String studentId;
  final String className;
  final String topic;
  final ReportStatus status;

  StudentReport({
    required this.name,
    required this.studentId,
    required this.className,
    required this.topic,
    required this.status,
  });
}

/* ------------------------ Bottom Navigation (dummy) ------------------------ */
