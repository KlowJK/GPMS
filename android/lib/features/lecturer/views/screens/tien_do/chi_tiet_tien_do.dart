import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:intl/intl.dart';

class ProgressDetailScreen extends StatefulWidget {
  const ProgressDetailScreen({
    super.key,
    required this.student,
    required this.tienDoViewModel,
  });
  final TienDoSinhVien student;
  final TienDoViewModel tienDoViewModel;

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  final weeks = List.generate(15, (i) => 'Tuần ${i + 1}');
  String selectedWeek = 'Tuần 2';
  List<TienDoSinhVien> tienDoList = [];
  List<WeeklyEntry> entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTienDo();
    });
  }

  String formatDateString(Object? raw) {
    if (raw == null) return '';
    // If it's already a DateTime, format directly
    if (raw is DateTime) {
      return DateFormat('dd/MM/yyyy').format(raw);
    }
    // If it's a String, try to parse and format
    if (raw is String) {
      if (raw.isEmpty) return '';
      try {
        final dt = DateTime.parse(raw);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        try {
          final parts = raw.split(RegExp(r'[-\/T\s:]'));
          if (parts.length >= 3) {
            final year = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final day = int.tryParse(parts[2]);
            if (year != null && month != null && day != null) {
              return DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime(year, month, day));
            }
          }
        } catch (_) {}
      }
      return raw; // fallback to original string
    }
    // Fallback for other types
    return raw.toString();
  }

  Future<void> _fetchTienDo() async {
    if (widget.student.idDeTai == null) return;
    try {
      final list = await widget.tienDoViewModel.fetchNhatKyByIdList(
        widget.student.idDeTai,
      );

      if (!mounted) return;
      setState(() {
        tienDoList = list;
        entries = list.map((t) {
          return WeeklyEntry(
            weekLabel: 'Tuần ${t.tuan ?? ''}',
            dateRange:
                '${formatDateString(t.ngayBatDau)}${(t.ngayKetThuc != null) ? ' - ${formatDateString(t.ngayKetThuc)}' : ''}',
            work: t.noiDung ?? '-',
            fileName: t.duongDanFile ?? '-',
            status: t.trangThaiNhatKy,
            review: t.nhanXet,
          );
        }).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

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

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.entry, required this.onReview});
  final WeeklyEntry entry;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E7EB);

    String _statusLabel(String? code) {
      if (code == null) return '';
      switch (code) {
        case 'CHUA_NOP':
          return 'Chưa nộp';
        case 'DA_NOP':
          return 'Đã nộp';
        case 'HOAN_THANH':
          return 'Hoàn thành';
        default:
          return code;
      }
    }

    Color _statusTextColor(String? code) {
      if (code == null) return Colors.transparent;
      switch (code) {
        case 'CHUA_NOP':
          return const Color(0xFFFFB020); // amber/orange
        case 'DA_NOP':
          return const Color(0xFF00C409); // green
        case 'HOAN_THANH':
          return const Color(0xFF2563EB); // blue
        default:
          return const Color(0xFF6B7280); // gray
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(2, 6, 23, .08), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Stack(
          children: [
            // main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowLabelValue('', entry.weekLabel, isTitle: true),
                const SizedBox(height: 6),
                _rowLabelValue('Thời gian:  ', entry.dateRange),
                const SizedBox(height: 6),
                _rowLabelValue(
                  'Nội dung công việc đã thực hiện:  ',
                  entry.work,
                ),
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
                if (entry.review != null) ...[
                  const SizedBox(height: 6),
                  _rowLabelValue('Nhận xét:  ', entry.review!),
                ],
              ],
            ),

            // positioned status badge (top-right)
            if (entry.status != null)
              Positioned(
                top: 6,
                right: 6,
                child: Text(
                  _statusLabel(entry.status),
                  style: TextStyle(
                    color: _statusTextColor(entry.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
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

class WeeklyEntry {
  final String weekLabel;
  final String dateRange;
  final String work;
  final String fileName;
  final String? status;
  final String? review;

  WeeklyEntry({
    required this.weekLabel,
    required this.dateRange,
    required this.work,
    required this.fileName,
    this.status,
    this.review,
  });
}
