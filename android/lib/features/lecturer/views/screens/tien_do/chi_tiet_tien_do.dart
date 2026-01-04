import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/show_review_dialog.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/weekly_entry.dart';

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
  List<WeeklyEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTienDo();
    });
  }

  Future<void> _fetchTienDo() async {
    if (widget.student.idDeTai == null) return;

    try {
      final list = await widget.tienDoViewModel.fetchNhatKyById(
        widget.student.idDeTai!,
      );

      if (!mounted) return;

      setState(() {
        _entries = list.map((t) {
          return WeeklyEntry(
            id: t.id,
            weekLabel: 'Tuần ${t.tuan ?? ''}',
            dateRange:
                '${_formatDate(t.ngayBatDau)}${t.ngayKetThuc != null ? ' - ${_formatDate(t.ngayKetThuc)}' : ''}',
            work: t.noiDung ?? '-',
            fileName: t.duongDanFile ?? '-',
            status: t.trangThaiNhatKy,
            review: t.nhanXet,
          );
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải tiến độ: $e')));
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';

    if (raw is DateTime) {
      return DateFormat('dd/MM/yyyy').format(raw);
    }

    if (raw is String) {
      if (raw.isEmpty) return '';
      try {
        final dt = DateTime.parse(raw);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        return raw;
      }
    }

    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TienDoViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Tiến độ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _fetchTienDo,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 10),

                // Stats cards
                _buildStats(),

                const SizedBox(height: 14),

                // Title
                Text(
                  'Tiến độ từng tuần:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 10),

                // Body
                _buildBody(vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    // Calculate stats from entries
    final submitted = _entries.where((e) => e.status != 'CHUA_NOP').length;
    final late = _entries.where((e) => e.status == 'DA_NOP').length;
    final completed = _entries.where((e) => e.status == 'HOAN_THANH').length;
    final total = _entries.length;
    final percent = total > 0
        ? ((completed / total) * 100).toStringAsFixed(0)
        : '0';

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 180,
          child: _StatCard(value: '$submitted', label: 'Tuần đã nộp'),
        ),
        SizedBox(
          width: 180,
          child: _StatCard(value: '$late', label: 'Tuần đang xử lý'),
        ),
        SizedBox(
          width: 180,
          child: _StatCard(value: '$percent%', label: 'Hoàn thành'),
        ),
      ],
    );
  }

  Widget _buildBody(TienDoViewModel vm) {
    // Loading state
    if (vm.isLoading && _entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (vm.hasError && _entries.isEmpty) {
      return _ErrorView(
        message: vm.error!,
        errorCode: vm.errorCode,
        onRetry: _fetchTienDo,
      );
    }

    // Empty state
    if (_entries.isEmpty) {
      return const _EmptyView(text: 'Chưa có tiến độ');
    }

    // List
    return Column(
      children: _entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _WeekCard(
            entry: entry,
            onReview: () => _handleReview(vm, entry),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleReview(TienDoViewModel vm, WeeklyEntry entry) async {
    if (entry.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thiếu id nhật ký')));
      return;
    }

    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ReviewDialog(
        studentName: widget.student.hoTen ?? '',
        weekLabel: entry.weekLabel,
        entryId: entry.id!,
        initialReview: entry.review,
        onSubmit: (id, nhanXet) async {
          await vm.approveReport(id: id, nhanXet: nhanXet);
        },
      ),
    );

    if (success == true && mounted) {
      await _fetchTienDo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu nhận xét cho ${widget.student.hoTen} - ${entry.weekLabel}',
          ),
        ),
      );
    }
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
        color: const Color(0xFFF9FAFB),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowLabelValue('', entry.weekLabel, isTitle: true),
                const SizedBox(height: 6),
                _rowLabelValue('Thời gian:  ', entry.dateRange),
                const SizedBox(height: 6),
                _rowLabelValue('Nội dung đã thực hiện:  ', entry.work),
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
                if (entry.review != null) ...[
                  const SizedBox(height: 6),
                  _rowLabelValue('Nhận xét:  ', entry.review!),
                ],
                const SizedBox(height: 6),
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
                    Expanded(child: _FileLink(fileName: entry.fileName)),
                    const SizedBox(width: 8),
                    if (entry.status == 'DA_NOP')
                      _ActionButton(label: 'Nhận xét', onTap: onReview),
                  ],
                ),
              ],
            ),
            if (entry.status != null)
              Positioned(
                top: 6,
                right: 6,
                child: Text(
                  _getStatusLabel(entry.status),
                  style: TextStyle(
                    color: _getStatusColor(entry.status),
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

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'CHUA_NOP':
        return 'Chưa nộp';
      case 'DA_NOP':
        return 'Đã nộp';
      case 'HOAN_THANH':
        return 'Hoàn thành';
      default:
        return status ?? '';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'CHUA_NOP':
        return const Color(0xFFFFB020);
      case 'DA_NOP':
        return const Color(0xFF00C409);
      case 'HOAN_THANH':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _FileLink extends StatelessWidget {
  const _FileLink({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleFileTap(context),
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
    );
  }

  Future<void> _handleFileTap(BuildContext context) async {
    if (fileName.trim().isEmpty || fileName == '-') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có file để xem')));
      return;
    }

    final uri = Uri.tryParse(fileName.trim());
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở đường dẫn')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi mở file: $e')));
        }
      }
    } else {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xem chi tiết'),
            content: Text(fileName),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
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
        color: const Color(0xFFF9FAFB),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 40,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    this.errorCode,
    required this.onRetry,
  });

  final String message;
  final ErrorCode? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Lỗi: $message',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
