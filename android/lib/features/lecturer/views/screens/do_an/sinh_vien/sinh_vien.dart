import 'dart:async';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/services/sinh_vien_service.dart';
import 'package:GPMS/features/lecturer/models/sinh_vien_item.dart';
import '../chi_tiet_de_tai.dart';

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => _SinhVienTabState();
}

class _SinhVienTabState extends State<SinhVienTab> {
  final _items = <SinhVienItem>[];
  bool _loading = false;
  String? _error;

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) _items.clear();
    });

    try {
      final list = await SinhVienService.fetchList(); // ⬅️ dùng list, không phân trang
      setState(() {
        _items
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _showSubmitConfirm() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [Icon(Icons.help, color: Color(0xFF1E40AF)), SizedBox(width: 8), Text('Xác nhận')],
        ),
        content: const Text('Bạn có chắc chắn muốn gửi danh sách đề tài hướng dẫn không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Quay lại')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi danh sách (mock). Bạn nối API sau nhé.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header + nút nộp danh sách + refresh
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Danh sách sinh viên (${_items.length}+):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              FilledButton.icon(
                onPressed: _showSubmitConfirm,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Nộp danh sách'),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF26A65B)),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
            onRefresh: _load,
            child: _loading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final it = _items[i];
                return _StudentCard(
                  item: it,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChiTietDeTai(
                          data: ChiTietDeTaiArgs(
                            maSV: it.maSV,
                            hoTen: it.hoTen,
                            tenLop: it.tenLop ?? '',
                            soDienThoai: it.soDienThoai ?? '',
                            tenDeTai: it.tenDeTai ?? '',
                            cvUrl: it.cvUrl ?? '',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item, required this.onTap});

  final SinhVienItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8, runSpacing: 2,
                    children: [
                      Text(item.hoTen, style: Theme.of(context).textTheme.titleMedium),
                      Text(item.maSV, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      if ((item.tenLop ?? '').isNotEmpty)
                        Text(item.tenLop!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              Text('CV: ', style: Theme.of(context).textTheme.bodyMedium),
              Flexible(
                child: Text(
                  (item.cvUrl ?? '').isEmpty ? '—' : (item.cvUrl!.split('/').last),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: (item.cvUrl ?? '').isEmpty ? TextDecoration.none : TextDecoration.underline,
                  ),
                ),
              ),
            ]),
            if ((item.tenDeTai ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Đề tài: ${item.tenDeTai}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ]),
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
        FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
      ],
    );
  }
}
