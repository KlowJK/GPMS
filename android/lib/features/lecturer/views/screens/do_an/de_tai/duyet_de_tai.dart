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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final list = await DeTaiService.fetchApprovalList();
      setState(() { _items..clear()..addAll(list); });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onAction({
    required int index,
    required bool approve,
  }) async {
    final it = _items[index];
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    try {
      DeTaiItem updated;
      if (approve) {
        updated = await DeTaiService.approve(deTaiId: it.id, nhanXet: note.trim());
      } else {
        updated = await DeTaiService.reject(deTaiId: it.id, nhanXet: note.trim());
      }
      setState(() => _items[index] = updated); // giữ item trong list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Đã duyệt đề tài' : 'Đã từ chối đề tài')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('Danh sách đề tài'),
              const Spacer(),
              const SizedBox(width: 8),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _items.length,
              itemBuilder: (_, i) => _TopicCard(
                item: _items[i],
                onApprove: _items[i].status == TopicStatus.pending
                    ? () => _onAction(index: i, approve: true)
                    : null,
                onReject: _items[i].status == TopicStatus.pending
                    ? () => _onAction(index: i, approve: false)
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
  const _TopicCard({
    required this.item,
    this.onApprove,
    this.onReject,
  });

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header: Avatar + HỌ TÊN + MÃ SV
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Họ tên
                    Text(
                      item.studentName?.isNotEmpty == true
                          ? item.studentName!
                          : 'Sinh viên',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Mã SV
                    if ((item.studentId ?? '').isNotEmpty)
                      Text(item.studentId!,
                          style: Theme.of(context).textTheme.bodySmall),
                    // Tổng quan đề tài (URL)
                    Row(
                      children: [
                        Text('Tổng quan: ', style: Theme.of(context).textTheme.bodyMedium),
                        Flexible(
                          child: InkWell(
                            onTap: canOpenOverview
                                ? () async {
                              final uri = Uri.tryParse(overview!);
                              if (uri != null) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                                : null, // chỉ click khi là URL
                            child: Text(
                              overviewText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: canOpenOverview
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                decoration: canOpenOverview
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
          Text('Đề tài: ${item.title}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),

          Row(
            children: [
              const Text('Trạng thái: ',
                  style: TextStyle(fontWeight: FontWeight.w700)),
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
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        elevation: 0,
                      ),
                      onPressed: onReject,
                      child: const Text('Từ chối'),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        elevation: 0,
                      ),
                      onPressed: onApprove,
                      child: const Text('Duyệt'),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ]),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 36, color: Theme.of(context).disabledColor),
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
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 32),
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
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Center(
        child: Text('Nhận xét', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: c,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Đưa ra nhận xét ...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0x33000000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2F7CD3), width: 1.2),
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: 140,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F7CD3),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('Xác nhận'),
          ),
        ),
      ],
    ),
  );
}


