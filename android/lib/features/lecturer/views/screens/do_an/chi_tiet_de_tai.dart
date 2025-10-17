import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/lecturer/services/de_cuong_service.dart';
import 'package:GPMS/features/lecturer/models/de_cuong_item.dart';

/// Dữ liệu truyền vào màn chi tiết (có kèm sinhVienId để load log)
class ChiTietDeTaiArgs {
  final String maSV;
  final String hoTen;
  final String tenLop;
  final String soDienThoai;
  final String tenDeTai;
  final String? cvUrl;
  final int? sinhVienId;

  const ChiTietDeTaiArgs({
    required this.maSV,
    required this.hoTen,
    required this.tenLop,
    required this.soDienThoai,
    required this.tenDeTai,
    this.cvUrl,
    this.sinhVienId,
  });
}

class ChiTietDeTai extends StatefulWidget {
  const ChiTietDeTai({super.key, required this.data});
  final ChiTietDeTaiArgs data;

  @override
  State<ChiTietDeTai> createState() => _ChiTietDeTaiState();
}

class _ChiTietDeTaiState extends State<ChiTietDeTai> {
  var _logs = <DeCuongItem>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  int? _resolveSinhVienId() {
    // Ưu tiên id được truyền sẵn
    if (widget.data.sinhVienId != null) return widget.data.sinhVienId;
    // Fallback: thử parse từ mã SV (nếu là số)
    final id = int.tryParse(widget.data.maSV);
    return id;
  }

  Future<void> _loadLogs() async {
    if (_loading) return;
    final svId = _resolveSinhVienId();
    if (svId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ⬇️ Dùng THAM SỐ VỊ TRÍ (Cách B)
      final list = await DeCuongService.fetchLogBySinhVien(svId);
      setState(() => _logs = list);
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
        title: const Text('Thông tin chi tiết đề tài'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Tiêu đề đề tài (không icon, theo layout giống ảnh 4)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Đề tài: ${widget.data.tenDeTai.isEmpty ? "—" : widget.data.tenDeTai}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'Thông tin sinh viên thực hiện:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Thông tin SV (gồm CV ở TRÊN như yêu cầu)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(context, 'Họ tên', widget.data.hoTen),
                    _divider(context),
                    _infoRow(context, 'Mã sinh viên', widget.data.maSV),
                    _divider(context),
                    _infoRow(context, 'Lớp', widget.data.tenLop),
                    _divider(context),
                    _infoRow(context, 'Số điện thoại', widget.data.soDienThoai),
                    _divider(context),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CV: ', style: Theme.of(context).textTheme.bodyMedium),
                        Expanded(
                          child: InkWell(
                            onTap: _maybeOpen(widget.data.cvUrl),
                            child: Text(
                              (widget.data.cvUrl ?? '').isEmpty
                                  ? '—'
                                  : widget.data.cvUrl!.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: (widget.data.cvUrl ?? '').startsWith('http')
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                decoration: (widget.data.cvUrl ?? '').startsWith('http')
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
            ),

            const SizedBox(height: 12),
            Text(
              'Đề cương của sinh viên:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            if (_error != null)
              _errorBox(context, _error!, onRetry: _loadLogs)
            else if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_logs.isEmpty)
                _emptyBox(context, 'Chưa có đề cương nào.')
              else
                Column(children: _logs.map((e) => _logItem(context, e)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _logItem(BuildContext context, DeCuongItem e) {
    String two(int x) => x.toString().padLeft(2, '0');
    String fmt(DateTime? d) => d == null ? '—' : '${two(d.day)}/${two(d.month)}/${d.year}';

    final color = deCuongStatusColor(e.status);
    final text = deCuongStatusText(e.status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lần nộp: ${e.lanNop ?? '—'}'),
            const SizedBox(height: 2),
            Text('Ngày nộp: ${fmt(e.ngayNop)}'),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('File: '),
                Expanded(
                  child: InkWell(
                    onTap: _maybeOpen(e.fileName),
                    child: Text(
                      e.fileName ?? '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (e.fileName ?? '').startsWith('http')
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        decoration: (e.fileName ?? '').startsWith('http')
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('Trạng thái: '),
                Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
            if ((e.nhanXet ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Nhận xét: ${e.nhanXet}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF393938)),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 16, color: Theme.of(context).dividerColor);

  VoidCallback? _maybeOpen(String? url) {
    if (url == null || url.isEmpty || !url.startsWith('http')) return null;
    return () async {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    };
  }

  Widget _emptyBox(BuildContext ctx, String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Theme.of(ctx).disabledColor),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _errorBox(BuildContext ctx, String msg, {required VoidCallback onRetry}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lỗi: $msg'),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        )
      ],
    ),
  );
}
