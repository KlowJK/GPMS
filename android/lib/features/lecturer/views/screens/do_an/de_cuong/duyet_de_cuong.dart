import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/services/de_cuong_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

Color deCuongStatusColor(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.approved:
      return const Color(0xFF16A34A); // xanh lá
    case DeCuongStatus.rejected:
      return const Color(0xFFDC2626); // đỏ
    case DeCuongStatus.pending:
    default:
      return const Color(0xFFF59E0B); // vàng
  }
}

String deCuongStatusText(DeCuongStatus s) {
  switch (s) {
    case DeCuongStatus.approved:
      return 'Đã duyệt';
    case DeCuongStatus.rejected:
      return 'Từ chối';
    case DeCuongStatus.pending:
    default:
      return 'Đang chờ duyệt';
  }
}

class DuyetDeCuong extends StatefulWidget {
  const DuyetDeCuong({super.key});
  @override
  State<DuyetDeCuong> createState() => _DuyetDeCuongState();
}

class _DuyetDeCuongState extends State<DuyetDeCuong> {
  final _items = <DeCuongItem>[];
  bool _loading = false;
  String? _error;

  // new: prevent duplicate requests while an action is running
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await DeCuongService.list();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(list);
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
    if (_processing) return;
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
        await DeCuongService.approve(id: it.id, nhanXet: note.trim());
      } else {
        await DeCuongService.reject(id: it.id, nhanXet: note.trim());
      }

      // reload full list from server to reflect changes
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Đã duyệt đề cương' : 'Đã từ chối đề cương'),
        ),
      );
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
          child: Row(
            children: [const Text('Danh sách đề cương'), const Spacer()],
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemCount: _items.length,
                                itemBuilder: (_, i) => _DeCuongCard(
                                  item: _items[i],
                                  onApprove:
                                      _items[i].status ==
                                              DeCuongStatus.pending &&
                                          !_processing
                                      ? () => _onAction(index: i, approve: true)
                                      : null,
                                  onReject:
                                      _items[i].status ==
                                              DeCuongStatus.pending &&
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

// dart
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

  // safe property getter for dynamic nx (supports Map or object)
  String? _getProp(dynamic obj, String key) {
    if (obj == null) return null;
    try {
      if (obj is Map) return obj[key]?.toString();
      // try dynamic property access
      final dyn = obj as dynamic;
      final val = dyn.noiDung; // will throw if property missing for other keys
      if (key == 'noiDung') return val?.toString();
      if (key == 'nguoiNhanXet') return (dyn.nguoiNhanXet)?.toString();
    } catch (_) {
      try {
        if (obj is Map) return obj[key]?.toString();
      } catch (_) {}
    }
    return null;
  }

  // detect prefix (GVHD / GVPB / TBM) based on item roles and nx author string
  String _detectPrefix(DeCuongItem item, dynamic nx) {
    final advisor = item.hoTenGiangVienHuongDan
        ?.toString()
        .toLowerCase()
        .trim();
    final reviewer = item.hoTenGiangVienPhanBien
        ?.toString()
        .toLowerCase()
        .trim();
    final head = item.hoTenTruongBoMon?.toString().toLowerCase().trim();

    final author = (_getProp(nx, 'nguoiNhanXet') ?? '').toLowerCase().trim();
    if (author.isEmpty) return '';

    if (advisor != null && advisor.isNotEmpty && author == advisor)
      return 'GVHD';
    if (reviewer != null && reviewer.isNotEmpty && author == reviewer)
      return 'GVPB';
    if (head != null && head.isNotEmpty && author == head) return 'TBM';

    if (author.contains('huong') ||
        author.contains('gvhd') ||
        author.contains('hd'))
      return 'GVHD';
    if (author.contains('phan') ||
        author.contains('gpb') ||
        author.contains('pb'))
      return 'GVPB';
    if (author.contains('truong') ||
        author.contains('tbm') ||
        author.contains('bộ môn') ||
        author.contains('bo mon'))
      return 'TBM';

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
            // SV
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      // TÊN (ưu tiên width, có ellipsis)
                      Expanded(
                        child: Text(
                          item.sinhVienTen ?? 'Sinh viên',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((item.maSV ?? '').isNotEmpty) ...[
                        const SizedBox(width: 8),
                        // MÃ SV (xám nhạt, cùng dòng với tên)
                        Text(
                          item.maSV!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
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
              const SizedBox(height: 2),
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
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayed,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                        ],
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

            // Nút chỉ hiện khi đang chờ duyệt
            if (pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                      child: const Text('Từ chối'),
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

/// Popup nhận xét
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
