import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';
import 'package:GPMS/features/lecturer/viewmodels/de_cuong_viewmodel.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

class DuyetDeCuong extends StatefulWidget {
  const DuyetDeCuong({super.key});

  @override
  State<DuyetDeCuong> createState() => _DuyetDeCuongState();
}

class _DuyetDeCuongState extends State<DuyetDeCuong>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _handleRefresh(DeCuongViewModel vm) async {
    try {
      await vm.fetchList();
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

    return Consumer<DeCuongViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Danh sách đề cương (${vm.pendingItems.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(vm)),
          ],
        );
      },
    );
  }

  Widget _buildBody(DeCuongViewModel vm) {
    // Error state
    if (vm.hasError && vm.items.isEmpty) {
      return _ErrorView(
        message: vm.error!,
        errorCode: vm.errorCode,
        onRetry: () => vm.retryList(),
      );
    }

    // Loading state
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (vm.items.isEmpty) {
      return const _EmptyView(text: 'Không có đề cương chờ duyệt.');
    }

    // List with refresh
    return RefreshIndicator(
      onRefresh: () => _handleRefresh(vm),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: vm.items.length,
        itemBuilder: (_, i) {
          final item = vm.items[i];
          return _DeCuongCard(
            item: item,
            onApprove: item.status == DeCuongStatus.pending && !vm.isProcessing
                ? () => _handleApprove(vm, item)
                : null,
            onReject: item.status == DeCuongStatus.pending && !vm.isProcessing
                ? () => _handleReject(vm, item)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleApprove(DeCuongViewModel vm, DeCuongItem item) async {
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    final success = await vm.approveDeCuong(id: item.id, nhanXet: note.trim());

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt đề cương thành công')),
      );
    } else {
      _showError(vm);
    }
  }

  Future<void> _handleReject(DeCuongViewModel vm, DeCuongItem item) async {
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    final success = await vm.rejectDeCuong(id: item.id, nhanXet: note.trim());

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã từ chối đề cương')));
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
    } else if (vm.errorCode == ErrorCode.noInternet) {
      message = 'Không có kết nối mạng';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DeCuongCard extends StatelessWidget {
  const _DeCuongCard({required this.item, this.onApprove, this.onReject});

  final DeCuongItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String? _getProp(dynamic obj, String key) {
    if (obj == null) return null;
    try {
      if (obj is Map) return obj[key]?.toString();
      final dyn = obj as dynamic;
      if (key == 'noiDung') return dyn.noiDung?.toString();
      if (key == 'nguoiNhanXet') return dyn.nguoiNhanXet?.toString();
    } catch (_) {
      try {
        if (obj is Map) return obj[key]?.toString();
      } catch (_) {}
    }
    return null;
  }

  String _detectPrefix(DeCuongItem item, dynamic nx) {
    final advisor = item.hoTenGiangVienHuongDan?.toLowerCase().trim();
    final reviewer = item.hoTenGiangVienPhanBien?.toLowerCase().trim();
    final head = item.hoTenTruongBoMon?.toLowerCase().trim();

    final author = (_getProp(nx, 'nguoiNhanXet') ?? '').toLowerCase().trim();
    if (author.isEmpty) return '';

    if (advisor != null && advisor.isNotEmpty && author == advisor)
      return 'GVHD';
    if (reviewer != null && reviewer.isNotEmpty && author == reviewer)
      return 'GVPB';
    if (head != null && head.isNotEmpty && author == head) return 'TBM';

    if (author.contains('huong') || author.contains('gvhd')) return 'GVHD';
    if (author.contains('phan') || author.contains('gpb')) return 'GVPB';
    if (author.contains('truong') || author.contains('tbm')) return 'TBM';

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final pending = item.status == DeCuongStatus.pending;
    final hasList = item.nhanXets != null && item.nhanXets!.isNotEmpty;
    final hasSingle = (item.nhanXet ?? '').isNotEmpty;

    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.sinhVienTen ?? 'Sinh viên',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if ((item.maSV ?? '').isNotEmpty)
                  Text(
                    item.maSV!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Phiên bản: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text('${item.lanNop}'),
              ],
            ),
            Row(
              children: [
                Text(
                  'Ngày nộp: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(_fmt(item.ngayNop)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File: ', style: Theme.of(context).textTheme.bodyMedium),
                Expanded(
                  child: InkWell(
                    onTap: _maybeOpen(item.fileName),
                    child: Text(
                      (item.fileName ?? '').startsWith('http')
                          ? 'Xem chi tiết'
                          : '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (item.fileName ?? '').startsWith('http')
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        decoration: (item.fileName ?? '').startsWith('http')
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Trạng thái: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  deCuongStatusText(item.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: deCuongStatusColor(item.status),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.nhanXets!.map((nx) {
                    final prefix = _detectPrefix(item, nx);
                    final content = _getProp(nx, 'noiDung') ?? '—';
                    final displayed = prefix.isNotEmpty
                        ? '$prefix: $content'
                        : content;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        displayed,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                )
              else
                Builder(
                  builder: (ctx) {
                    final fakeNx = {
                      'nguoiNhanXet': '',
                      'noiDung': item.nhanXet,
                    };
                    final prefix = _detectPrefix(item, fakeNx);
                    final displayed = prefix.isNotEmpty
                        ? '$prefix: ${item.nhanXet}'
                        : (item.nhanXet ?? '—');
                    return Text(
                      displayed,
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 36,
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'Lỗi: $message',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      ],
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
