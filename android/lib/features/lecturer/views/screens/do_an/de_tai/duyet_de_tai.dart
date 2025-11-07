import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/models/de_tai_item.dart';
import 'package:GPMS/features/lecturer/viewmodels/de_tai_viewmodel.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

class DuyetDeTai extends StatefulWidget {
  const DuyetDeTai({super.key});

  @override
  State<DuyetDeTai> createState() => _DuyetDeTaiState();
}

class _DuyetDeTaiState extends State<DuyetDeTai>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _handleRefresh(DeTaiViewModel vm) async {
    try {
      await vm.fetchApprovalList();
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

    return Consumer<DeTaiViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Danh sách đề tài (${vm.pendingItems.length})',
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

  Widget _buildBody(DeTaiViewModel vm) {
    // Error state
    if (vm.hasError && vm.items.isEmpty) {
      return _ErrorView(
        message: vm.error!,
        errorCode: vm.errorCode,
        onRetry: () => vm.retry(),
      );
    }

    // Loading state
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (vm.items.isEmpty) {
      return const _EmptyView(text: 'Không có đề tài chờ duyệt.');
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
          return _TopicCard(
            item: item,
            onApprove: item.status == TopicStatus.pending && !vm.isProcessing
                ? () => _handleApprove(vm, item)
                : null,
            onReject: item.status == TopicStatus.pending && !vm.isProcessing
                ? () => _handleReject(vm, item)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleApprove(DeTaiViewModel vm, DeTaiItem item) async {
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    final success = await vm.approveDeTai(
      deTaiId: item.id,
      nhanXet: note.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt đề tài thành công')),
      );
    } else {
      _showError(vm);
    }
  }

  Future<void> _handleReject(DeTaiViewModel vm, DeTaiItem item) async {
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    final success = await vm.rejectDeTai(
      deTaiId: item.id,
      nhanXet: note.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã từ chối đề tài')));
    } else {
      _showError(vm);
    }
  }

  void _showError(DeTaiViewModel vm) {
    String message = vm.error ?? 'Có lỗi xảy ra';

    if (vm.errorCode == ErrorCode.unauthenticated) {
      message = 'Phiên đăng nhập hết hạn';
      // Navigate to login
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

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.item, this.onApprove, this.onReject});

  final DeTaiItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final pending = item.status == TopicStatus.pending;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName ?? 'Sinh viên',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            'CV: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Flexible(
                            child: InkWell(
                              onTap: _maybeOpen(item.duongDanCv),
                              child: Text(
                                (item.duongDanCv ?? '').startsWith('http')
                                    ? 'Xem chi tiết'
                                    : '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          (item.duongDanCv ?? '').startsWith(
                                            'http',
                                          )
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : null,
                                      decoration:
                                          (item.duongDanCv ?? '').startsWith(
                                            'http',
                                          )
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Đề tài: ${item.title}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'File tổng quan: ',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Flexible(
                            child: InkWell(
                              onTap: _maybeOpen(item.overviewFileName),
                              child: Text(
                                (item.overviewFileName ?? '').startsWith('http')
                                    ? 'Xem chi tiết'
                                    : '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          (item.overviewFileName ?? '')
                                              .startsWith('http')
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : null,
                                      decoration:
                                          (item.overviewFileName ?? '')
                                              .startsWith('http')
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'Trạng thái: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  switch (item.status) {
                    TopicStatus.approved => 'Đã duyệt',
                    TopicStatus.rejected => 'Đã từ chối',
                    TopicStatus.pending => 'Đang chờ duyệt',
                  },
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: switch (item.status) {
                      TopicStatus.approved => const Color(0xFF16A34A),
                      TopicStatus.rejected => const Color(0xFFDC2626),
                      TopicStatus.pending => const Color(0xFFC9B325),
                    },
                  ),
                ),
              ],
            ),
            if ((item.comment ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Nhận xét: ${item.comment}'),
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

/// Popup nhận xét ở GIỮA màn hình
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
