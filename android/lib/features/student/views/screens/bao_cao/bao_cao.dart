import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/student/models/bao_cao.dart';
import 'package:GPMS/features/student/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/features/student/views/screens/bao_cao/nop_bao_cao.dart';
import 'package:GPMS/features/student/views/widgets/custom_app_bar.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

class BaoCao extends StatefulWidget {
  const BaoCao({super.key});

  @override
  State<BaoCao> createState() => _BaoCaoState();
}

class _BaoCaoState extends State<BaoCao> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BaoCaoViewModel>().fetchReports();
    });
  }

  Future<void> _handleRefresh(BaoCaoViewModel vm) async {
    try {
      await vm.fetchReports();
    } catch (e) {
      if (!mounted) return;

      String message = 'Không thể làm mới dữ liệu';

      if (e is CustomException) {
        switch (e.errorCode) {
          case ErrorCode.unauthenticated:
            message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
            break;
          case ErrorCode.timeout:
            message = 'Kết nối hết thời gian chờ. Vui lòng thử lại.';
            break;
          case ErrorCode.deTaiNotFound:
            message = 'Bạn chưa đăng ký đề tài.';
            break;
          default:
            message = e.errorCode.message;
        }
      } else {
        message = 'Lỗi kết nối: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _goSubmit(BuildContext context) async {
    // Lấy instance hiện có từ TrangChuSinhVien
    final vm = context.read<BaoCaoViewModel>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm, // 👈 truyền đúng instance hiện có
          child: const SubmitReportPage(),
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã nộp báo cáo thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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

    return Consumer<BaoCaoViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: CustomAppBar(),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: _buildBody(vm, pad, gap),
              ),
            ),
          ),
          floatingActionButton: _buildFAB(vm),
        );
      },
    );
  }

  Widget _buildBody(BaoCaoViewModel vm, double pad, double gap) {
    // Loading lần đầu
    if (vm.loading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (vm.hasError) {
      return _buildErrorView(vm, pad);
    }

    // No topic
    if (!vm.hasTopic) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
        child: const _EmptyState(
          icon: Icons.info_outline,
          title: 'Bạn chưa có đề tài',
          subtitle: 'Vui lòng đăng ký đề tài để có thể nộp báo cáo.',
        ),
      );
    }

    // Empty list
    if (vm.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
        child: const _EmptyState(
          icon: Icons.description_outlined,
          title: 'Bạn chưa có báo cáo trong hệ thống.',
          subtitle: 'Nhấn nút "+" để nộp báo cáo.',
        ),
      );
    }

    // List with pull to refresh
    return RefreshIndicator(
      onRefresh: () => _handleRefresh(vm),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
        itemCount: vm.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ReportCard(item: vm.items[i]),
      ),
    );
  }

  Widget _buildErrorView(BaoCaoViewModel vm, double pad) {
    String message = vm.error!;
    IconData icon = Icons.error_outline;
    VoidCallback? onAction;

    // Handle specific errors
    if (vm.errorCode == ErrorCode.unauthenticated) {
      message = 'Phiên đăng nhập hết hạn';
      icon = Icons.lock_outline;
      onAction = () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      };
    } else if (vm.errorCode == ErrorCode.timeout) {
      message = 'Kết nối hết thời gian chờ';
      icon = Icons.signal_wifi_off;
      onAction = () => vm.fetchReports();
    } else if (vm.errorCode == ErrorCode.deTaiNotFound) {
      message = 'Bạn chưa đăng ký đề tài';
      icon = Icons.topic_outlined;
    } else {
      onAction = () => vm.fetchReports();
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB(BaoCaoViewModel vm) {
    // Require topic
    if (!vm.hasTopic) return null;

    // Only show FAB if the latest report is rejected (TU_CHOI)
    if (!_shouldShowFab(vm)) return null;

    return Tooltip(
      message: vm.canSubmitNew
          ? 'Nộp báo cáo mới'
          : 'Chỉ nộp mới khi báo cáo trước bị từ chối',
      child: FloatingActionButton(
        onPressed: () => _handleFABTap(vm),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Decide whether to show FAB: true only when the latest report is rejected.
  bool _shouldShowFab(BaoCaoViewModel vm) {
    if (vm.items.isEmpty) return false;

    // Find the report(s) with the highest version number
    int maxVersion = vm.items.map((e) => e.version).reduce((a, b) => a > b ? a : b);
    final topVersionItems = vm.items.where((e) => e.version == maxVersion).toList();

    // If multiple items share the same max version, pick the most recent by createdAt
    ReportItem latest = topVersionItems.first;
    for (final r in topVersionItems) {
      try {
        if (r.createdAt.isAfter(latest.createdAt)) latest = r;
      } catch (_) {}
    }

    return latest.status == ReportStatus.rejected;
  }

  void _handleFABTap(BaoCaoViewModel vm) {
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
      msg = 'Báo cáo trước đã được duyệt. Không thể nộp báo cáo mới.';
    } else {
      msg = 'Không thể nộp báo cáo mới.';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Card hiển thị báo cáo
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.item});
  final ReportItem item;

  String get _statusLabel => switch (item.status) {
    ReportStatus.approved => 'Đã duyệt',
    ReportStatus.rejected => 'Từ chối',
    _ => 'Chờ duyệt',
  };

  (Color, Color) get _statusColors => switch (item.status) {
    ReportStatus.approved => (const Color(0xFFF0FDF4), const Color(0xFF22C55E)),
    ReportStatus.rejected => (const Color(0xFFFEF2F2), const Color(0xFFEF4444)),
    _ => (const Color(0xFFFFFBEB), const Color(0xFFF59E0B)),
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
        side: BorderSide(color: badgeColor.withAlpha((0.5 * 255).round())),
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
            // Show score when approved
            if (item.status == ReportStatus.approved && item.diemBaoCao != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Điểm: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.diemBaoCao!.toStringAsFixed(item.diemBaoCao! % 1 == 0 ? 0 : 2),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
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
