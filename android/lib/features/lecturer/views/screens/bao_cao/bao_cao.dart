import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';
import 'package:GPMS/features/lecturer/models/bao_cao_item.dart';

class BaoCao extends StatefulWidget {
  const BaoCao({super.key});
  @override
  State<BaoCao> createState() => _BaoCaoState();
}

class _BaoCaoState extends State<BaoCao> {
  final _items = <BaoCaoItem>[];
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
      final list = await BaoCaoService.fetchList();
      // Ưu tiên "chưa nộp" nằm trên
      list.sort((a, b) {
        int w(ReportSubmitStatus s) =>
            s == ReportSubmitStatus.notSubmitted ? 0 : 1;
        return w(a.trangThai).compareTo(w(b.trangThai));
      });
      setState(() { _items..clear()..addAll(list); });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2F7CD3);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,       // bỏ mũi tên back
        title: const Text('Báo cáo'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header thời hạn: giữ nguyên block cũ của bạn nếu muốn
            // ...

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Danh sách sinh viên:',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
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
                    ? const _EmptyView(text: 'Không có dữ liệu.')
                    : ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _StudentCard(info: _items[i]),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card hiển thị theo đúng layout của bạn (tên + mã SV cạnh nhau, lớp bên phải, "Đề tài:" in đậm)
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info});
  final BaoCaoItem info;

  Color _statusColor(ReportSubmitStatus s) =>
      s == ReportSubmitStatus.submitted ? const Color(0xFF00C409) : const Color(0xFFFFDD00);

  String _statusText(ReportSubmitStatus s) =>
      s == ReportSubmitStatus.submitted ? 'đã nộp' : 'chưa nộp';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFDBEAFE),
                  child: Icon(Icons.person, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                // Tên + mã SV cạnh nhau
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          info.hoTen,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        info.maSV,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(info.tenLop, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Trạng thái: '),
                Text(
                  _statusText(info.trangThai),
                  style: TextStyle(
                    color: _statusColor(info.trangThai),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                      text: 'Đề tài: ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: info.deTai),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline,
              size: 36, color: Theme.of(context).disabledColor),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 16),
      Icon(Icons.error_outline,
          color: Theme.of(context).colorScheme.error, size: 32),
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
