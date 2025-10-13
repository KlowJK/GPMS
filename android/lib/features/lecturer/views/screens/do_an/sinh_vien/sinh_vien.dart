import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:GPMS/features/lecturer/models/sinh_vien_item.dart';
import 'package:GPMS/features/lecturer/services/sinh_vien_service.dart';
import 'package:GPMS/features/lecturer/views/screens/do_an/chi_tiet_de_tai.dart';

/// Helper: ép String? -> String hiển thị gọn gàng
String _txt(String? s, {String fb = '—'}) =>
    (s == null || s.trim().isEmpty) ? fb : s.trim();

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => _SinhVienTabState();
}

class _SinhVienTabState extends State<SinhVienTab> {
  final _items = <SinhVienItem>[];
  bool _loading = false;
  String? _error;

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
      final list = await SinhVienService.fetch(); // GET /api/giang-vien/sinh-vien
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Danh sách sinh viên (${_items.length}+):',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
            onRefresh: _load,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_items.isEmpty
                ? const _EmptyCenter(text: 'Không có sinh viên.')
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: _items.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final it = _items[i];
                return _SinhVienCard(
                  item: it,
                  onTap: () {
                    // Điều hướng sang màn chi tiết đề tài
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChiTietDeTai(
                          data: ChiTietDeTaiArgs(
                            maSV: _txt(it.maSV),
                            hoTen: _txt(it.hoTen),
                            tenLop: _txt(it.tenLop),
                            soDienThoai: _txt(it.soDienThoai),
                            tenDeTai: _txt(it.tenDeTai),
                            cvUrl: it.cvUrl,
                            sinhVienId: it.id,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )),
          ),
        ),
      ],
    );
  }
}

class _SinhVienCard extends StatelessWidget {
  const _SinhVienCard({required this.item, this.onTap});

  final SinhVienItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cvText = (item.cvUrl == null || item.cvUrl!.isEmpty)
        ? 'CV: —'
        : 'CV: ${Uri.tryParse(item.cvUrl!)?.pathSegments.last ?? item.cvUrl!}';

    final canOpenCV = (item.cvUrl ?? '').startsWith('http');

    return Material(
      color: const Color(0xFFE6F2FF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFDBEAFE),
                child: Icon(Icons.person, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng 1: Tên + Mã SV
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _txt(item.hoTen, fb: 'Sinh viên'),
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _txt(item.maSV),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Dòng 2: Lớp + CV (bên phải)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _txt(item.tenLop),
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: InkWell(
                            onTap: canOpenCV ? _open(item.cvUrl!) : null,
                            child: Text(
                              cvText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: canOpenCV
                                    ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    : null,
                                decoration: canOpenCV
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

                    // Dòng 3: Đề tài
                    Text(
                      'Đề tài: ${_txt(item.tenDeTai)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback _open(String url) {
    return () async {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    };
  }
}

class _EmptyCenter extends StatelessWidget {
  const _EmptyCenter({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            Icon(Icons.info_outline,
                size: 40, color: Theme.of(context).disabledColor),
            const SizedBox(height: 8),
            Text(text),
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
        const SizedBox(height: 24),
        Icon(Icons.error_outline,
            color: Theme.of(context).colorScheme.error, size: 36),
        const SizedBox(height: 8),
        Text('Lỗi: $message'),
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
