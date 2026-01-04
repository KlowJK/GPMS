import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:GPMS/features/lecturer/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

class DuyetBaoCao extends StatefulWidget {
  const DuyetBaoCao({super.key});

  @override
  State<DuyetBaoCao> createState() => _DuyetBaoCaoState();
}

class _DuyetBaoCaoState extends State<DuyetBaoCao>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load pending reports on init
      final vm = context.read<BaoCaoViewModel>();
      vm.fetchList(status: BaoCaoViewModel.STATUS_CHO_DUYET);
    });
  }

  Future<void> _handleRefresh(BaoCaoViewModel vm) async {
    try {
      await vm.fetchList(status: BaoCaoViewModel.STATUS_CHO_DUYET);
    } catch (e) {
      if (!mounted) return;

      String message = 'Không thể làm mới dữ liệu';

      if (e is CustomException) {
        switch (e.errorCode) {
          case ErrorCode.unauthenticated:
            message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
            break;
          case ErrorCode.timeout:
            message = 'Kết nối hết thời gian chờ. Vui lòng thử lại.';
            break;
          default:
            message = e.errorCode.message;
        }
      } else {
        message = 'Lỗi kết nối: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<BaoCaoViewModel>(
      builder: (context, vm, _) {
        return RefreshIndicator(
          onRefresh: () => _handleRefresh(vm),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Title with count
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Danh sách báo cáo (${vm.pendingReports.length}):',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Body
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: _buildBody(vm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BaoCaoViewModel vm) {
    // Error state
    if (vm.hasError && vm.items.isEmpty) {
      return SliverToBoxAdapter(
        child: _ErrorView(
          message: vm.error!,
          errorCode: vm.errorCode,
          onRetry: () => vm.fetchList(status: BaoCaoViewModel.STATUS_CHO_DUYET),
        ),
      );
    }

    // Loading state
    if (vm.isLoading && vm.items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Đang tải báo cáo...'),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (vm.pendingReports.isEmpty) {
      return const SliverToBoxAdapter(
        child: _EmptyView(text: 'Không có báo cáo chờ duyệt'),
      );
    }

    // List
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        final report = vm.pendingReports[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ReportCard(report: report, vm: vm),
        );
      }, childCount: vm.pendingReports.length),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.vm});

  final ReportSubmission report;
  final BaoCaoViewModel vm;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.trangThai);
    final statusText = _getStatusText(report.trangThai);

    return Card(
      elevation: 1,
      color: const Color(0xFFF1F3F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFDBEAFE),
                  child: Icon(Icons.receipt_long, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.tenDeTai ?? '-',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${report.tenSinhVien ?? '-'} - ${report.maSinhVien ?? '-'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // File link
            Row(
              children: [
                const Text('File: '),
                Flexible(
                  child: InkWell(
                    onTap: () => _launchFile(context, report.duongDanFile),
                    child: Text(
                      (report.duongDanFile ?? '').startsWith('http')
                          ? 'Xem chi tiết'
                          : '—',
                      style: TextStyle(
                        decoration:
                            (report.duongDanFile ?? '').startsWith('http')
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        color: (report.duongDanFile ?? '').startsWith('http')
                            ? Colors.blue
                            : Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Version and date
            Text(
              'Phiên bản: ${report.phienBan ?? 1}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Ngày nộp: ${_formatDate(report.ngayNop)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            // Action buttons (only for pending reports)
            if (report.trangThai == 'CHO_DUYET')
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
                      onPressed: () => _handleReject(context, vm, report),
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
                      onPressed: () => _handleApprove(context, vm, report),
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

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'CHO_DUYET':
        return const Color(0xFFFFDD00);
      case 'DA_DUYET':
        return const Color(0xFF00C409);
      case 'TU_CHOI':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'TU_CHOI':
        return 'Từ chối';
      default:
        return '-';
    }
  }

  Future<void> _launchFile(BuildContext context, String? url) async {
    if (url == null || !url.startsWith('http')) return;

    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể mở tệp')));
      }
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleReject(
    BuildContext context,
    BaoCaoViewModel vm,
    ReportSubmission report,
  ) async {
    final reason = await _showRejectDialog(context);
    if (reason == null) return;

    final id = report.id;
    if (id == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể từ chối: thiếu id báo cáo')),
        );
      }
      return;
    }

    final success = await vm.reject(idBaoCao: id, nhanXet: reason);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã từ chối báo cáo' : 'Từ chối thất bại'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleApprove(
    BuildContext context,
    BaoCaoViewModel vm,
    ReportSubmission report,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => GradeSheetDialog(
        studentName: report.tenSinhVien ?? '',
        studentId: report.maSinhVien ?? '',
        topic: report.tenDeTai ?? '',
        className: report.lop ?? '',
      ),
    );

    if (result == null) return;

    final id = report.id;
    if (id == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể duyệt: thiếu id báo cáo')),
        );
      }
      return;
    }

    final total = (result['total'] as double?) ?? 0.0;
    final comment = (result['comment'] as String?) ?? '';

    final success = await vm.approve(
      idBaoCao: id,
      diemHuongDan: total,
      nhanXet: comment.isEmpty ? null : comment,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã duyệt báo cáo' : 'Duyệt thất bại'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Nhập lý do...'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}

class GradeSheetDialog extends StatefulWidget {
  const GradeSheetDialog({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.topic,
    required this.className,
  });

  final String studentName;
  final String studentId;
  final String topic;
  final String className;

  @override
  State<GradeSheetDialog> createState() => _GradeSheetDialogState();
}

class _GradeSheetDialogState extends State<GradeSheetDialog> {
  final _f1 = TextEditingController();
  final _f2 = TextEditingController();
  final _f3 = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _total = 0;

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _commentController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _recalc() {
    setState(() {
      _total = (_parse(_f1) + _parse(_f2) + _parse(_f3)) / 3;
    });
  }

  InputDecoration _boxDec() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    border: OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Họ tên:', widget.studentName),
                _infoRow('Mã sinh viên:', widget.studentId),
                _infoRow('Lớp:', widget.className),
                const SizedBox(height: 12),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Đề tài: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: widget.topic,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 16),
                _scoreRow('Hình thức trình bày báo cáo', _f1),
                const SizedBox(height: 8),
                _scoreRow('Nội dung lý thuyết và cơ sở khoa học', _f2),
                const SizedBox(height: 8),
                _scoreRow('Mức độ nghiên cứu và phân tích', _f3),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Nhận xét',
                    hintText: 'Nhập nhận xét',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nhận xét';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7CD3),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.pop<Map<String, dynamic>>(context, {
                            'total': _total,
                            'comment': _commentController.text.trim(),
                          });
                        }
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ),
              ],
            ),
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
          child: TextFormField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _boxDec().copyWith(
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              errorMaxLines: 1,
            ),
            textAlign: TextAlign.right,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nhập điểm';
              }
              final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
              if (parsed == null) return 'Điểm không hợp lệ';
              if (parsed < 0 || parsed > 10) {
                return 'Điểm phải trong khoảng 0 - 10';
              }
              return null;
            },
            onChanged: (_) => _recalc(),
          ),
        ),
      ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
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
    );
  }
}
