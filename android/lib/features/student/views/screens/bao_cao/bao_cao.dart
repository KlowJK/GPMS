import 'package:GPMS/features/student/views/screens/bao_cao/nop_bao_cao.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/report_item.dart';
import '../../../viewmodels/bao_cao_viewmodel.dart';
import '../../../services/bao_cao_service.dart';
import '../../../../auth/services/auth_service.dart';

class BaoCao extends StatelessWidget {
  const BaoCao({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BaoCaoViewModel(service: BaoCaoService(baseUrl: AuthService.baseUrl))
            ..fetchReports(),
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
        builder: (ctx) => ChangeNotifierProvider.value(
          value: vm,
          child: const SubmitReportPage(),
        ),
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2563EB),
        elevation: 1,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              child: Image.asset("assets/images/logo.png"),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Text(
                    'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'THUY LOI UNIVERSITY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Thông báo',
            icon: const Icon(Icons.notifications_outlined),
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person, size: 18),
            ),
          ),
        ],
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
                      subtitle:
                          'Vui lòng đăng ký đề tài để có thể nộp báo cáo.',
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
      floatingActionButton: vm.hasTopic
          ? Tooltip(
              message: vm.canSubmitNew
                  ? 'Nộp báo cáo mới'
                  : 'Chỉ nộp mới khi báo cáo trước bị từ chối',
              child: FloatingActionButton(
                onPressed: () {
                  if (vm.canSubmitNew) {
                    _goSubmit(context);
                    return;
                  }
                  final latest = vm.latestReport;
                  String msg;
                  if (latest == null) {
                    _goSubmit(context);
                    return;
                  } else if (latest.status == ReportStatus.pending) {
                    msg =
                        'Báo cáo trước đang trong trạng thái chờ duyệt. Vui lòng chờ phản hồi.';
                  } else if (latest.status == ReportStatus.approved) {
                    msg =
                        'Báo cáo trước đã được duyệt. Không thể nộp báo cáo mới.';
                  } else {
                    msg = 'Không thể nộp báo cáo mới.';
                  }

                  if (ScaffoldMessenger.maybeOf(context) != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.item});
  final ReportItem item;

  String get _statusLabel => switch (item.status) {
    ReportStatus.approved => 'Đã duyệt',
    ReportStatus.rejected => 'Từ chối',
    _ => 'Chờ duyệt',
  };

  (Color, Color) get _statusColors => switch (item.status) {
    ReportStatus.approved => (
      const Color(0xFFF0FDF4),
      const Color(0xFF22C55E),
    ), // green
    ReportStatus.rejected => (
      const Color(0xFFFEF2F2),
      const Color(0xFFEF4444),
    ), // red
    _ => (const Color(0xFFFFFBEB), const Color(0xFFF59E0B)), // amber
  };

  String _fmtDateOnly(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _buildInfoRow(String label, {String? text, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (child != null)
              WidgetSpan(child: child, alignment: PlaceholderAlignment.middle)
            else
              TextSpan(text: text ?? ''),
          ],
        ),
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (cardColor, badgeColor) = _statusColors;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: badgeColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Phiên bản: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: '${item.version}'),
                    ],
                  ),
                ),
                _Badge(text: _statusLabel, color: badgeColor),
              ],
            ),
            _buildInfoRow(
              'File',
              child: InkWell(
                onTap: () async {
                  if (item.fileUrl == null) return;
                  final url = Uri.tryParse(item.fileUrl!);
                  if (url != null && await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: cs.primary,
                  ),
                ),
              ),
            ),
            _buildInfoRow('Ngày nộp', text: _fmtDateOnly(item.createdAt)),

            if (item.note != null && item.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Nhận xét: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: item.note!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
      width: double.infinity,
      constraints: BoxConstraints(minHeight: h * 0.62),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: color)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
