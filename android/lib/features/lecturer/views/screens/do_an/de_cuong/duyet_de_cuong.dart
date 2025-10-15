import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:GPMS/features/lecturer/services/de_cuong_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DuyetDeCuong extends StatefulWidget {
  const DuyetDeCuong({super.key});
  @override
  State<DuyetDeCuong> createState() => _DuyetDeCuongState();
}

class _DuyetDeCuongState extends State<DuyetDeCuong> {
  final _items = <DeCuongItem>[];
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
      final list = await DeCuongService.list();

      // SẮP XẾP: pending trước, sau đó tới approved, rejected (không lọc)
      list.sort((a, b) {
        int w(DeCuongStatus s) =>
            s == DeCuongStatus.pending ? 0 : (s == DeCuongStatus.approved ? 1 : 2);
        final c = w(a.status).compareTo(w(b.status));
        return c != 0 ? c : (b.ngayNop ?? DateTime(0)).compareTo(a.ngayNop ?? DateTime(0));
      });

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
      DeCuongItem updated;
      if (approve) {
        updated = await DeCuongService.approve(id: it.id, nhanXet: note.trim());
      } else {
        updated = await DeCuongService.reject(id: it.id, nhanXet: note.trim());
      }
      setState(() => _items[index] = updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Đã duyệt đề cương' : 'Đã từ chối đề cương')),
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
              const Text('Danh sách đề cương'),
              const Spacer(),
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
                ? const _EmptyView(text: 'Không có đề cương.')
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _items.length,
              itemBuilder: (_, i) => _DeCuongCard(
                item: _items[i],
                onApprove: _items[i].status == DeCuongStatus.pending
                    ? () => _onAction(index: i, approve: true)
                    : null,
                onReject: _items[i].status == DeCuongStatus.pending
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

class _DeCuongCard extends StatelessWidget {
  const _DeCuongCard({
    required this.item,
    this.onApprove,
    this.onReject,
  });

  final DeCuongItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = item.status == DeCuongStatus.pending;

    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SV
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
                  Text(item.maSV!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),

            if (item.ngayNop != null) ...[
              Row(
                children: [
                  Text('Ngày nộp: ', style: Theme.of(context).textTheme.bodyMedium),
                  Text(_fmt(item.ngayNop)),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if ((item.fileName ?? '').isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File: ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: InkWell(
                      onTap: _maybeOpen(item.fileName),
                      child: Text(
                        item.fileName ?? '—',
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
            ],

            // Trạng thái (hiển thị cho mọi trạng thái)
            Row(
              children: [
                Text('Trạng thái: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  deCuongStatusText(item.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: deCuongStatusColor(item.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if ((item.nhanXet ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Nhận xét: ${item.nhanXet}'),
            ],

            // Nút chỉ hiện khi đang chờ duyệt
            if (pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // đỏ
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
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E), // xanh lá
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
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
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

/// Popup nhận xét
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
