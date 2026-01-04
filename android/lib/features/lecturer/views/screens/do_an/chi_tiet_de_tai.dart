import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';
import 'package:GPMS/features/lecturer/viewmodels/de_cuong_viewmodel.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/models/chi_tiet_de_tai_args.dart';

class ChiTietDeTai extends StatefulWidget {
  const ChiTietDeTai({super.key, required this.data});
  final ChiTietDeTaiArgs data;

  @override
  State<ChiTietDeTai> createState() => _ChiTietDeTaiState();
}

class _ChiTietDeTaiState extends State<ChiTietDeTai> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DeCuongViewModel>();
      vm.fetchStudentLogs(widget.data.maSV);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeCuongViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text('Thông tin chi tiết'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const SizedBox(height: 8),

                // Student info card
                _StudentInfoCard(data: widget.data),

                const SizedBox(height: 12),
                Text(
                  'Đề cương của sinh viên:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Logs section
                _buildLogsSection(vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogsSection(DeCuongViewModel vm) {
    // Loading
    if (vm.isLoadingLogs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error
    if (vm.hasLogsError) {
      return _ErrorBox(
        message: vm.logsError!,
        errorCode: vm.logsErrorCode,
        onRetry: () => vm.fetchStudentLogs(widget.data.maSV),
      );
    }

    // Empty
    if (vm.studentLogs.isEmpty) {
      return _EmptyBox(text: 'Chưa có đề cương nào.');
    }

    // List
    return Column(
      children: vm.studentLogs
          .asMap()
          .entries
          .map(
            (entry) => _LogItem(
              log: entry.value,
              onApprove:
                  entry.value.status == DeCuongStatus.pending &&
                      !vm.isProcessing
                  ? () => _handleApprove(vm, entry.value)
                  : null,
              onReject:
                  entry.value.status == DeCuongStatus.pending &&
                      !vm.isProcessing
                  ? () => _handleReject(vm, entry.value)
                  : null,
            ),
          )
          .toList(),
    );
  }

  Future<void> _handleApprove(DeCuongViewModel vm, DeCuongItem log) async {
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    final success = await vm.approveDeCuong(id: log.id, nhanXet: note.trim());

    if (!mounted) return;

    if (success) {
      // Reload logs
      await vm.fetchStudentLogs(widget.data.maSV);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã duyệt đề cương')));
      }
    } else {
      _showError(vm);
    }
  }

  Future<void> _handleReject(DeCuongViewModel vm, DeCuongItem log) async {
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    final success = await vm.rejectDeCuong(id: log.id, nhanXet: note.trim());

    if (!mounted) return;

    if (success) {
      // Reload logs
      await vm.fetchStudentLogs(widget.data.maSV);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã từ chối đề cương')));
      }
    } else {
      _showError(vm);
    }
  }

  void _showError(DeCuongViewModel vm) {
    String message = vm.error ?? 'Có lỗi xảy ra';

    if (vm.errorCode == ErrorCode.unauthenticated) {
      message = 'Phiên đăng nhập hết hạn';
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    } else if (vm.errorCode == ErrorCode.timeout) {
      message = 'Kết nối hết thời gian chờ. Vui lòng thử lại.';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard({required this.data});
  final ChiTietDeTaiArgs data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Đề tài: ${data.tenDeTai.isEmpty ? "—" : data.tenDeTai}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Họ tên', value: data.hoTen),
            _Divider(),
            _InfoRow(label: 'Mã sinh viên', value: data.maSV),
            _Divider(),
            _InfoRow(label: 'Lớp', value: data.tenLop),
            _Divider(),
            _InfoRow(label: 'Số điện thoại', value: data.soDienThoai),
            _Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CV: ', style: Theme.of(context).textTheme.bodyMedium),
                Expanded(
                  child: InkWell(
                    onTap: _maybeOpen(data.cvUrl),
                    child: Builder(
                      builder: (context) {
                        final url = data.cvUrl ?? '';
                        final hasHttp = url.startsWith('http');
                        final display = hasHttp
                            ? 'Xem chi tiết'
                            : (url.isEmpty ? '—' : url.split('/').last);
                        return Text(
                          display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: hasHttp
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                decoration: hasHttp
                                    ? TextDecoration.underline
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _maybeOpen(String? url) {
    if (url == null || url.isEmpty || !url.startsWith('http')) return null;
    return () async {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    };
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem({required this.log, this.onApprove, this.onReject});

  final DeCuongItem log;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = log.status == DeCuongStatus.pending;
    final hasList = log.nhanXets != null && log.nhanXets!.isNotEmpty;
    final hasSingle = (log.nhanXet ?? '').isNotEmpty;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: ${log.lanNop ?? '—'}'),
            const SizedBox(height: 2),
            Text('Ngày nộp: ${_fmt(log.ngayNop)}'),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('File: '),
                Expanded(
                  child: InkWell(
                    onTap: _maybeOpen(log.fileName),
                    child: Text(
                      (log.fileName ?? '').startsWith('http')
                          ? 'Xem chi tiết'
                          : '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (log.fileName ?? '').startsWith('http')
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        decoration: (log.fileName ?? '').startsWith('http')
                            ? TextDecoration.underline
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('Trạng thái: '),
                Text(
                  deCuongStatusText(log.status),
                  style: TextStyle(
                    color: deCuongStatusColor(log.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (hasList || hasSingle) ...[
              const SizedBox(height: 8),
              Text('Nhận xét:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 6),
              if (hasList)
                ...log.nhanXets!.map(
                  (nx) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(nx.noiDung ?? '—'),
                  ),
                )
              else
                Text(log.nhanXet ?? '—'),
            ],
            if (pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Duyệt'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  VoidCallback? _maybeOpen(String? url) {
    if (url == null || url.isEmpty || !url.startsWith('http')) return null;
    return () async {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 16, color: Theme.of(context).dividerColor);
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).disabledColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({
    required this.message,
    this.errorCode,
    required this.onRetry,
  });

  final String message;
  final ErrorCode? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lỗi: $message'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _showCommentDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Nhận xét'),
        content: TextField(
          controller: controller,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Nhập nhận xét bắt buộc...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isEmpty) return;
              Navigator.pop(ctx, t);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      );
    },
  );
}
