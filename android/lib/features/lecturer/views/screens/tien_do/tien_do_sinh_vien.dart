// dart
import 'package:GPMS/features/lecturer/models/tuan.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/services/tien_do_service.dart';

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => TienDoSinhVienState();
}

class TienDoSinhVienState extends State<SinhVienTab> {
  final List<TienDoSinhVien> students = [];
  final List<Tuan> weeks = [];

  late final TienDoViewModel _vm;
  bool _initialLoad = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _vm = TienDoViewModel(service: TienDoService());
    _vm.addListener(_onVmChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _initialLoad = true);
    try {
      await _vm.loadTuans(includeAll: false);

      Tuan? tuanToUse;
      final selNum = _vm.selectedTuan;
      if (selNum != null) {
        try {
          tuanToUse = _vm.tuans.firstWhere((t) => t.tuan == selNum);
        } catch (_) {
          tuanToUse = null;
        }
      }
      tuanToUse ??= _vm.tuans.isNotEmpty ? _vm.tuans.first : null;

      await _vm.loadAll(tuan: tuanToUse);
    } finally {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  void _onVmChanged() {
    if (!mounted) return;
    setState(() {
      students
        ..clear()
        ..addAll(_vm.items);
    });
  }

  Future<void> _loadVersions({
    bool refresh = false,
    Tuan? tuan,
    String? status,
    bool supervised = false,
  }) async {
    Tuan? resolveTuan(Tuan? param) {
      if (param != null) return param;
      final selNum = _vm.selectedTuan;
      if (selNum != null) {
        try {
          return _vm.tuans.firstWhere((t) => t.tuan == selNum);
        } catch (_) {
          return null;
        }
      }
      return _vm.tuans.isNotEmpty ? _vm.tuans.first : null;
    }

    if (refresh) {
      if (!mounted) return;
      setState(() => _isRefreshing = true);
      try {
        // Load tuans first so we can resolve a Tuan reliably
        await _vm.loadTuans(includeAll: true);
        final Tuan? tuanToUse = resolveTuan(tuan);

        if (supervised) {
          await _vm.loadMySupervised(status: status ?? _vm.statusFilter);
        } else {
          await _vm.loadAll(tuan: tuanToUse);
        }
      } finally {
        if (mounted) setState(() => _isRefreshing = false);
      }
      return;
    }

    if (!mounted) return;
    setState(() => _initialLoad = true);
    try {
      // Ensure weeks are loaded before loading items that depend on them
      await _vm.loadTuans(includeAll: true);
      final Tuan? tuanToUse = resolveTuan(tuan);
      debugPrint('tuanToUse: $tuanToUse');
      await _vm.loadAll(tuan: tuanToUse);
    } finally {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstTuan = _vm.tuans.isNotEmpty ? _vm.tuans.first : null;
    final DateTime from = firstTuan?.ngayBatDau ?? DateTime.now();
    final DateTime to =
        firstTuan?.ngayKetThuc ?? DateTime.now().add(const Duration(days: 7));
    final String note = firstTuan != null
        ? 'Thời hạn nộp nhật ký Tuần ${firstTuan.tuan} :'
        : 'Thời hạn nộp nhật ký Tuần :';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadVersions,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _WeekHeader(from: from, to: to, note: note),
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
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info, this.onTap});
  final TienDoSinhVien info;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color statusColor(SubmitStatus s) => s == SubmitStatus.DA_NOP
        ? const Color(0xFF00C409)
        : const Color(0xFFFFDD00);
    String statusText(SubmitStatus s) =>
        s == SubmitStatus.DA_NOP ? 'Đã nộp' : 'Chưa nộp';
    final name = info.hoTen ?? '';
    final studentId = info.maSinhVien ?? '';
    final className = info.lop ?? '';
    final topic = info.deTai ?? '';
    final status = _toSubmitStatus(info.trangThaiNhatKy);
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
                          name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          studentId,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                        Text(
                          className,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: statusText(status),
                              style: TextStyle(
                                color: statusColor(status),
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
                  'Đề tài: $topic',
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

class ProgressDetailScreen extends StatefulWidget {
  const ProgressDetailScreen({super.key, required this.student});
  final TienDoSinhVien student;

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  final weeks = List.generate(15, (i) => 'Tuần ${i + 1}');
  String selectedWeek = 'Tuần 2';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
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
  TienDoSinhVien student,
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
                        'Đã lưu nhận xét cho ${student.hoTen} - ${week.weekLabel}',
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

enum SubmitStatus { DA_NOP, CHUA_NOP, HOAN_THANH }

SubmitStatus _toSubmitStatus(Object? v) {
  if (v == null) return SubmitStatus.CHUA_NOP;
  if (v is SubmitStatus) return v;
  final s = v.toString();
  final name = s.contains('.') ? s.split('.').last : s;
  switch (name.toUpperCase()) {
    case 'DA_NOP':
    case 'SUBMITTED':
      return SubmitStatus.DA_NOP;
    case 'HOAN_THANH':
    case 'COMPLETED':
      return SubmitStatus.HOAN_THANH;
    case 'CHUA_NOP':
    default:
      return SubmitStatus.CHUA_NOP;
  }
}

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
