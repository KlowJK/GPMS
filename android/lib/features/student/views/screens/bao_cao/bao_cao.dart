import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../models/report_item.dart';
import '../../../viewmodels/bao_cao_viewmodel.dart';
import '../../../services/bao_cao_service.dart';
import '../../../../auth/services/auth_service.dart';
import 'submit_report_page.dart';

class BaoCao extends StatelessWidget {
  const BaoCao({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BaoCaoViewModel(
        service: BaoCaoService(baseUrl: AuthService.baseUrl),
      )..fetchReports(),
      child: const _BaoCaoBody(),
    );
  }
}

class _BaoCaoBody extends StatelessWidget {
  const _BaoCaoBody();

  Future<void> _goSubmit(BuildContext context) async {
    final vm = context.read<BaoCaoViewModel>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ChangeNotifierProvider.value(value: vm, child: SubmitReportPage()),
      ),
    );
    if (result == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã nộp báo cáo thành công')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BaoCaoViewModel>();
    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 560
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Báo cáo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                      ? _ErrorState(
                          message: 'Không thể tải báo cáo. Vui lòng thử lại.',
                          onRetry: () => vm.fetchReports(),
                        )
                      : !vm.hasTopic
                          ? const _EmptyState(
                              icon: Icons.info_outline,
                              title: 'Bạn chưa có đề tài',
                              subtitle: 'Vui lòng đăng ký đề tài để có thể nộp báo cáo.',
                            )
                          : vm.items.isEmpty
                              ? const _EmptyState(
                                  icon: Icons.description_outlined,
                                  title: 'Bạn chưa có báo cáo trong hệ thống.',
                                  subtitle: 'Nhấn nút “+” để nộp báo cáo.',
                                )
                              : ListView.separated(
                                  itemCount: vm.items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (_, i) => _ReportCard(item: vm.items[i]),
                                ),
            ),
          ),
        ),
      ),
      // Show FAB when user has a topic; if not allowed to submit, show a SnackBar explaining why
      floatingActionButton: vm.hasTopic
          ? Tooltip(
              message: vm.canSubmitNew ? 'Nộp báo cáo mới' : 'Chỉ nộp mới khi báo cáo trước bị từ chối',
              child: FloatingActionButton(
                onPressed: () {
                  if (vm.canSubmitNew) {
                    _goSubmit(context);
                    return;
                  }

                  // Determine message based on latest report status
                  final latest = vm.latestReport;
                  String msg;
                  if (latest == null) {
                    msg = 'Không thể nộp báo cáo mới.';
                  } else if (latest.status == ReportStatus.pending) {
                    msg = 'Báo cáo trước đang trong trạng thái chờ duyệt. Vui lòng chờ phản hồi.';
                  } else if (latest.status == ReportStatus.approved) {
                    msg = 'Báo cáo trước đã được duyệt. Không thể nộp báo cáo mới.';
                  } else if (latest.status == ReportStatus.rejected) {
                    // should not reach here since canSubmitNew would be true, but handle defensively
                    _goSubmit(context);
                    return;
                  } else {
                    msg = 'Không thể nộp báo cáo mới.';
                  }

                  if (ScaffoldMessenger.maybeOf(context) != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }
}

/* ================== CARD HIỂN THỊ BÁO CÁO ================== */

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.item});
  final ReportItem item;

  String get _statusLabel => switch (item.status) {
    ReportStatus.approved => 'Đã duyệt',
    ReportStatus.rejected => 'Từ chối',
    _ => 'Chờ duyệt',
  };

  (Color bg, Color fg) get _statusColor => switch (item.status) {
    ReportStatus.approved => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    ReportStatus.rejected => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    _ => (const Color(0xFFFFF7ED), const Color(0xFF9A3412)),
  };

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year} • '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  void _showFileDialog(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Đường dẫn tệp'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Đã sao chép đường dẫn')));
            },
            child: const Text('Sao chép'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _statusColor;
    final cs = Theme.of(context).colorScheme;
    final vm = context.watch<BaoCaoViewModel>();
    final raw = vm.lastSubmittedRaw;
    final bool matched = raw != null && (raw.duongDanFile?.split(RegExp(r"[\\\/]")) .last == item.fileName || (raw.duongDanFile ?? '').contains(item.fileName));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tên file + trạng thái
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mở tệp: ${item.fileName} (demo)'),
                      ),
                    ),
                    child: Text(
                      item.fileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _Badge(text: _statusLabel, bg: bg, fg: fg),
              ],
            ),
            const SizedBox(height: 6),
            _meta('Phiên bản', '${item.version}'),
            _meta('Ngày nộp', _fmt(item.createdAt)),
            if (kDebugMode && (item.rawStatus ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('rawStatus: ${item.rawStatus}', style: const TextStyle(fontSize: 12, color: Colors.black38)),
            ],
            if (item.note != null && item.note!.isNotEmpty)
              _meta('Phản hồi', item.note!),

            // show additional fields when we have raw data matching this item
            if (matched) ...[
              const SizedBox(height: 8),
              // raw is non-null here because `matched` checked it; create a local non-nullable alias
              // so the analyzer knows the fields are non-nullable where appropriate.
              (() {
                final r = raw;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((r.tenGiangVienHuongDan ?? '').isNotEmpty)
                      _meta('GVHD', r.tenGiangVienHuongDan!),
                    if (r.diemBaoCao != null) _meta('Điểm', r.diemBaoCao.toString()),
                    if ((r.duongDanFile ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const SizedBox(width: 90, child: Text('Tệp', style: TextStyle(color: Colors.black54))),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton(
                                onPressed: () => _showFileDialog(context, r.duongDanFile!),
                                child: Text('Mở/Chi tiết', style: TextStyle(color: cs.primary)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }()),
            ],

            const SizedBox(height: 8),
            // 'Phúc đáp' removed for student role
          ],
        ),
      ),
    );
  }

  Widget _meta(String k, String v) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(k, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

/* ================== NỘP BÁO CÁO (Submit) ================== */

// SubmitReportPage (and _AttachFileTile) moved to submit_report_page.dart

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;

    return Container(
      // ➜ ép khung trắng rộng full và cao tối thiểu 62% màn hình
      width: double.infinity,
      constraints: BoxConstraints(minHeight: h * 0.62),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // căn giữa đẹp hơn
        children: [
          Icon(icon, size: 64, color: cs.primary),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: cs.error),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }
}
