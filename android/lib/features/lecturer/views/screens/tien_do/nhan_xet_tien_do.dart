import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/show_review_dialog.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/services/tien_do_service.dart';

class NhanXetTienDo extends StatefulWidget {
  const NhanXetTienDo({super.key});

  @override
  State<NhanXetTienDo> createState() => NhanXetTienDoState();
}

class NhanXetTienDoState extends State<NhanXetTienDo> {
  List<TienDoSinhVien> tienDoList = [];
  List<WeeklyEntry> entries = [];

  late final TienDoViewModel _vm;
  bool _initialLoad = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _vm = TienDoViewModel(service: TienDoService());
    _fetchNhanXetTienDo();
  }

  Future<void> _fetchNhanXetTienDo() async {
    if (!_initialLoad && _isRefreshing == false) {
      // normal fetch guard (optional)
    }
    try {
      final list = await _vm.fetchMySupervisedStudents(status: 'DA_NOP');
      if (!mounted) return;
      setState(() {
        tienDoList = list;
        entries = list
            .map(
              (t) => WeeklyEntry(
                id: t.id,
                studentName: t.hoTen,
                weekLabel: 'Tuần ${t.tuan ?? ''}',
                dateRange:
                    '${formatDateString(t.ngayBatDau)}${(t.ngayKetThuc != null) ? ' - ${formatDateString(t.ngayKetThuc)}' : ''}',
                work: t.noiDung ?? '-',
                fileName: t.duongDanFile ?? '-',
                status: t.trangThaiNhatKy,
                review: t.nhanXet,
              ),
            )
            .toList();
        _initialLoad = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await _fetchNhanXetTienDo();
    } finally {
      if (!mounted) return;
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> approveAndRefresh(int id, String nhanXet) async {
    try {
      await _vm.approveReport(id, nhanXet);
      await _fetchNhanXetTienDo();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lưu nhận xét thành công')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu nhận xét: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
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
    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          children: [
            const SizedBox(height: 5),
            Text(
              'Nhận xét tiến độ sinh viên',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            for (final e in entries) ...[
              _WeekCard(
                entry: e,
                onReview: () async {
                  if (e.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thiếu id nhật ký')),
                    );
                    return;
                  }
                  final ok = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => ReviewDialog(
                      studentName: e.studentName ?? '',
                      weekLabel: e.weekLabel,
                      entryId: e.id!,
                      initialReview: e.review,
                      onSubmit: (id, nhanXet) async {
                        await _vm.approveReport(id, nhanXet);
                      },
                    ),
                  );

                  if (ok == true) {
                    await _fetchNhanXetTienDo();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã lưu nhận xét cho ${e.studentName ?? ''} - ${e.weekLabel}',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
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
                if (entry.review != null) ...[
                  const SizedBox(height: 6),
                  _rowLabelValue('Nhận xét:  ', entry.review!),
                ],
                const SizedBox(height: 2),
                // dart
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

                    // Single Expanded to provide proper flex constraints
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final file = entry.fileName;
                          if (file == null ||
                              file.trim().isEmpty ||
                              file == '-') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Không có file để xem'),
                              ),
                            );
                            return;
                          }

                          final uri = Uri.tryParse(file.trim());
                          if (uri != null &&
                              (uri.scheme == 'http' || uri.scheme == 'https')) {
                            try {
                              final launched = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!launched) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Không thể mở đường dẫn'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi khi mở file: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          } else {
                            await showDialog<void>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Xem chi tiết'),
                                content: Text(file),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dCtx).pop(),
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Xem chi tiết',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF0090FF),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (entry.status == 'DA_NOP')
                      _ActionButton(label: 'Nhận xét', onTap: onReview),
                  ],
                ),
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
    return Container(
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
    );
  }
}

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
