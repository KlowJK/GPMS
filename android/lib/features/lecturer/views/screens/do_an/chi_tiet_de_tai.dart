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
  bool _processing = false;
  Future<void> _onAction({required int index, required bool approve}) async {
    if (_processing) return;
    setState(() => _processing = true);

    final it = _logs[index];
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
      await _loadLogs();

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
  void initState() {
    super.initState();
    _loadLogs();
  }

  String? _resolveSinhVienId() {
    return widget.data.maSV;
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
      // ⬇️ Dùng THAM SỐ VỊ TRÍ (theo service bạn đang xài)
      final list = await DeCuongService.fetchLogBySinhVien(svId);
      setState(() => _logs = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  List<int> _pendingIndexes() =>
      _logs.asMap().entries.where((e) => e.value.status == DeCuongStatus.pending).map((e) => e.key).toList();

  Future<int?> _pickPendingIndex(List<int> idxs) async {
    if (idxs.length == 1) return idxs.first;
    // Cho phép chọn log khi có nhiều "chờ duyệt"
    return showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Chọn lần nộp cần xử lý')),
            for (final i in idxs)
              ListTile(
                title: Text('Lần nộp: ${_logs[i].lanNop ?? "—"}'),
                subtitle: Text('File: ${_logs[i].fileName ?? "—"}'),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGlobalAction({required bool approve}) async {
    final idxs = _pendingIndexes();
    if (idxs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có đề cương đang chờ duyệt.')),
      );
      return;
    }
    final index = await _pickPendingIndex(idxs);
    if (index == null) return;

    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    try {
      final it = _logs[index];
      final updated = approve
          ? await DeCuongService.approve(id: it.id, nhanXet: note.trim())
          : await DeCuongService.reject(id: it.id, nhanXet: note.trim());
      setState(() => _logs[index] = updated);
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

  /// Duyệt / Từ chối 1 log (PUT) + popup nhận xét
  Future<void> _onAction({required int index, required bool approve}) async {
    final it = _logs[index];
    final note = await _showCommentDialog(context);
    if (note == null || note.trim().isEmpty) return;

    try {
      DeCuongItem updated;
      if (approve) {
        updated = await DeCuongService.approve(id: it.id, nhanXet: note.trim());
      } else {
        updated = await DeCuongService.reject(id: it.id, nhanXet: note.trim());
      }
      setState(() => _logs[index] = updated);
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
    const primary = Color(0xFF2F7CD3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Thông tin chi tiết'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SizedBox(height: 8),

            // Thông tin SV (gồm CV ở TRÊN như yêu cầu)
            // lib/features/lecturer/views/screens/do_an/chi_tiet_de_tai.dart (snippet)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Đề tài: ${widget.data.tenDeTai.isEmpty ? "—" : widget.data.tenDeTai}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
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
                        Text(
                          'CV: ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _maybeOpen(widget.data.cvUrl),
                            child: Builder(
                              builder: (context) {
                                final url = widget.data.cvUrl ?? '';
                                final hasHttp = url.startsWith('http');
                                final display = hasHttp
                                    ? 'Xem chi tiết'
                                    : (url.isEmpty ? '—' : url.split('/').last);
                                return Text(
                                  display,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: hasHttp
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.black87,
                                        decoration: hasHttp
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        fontWeight: FontWeight.w600,
                                      ),
                                );
                              },
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
              Column(
                children: _logs
                    .asMap()
                    .entries
                    .map((entry) => _logItem(context, entry.value, entry.key))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // dart
  Widget _logItem(BuildContext context, DeCuongItem e, int index) {
    String two(int x) => x.toString().padLeft(2, '0');
    String fmt(DateTime? d) =>
        d == null ? '—' : '${two(d.day)}/${two(d.month)}/${d.year}';
    final pending = e.status == DeCuongStatus.pending;

    // assign callbacks based on pending state and index
    final VoidCallback? onReject = (!_processing && pending)
        ? () => _onAction(index: index, approve: false)
        : null;
    final VoidCallback? onApprove = (!_processing && pending)
        ? () => _onAction(index: index, approve: true)
        : null;

    final color = deCuongStatusColor(e.status);
    final text = deCuongStatusText(e.status);
    final colorGVPB = e.gvPhanBienDuyet == null
        ? Colors.grey
        : deCuongStatusColor(e.gvPhanBienDuyet!);
    final textGVPB = e.gvPhanBienDuyet == null
        ? '—'
        : deCuongStatusText(e.gvPhanBienDuyet!);

    final colorTBM = e.tbmDuyet == null
        ? Colors.grey
        : deCuongStatusColor(e.tbmDuyet!);
    final textTBM = e.tbmDuyet == null ? '—' : deCuongStatusText(e.tbmDuyet!);

    final hasList = e.nhanXets != null && e.nhanXets!.isNotEmpty;
    final hasSingle = (e.nhanXet ?? '').isNotEmpty;

    String _detectPrefix(DeCuongItem item, dynamic nx) {
      final dyn = item as dynamic;
      final advisor = dyn.hoTenGiangVienHuongDan
          ?.toString()
          ?.toLowerCase()
          .trim();
      final reviewer = dyn.hoTenGiangVienPhanBien
          ?.toString()
          ?.toLowerCase()
          .trim();
      final head = dyn.hoTenTruongBoMon?.toString()?.toLowerCase().trim();

      final author = (nx.nguoiNhanXet ?? '').toString().toLowerCase().trim();
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

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: ${e.lanNop ?? '—'}'),
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
                    child: Builder(
                      builder: (context) {
                        final url = e.fileName ?? '';
                        final hasHttp = url.startsWith('http');
                        final display = hasHttp
                            ? 'Xem chi tiết'
                            : (url.isEmpty ? '—' : url.split('/').last);
                        return Text(
                          display,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: hasHttp
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                decoration: hasHttp
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('Trạng thái: '),
                Text(
                  text,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 2),
            Row(
              children: [
                const Text('Trạng thái GVPB: '),
                Text(
                  textGVPB,
                  style: TextStyle(
                    color: colorGVPB,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('Trạng thái TBM: '),
                Text(
                  textTBM,
                  style: TextStyle(
                    color: colorTBM,
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
                  children: e.nhanXets!.map((nx) {
                    final prefix = _detectPrefix(e, nx);
                    final content = nx.noiDung ?? '—';
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
                    final fakeNx = {'nguoiNhanXet': '', 'noiDung': e.nhanXet};
                    final prefix = _detectPrefix(e, fakeNx);
                    final displayed = prefix.isNotEmpty
                        ? '$prefix: ${e.nhanXet}'
                        : (e.nhanXet ?? '—');
                    return Text(
                      displayed,
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
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

            // ✅ Nút DUYỆT / TỪ CHỐI ngay trong thẻ
            if (pending) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 32,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(88, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Từ chối', style: TextStyle(fontSize: 13)),
                      onPressed: () => _onAction(index: index, approve: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(88, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Duyệt', style: TextStyle(fontSize: 13)),
                      onPressed: () => _onAction(index: index, approve: true),
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

  Widget _infoRow(BuildContext context, String label, String value) {
    final styleLabel = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    );
    final styleValue = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? '', style: styleValue)),
        ],
      ),
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

  Widget _errorBox(
    BuildContext ctx,
    String msg, {
    required VoidCallback onRetry,
  }) => Container(
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
        ),
      ],
    ),
  );
}

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
