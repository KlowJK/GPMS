import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/show_review_dialog.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/weekly_entry.dart';

class NhanXetTienDoTab extends StatefulWidget {
  const NhanXetTienDoTab({super.key});

  @override
  State<NhanXetTienDoTab> createState() => _NhanXetTienDoTabState();
}

class _NhanXetTienDoTabState extends State<NhanXetTienDoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Use existing ViewModel
      final vm = context.read<TienDoViewModel>();
      vm.fetchMySupervisedStudents(status: 'DA_NOP');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<TienDoViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => vm.fetchMySupervisedStudents(status: 'DA_NOP'),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Title
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 17, 12, 10),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Nhận xét tiến độ sinh viên',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),

                // Body
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  sliver: _buildBody(vm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(TienDoViewModel vm) {
    // Error state
    if (vm.hasSupervisedError && vm.supervisedStudents.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _ErrorView(
          message: vm.supervisedError!,
          errorCode: vm.supervisedErrorCode,
          onRetry: () => vm.fetchMySupervisedStudents(status: 'DA_NOP'),
        ),
      );
    }

    // Loading state
    if (vm.isLoadingSupervised && vm.supervisedStudents.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Convert to entries
    final entries = _convertToEntries(vm.supervisedStudents);

    // Empty state
    if (entries.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyView(text: 'Chưa có nhật ký cần nhận xét'),
      );
    }

    // List
    return SliverList.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _WeekCard(
        entry: entries[i],
        onReview: () => _handleReview(vm, entries[i]),
      ),
    );
  }

  List<WeeklyEntry> _convertToEntries(List<TienDoSinhVien> items) {
    return items.map((t) {
      return WeeklyEntry(
        id: t.id,
        studentName: t.hoTen,
        weekLabel: 'Tuần ${t.tuan ?? ''}',
        dateRange:
            '${_formatDate(t.ngayBatDau)}${t.ngayKetThuc != null ? ' - ${_formatDate(t.ngayKetThuc)}' : ''}',
        work: t.noiDung ?? '-',
        fileName: t.duongDanFile ?? '-',
        status: t.trangThaiNhatKy,
        review: t.nhanXet,
      );
    }).toList();
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
        studentName: entry.studentName ?? '',
        weekLabel: entry.weekLabel,
        entryId: entry.id!,
        initialReview: entry.review,
        onSubmit: (id, nhanXet) async {
          await vm.approveReport(id: id, nhanXet: nhanXet);
        },
      ),
    );

    if (success == true && mounted) {
      await vm.fetchMySupervisedStudents(status: 'DA_NOP');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu nhận xét cho ${entry.studentName ?? ''} - ${entry.weekLabel}',
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
                if (entry.studentName != null)
                  _rowLabelValue('Sinh viên: ', entry.studentName!),
                const SizedBox(height: 6),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
