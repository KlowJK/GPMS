import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/services/de_tai_service.dart';
import 'package:GPMS/features/lecturer/models/de_tai_item.dart';

class DuyetDeTai extends StatefulWidget {
  const DuyetDeTai({super.key});
  @override
  State<DuyetDeTai> createState() => _DuyetDeTaiState();
}

class _DuyetDeTaiState extends State<DuyetDeTai> {
  final _items = <DeTaiItem>[];
  bool _loading = false;
  String? _error;

  // new: block duplicate requests while processing an action
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await DeTaiService.fetchApprovalList();
      if (!mounted) return; // avoid updating state when widget is gone

      setState(() {
        _items
          ..clear()
          ..addAll(list);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onAction({required int index, required bool approve}) async {
    if (_processing) return; // guard
    if (index < 0 || index >= _items.length) return;
    setState(() => _processing = true);

    final it = _items[index];
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) {
      if (mounted) setState(() => _processing = false);
      return;
    }

    try {
      if (approve) {
        await DeTaiService.approve(deTaiId: it.id, nhanXet: note.trim());
      } else {
        await DeTaiService.reject(deTaiId: it.id, nhanXet: note.trim());
      }

      // reload full list from server to reflect changes
      await _load();

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [const Text('Danh sách đề tài')]),
        ),
        Expanded(
          child: _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : (_items.isEmpty
                            ? const _EmptyView(text: 'Không có đề tài.')
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemCount: _items.length,
                                itemBuilder: (_, i) => _TopicCard(
                                  item: _items[i],
                                  // disable buttons while processing
                                  onApprove:
                                      _items[i].status == TopicStatus.pending &&
                                          !_processing
                                      ? () => _onAction(index: i, approve: true)
                                      : null,
                                  onReject:
                                      _items[i].status == TopicStatus.pending &&
                                          !_processing
                                      ? () =>
                                            _onAction(index: i, approve: false)
                                      : null,
                                ),
                              )),
                ),
        ),
      ],
    );
  }
}

VoidCallback? _maybeOpen(String? url) {
  if (url == null || url.isEmpty || !url.startsWith('http')) return null;
  return () async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  };
}


class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.item, this.onApprove, this.onReject});

  final DeTaiItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final pending = item.status == TopicStatus.pending;

    // Lấy URL tổng quan (ưu tiên theo thứ tự bạn đang dùng ở model)
    final overview = item.overviewUrl;
    final canOpenOverview = (overview ?? '').startsWith('http');
    final overviewText = (overview == null || overview.isEmpty)
        ? '—'
        : (Uri.tryParse(overview)?.pathSegments.last ?? overview);

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
              style: TextStyle(fontWeight: FontWeight.w800),
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
                          Text(
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
                ],
              ),
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
      if (uri != null)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
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
        Text('Lỗi: $message', style: Theme.of(context).textTheme.bodyMedium),
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

/// Popup nhận xét (ở giữa, styled giống mock)
Future<String?> _showCommentDialog(BuildContext context) async {
  final c = TextEditingController();
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
        ),
      ],
    ),
  );
}


