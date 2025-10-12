import 'dart:async';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/services/de_cuong_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

class DuyetDeCuong extends StatefulWidget {
  const DuyetDeCuong({super.key});
  @override
  State<DuyetDeCuong> createState() => _DuyetDeCuongState();
}

class _DuyetDeCuongState extends State<DuyetDeCuong> {
  final _items = <DeCuongItem>[];
  final _scroll = ScrollController();
  bool _loading = false;
  String? _error;
  int _page = 0;
  final int _size = 10;
  bool _last = false;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(() {
      if (_loading || _last) return;
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 160) {
        _load();
      }
    });
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true; _error = null;
      if (reset) { _page = 0; _last = false; _items.clear(); }
    });

    try {
      final raw = await DeCuongService.fetchPage(page: _page, size: _size);
      final page = (raw['result'] as Map<String, dynamic>);
      final content = List<Map<String, dynamic>>.from(page['content'] ?? []);
      final mapped = content.map(DeCuongItem.fromJson).toList();
      setState(() {
        _items.addAll(mapped);
        _last = (page['last'] as bool?) ?? true;
        _page++;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveOrReject({
    required int id,
    required bool approve,
    required int index,
  }) async {
    final note = await _showCommentSheet(context);
    if (note == null || note.trim().isEmpty) return;

    try {
      final res = approve
          ? await DeCuongService.approve(id: id, nhanXet: note.trim())
          : await DeCuongService.reject(id: id, nhanXet: note.trim());
      final updated = DeCuongItem.fromJson(Map<String, dynamic>.from(res['result']));
      setState(() => _items[index] = updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Đã duyệt đề cương' : 'Đã từ chối đề cương')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
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
              IconButton(onPressed: () => _load(reset: true), icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
        Expanded(
          child: _error != null
              ? _ErrorView(message: _error!, onRetry: () => _load(reset: true))
              : RefreshIndicator(
            onRefresh: () => _load(reset: true),
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (_loading && i == _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final it = _items[i];
                return _DeCuongCard(
                  item: it,
                  onApprove: it.status == DeCuongStatus.pending
                      ? () => _approveOrReject(id: it.id, approve: true, index: i)
                      : null,
                  onReject: it.status == DeCuongStatus.pending
                      ? () => _approveOrReject(id: it.id, approve: false, index: i)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(spacing: 8, runSpacing: 2, children: [
                Text(item.sinhVienTen ?? 'Sinh viên', style: Theme.of(context).textTheme.titleMedium),
                if ((item.maSV ?? '').isNotEmpty)
                  Text(item.maSV!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('Ngày nộp: ', style: Theme.of(context).textTheme.bodyMedium),
            Text(_fmt(item.ngayNop)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text('File: ', style: Theme.of(context).textTheme.bodyMedium),
            Flexible(
              child: Text(item.fileName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: (item.fileName ?? '').isEmpty ? TextDecoration.none : TextDecoration.underline,
                  )),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text('Trạng thái: ', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              deCuongStatusText(item.status),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: deCuongStatusColor(item.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
          if ((item.nhanXet ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Nhận xét: ${item.nhanXet}'),
          ],
          const SizedBox(height: 12),
          if (item.status == DeCuongStatus.pending)
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                    onPressed: onReject, icon: const Icon(Icons.close), label: const Text('Từ chối')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1D4ED8), foregroundColor: Colors.white),
                    onPressed: onApprove, icon: const Icon(Icons.check), label: const Text('Duyệt')),
              ),
            ]),
        ]),
      ),
    );
  }
}

Future<String?> _showCommentSheet(BuildContext context) async {
  final controller = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      final bottom = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Nhận xét', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 6, maxLines: 10,
            decoration: InputDecoration(hintText: 'Nhập nhận xét bắt buộc...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {
            final t = controller.text.trim();
            if (t.isEmpty) return;
            Navigator.pop(context, t);
          }, child: const Text('Xác nhận')),
        ]),
      );
    },
  );
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
        FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
      ],
    );
  }
}
