import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/views/screens/do_an/hoan_do_an.dart';
import 'package:GPMS/features/student/views/screens/do_an/de_tai/dang_ky_de_tai.dart';
import 'package:GPMS/features/student/views/screens/do_an/de_cuong/de_cuong.dart';
import 'package:GPMS/features/student/views/screens/do_an/de_cuong/nop_de_cuong_screen.dart';
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';
import 'package:GPMS/features/student/views/widgets/custom_app_bar.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GPMS/features/student/viewmodels/hoan_do_an_viewmodel.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

enum DoAnTab { detai, decuong }

class DoAn extends StatefulWidget {
  const DoAn({super.key});

  @override
  State<DoAn> createState() => _DoAnState();
}

class _DoAnState extends State<DoAn> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DoAnTab _tab = DoAnTab.detai;

  @override
  void initState() {
    super.initState();

    // Load cả advisors và đề tài chi tiết ngay khi mở tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DoAnViewModel>();

      // Load advisors nếu chưa có
      if (!vm.isLoadingAdvisors && vm.advisors.isEmpty) {
        vm.fetchAdvisors();
      }

      // Load đề tài chi tiết nếu chưa có dữ liệu và chưa đang loading
      if (vm.deTaiDetail == null &&
          !vm.isLoadingDeTai &&
          vm.deTaiError == null) {
        vm.fetchDeTaiChiTiet();
      }
    });
  }

  Future<void> _handleRefresh(DoAnViewModel vm) async {
    try {
      await vm.fetchDeTaiChiTiet();
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

  Future<void> _goRegister() async {
    final vm = context.read<DoAnViewModel>();

    // Check and load advisors if needed
    if (vm.advisors.isEmpty && !vm.isLoadingAdvisors) {
      await vm.fetchAdvisors();
    }

    if (vm.advisors.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: const DangKyDeTai(),
          ),
        ),
      );
      return;
    }

    // Show error
    final msg = vm.advisorError?.isNotEmpty == true
        ? vm.advisorError!
        : 'Không có giảng viên hướng dẫn hoặc không thể tải dữ liệu. Vui lòng thử lại.';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _goPostpone() {
    final hoanVm = context.read<HoanDoAnViewModel>(); // lấy từ TrangChuSinhVien
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: hoanVm,
          child: const HoanDoAn(),
        ),
      ),
    );
  }

  void _goToNopDeCuong() {
    final vm = context.read<DoAnViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const NopDeCuongScreen(submissionCount: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final w = MediaQuery.of(context).size.width;
    final double maxContentWidth = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 560
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    return Consumer<DoAnViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: CustomAppBar(),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, gap, pad, 0),
                      child: _TabsBar(
                        current: _tab,
                        onChanged: (t) => setState(() => _tab = t),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Expanded(
                      child: _tab == DoAnTab.detai
                          ? _buildDeTaiTab(context, vm, pad, gap)
                          : _buildDeCuongTab(context, vm, gap),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeTaiTab(
    BuildContext context,
    DoAnViewModel vm,
    double pad,
    double gap,
  ) {
    return RefreshIndicator(
      onRefresh: () => _handleRefresh(vm),
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          // Action buttons
          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 520;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _goRegister,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Đăng ký đề tài'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goPostpone,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Đề nghị hoãn đồ án'),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _goRegister,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Đăng ký đề tài'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _goPostpone,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Đề nghị hoãn đồ án'),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: gap),
          // Content
          if (vm.isLoadingDeTai && vm.deTaiDetail == null)
            const Center(child: CircularProgressIndicator())
          else if (vm.deTaiError != null && vm.deTaiDetail == null)
            _buildErrorView(vm, gap)
          else if (vm.deTaiDetail != null) ...[
            SizedBox(height: gap),
            Text(
              "Thông tin đề tài",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: gap),
            _ProjectInfoCard(
              gap: gap,
              title: vm.deTaiDetail!.tenDeTai,
              advisor: vm.deTaiDetail!.gvhdTen,
              overviewFile: vm.deTaiDetail!.tongQuanFilename,
              fileUrl: vm.deTaiDetail!.tongQuanDeTaiUrl,
              status: vm.deTaiDetail!.trangThai,
              nhanXet: vm.deTaiDetail!.nhanXet,
            ),
          ] else ...[
            SizedBox(height: gap),
            const _EmptyState(
              icon: Icons.assignment,
              title: 'Bạn chưa đăng ký đề tài',
              subtitle: 'Vui lòng nhấn "Đăng ký đề tài" để bắt đầu.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(DoAnViewModel vm, double gap) {
    String message = vm.deTaiError!;
    IconData icon = Icons.error_outline;
    VoidCallback? onAction;

    // Handle specific errors
    if (vm.deTaiErrorCode == ErrorCode.unauthenticated) {
      message = 'Phiên đăng nhập hết hạn';
      icon = Icons.lock_outline;
      onAction = () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      };
    } else if (vm.deTaiErrorCode == ErrorCode.timeout) {
      message = 'Kết nối hết thời gian chờ';
      icon = Icons.signal_wifi_off;
      onAction = () => vm.retryDeTai();
    } else if (vm.deTaiErrorCode == ErrorCode.deTaiNotFound) {
      return const _EmptyState(
        icon: Icons.assignment,
        title: 'Bạn chưa đăng ký đề tài',
        subtitle: 'Vui lòng nhấn "Đăng ký đề tài" để bắt đầu.',
      );
    } else {
      onAction = () => vm.retryDeTai();
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(gap),
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

  Widget _buildDeCuongTab(BuildContext context, DoAnViewModel vm, double gap) {
    if (vm.deTaiDetail != null) {
      return DeCuong(gap: gap, onCreate: _goToNopDeCuong);
    } else {
      return DeCuong(
        gap: gap,
        onCreate: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hãy đăng ký đề tài trước khi tạo đề cương.'),
            ),
          );
        },
      );
    }
  }
}

class _ProjectInfoCard extends StatelessWidget {
  const _ProjectInfoCard({
    required this.gap,
    required this.title,
    required this.advisor,
    this.overviewFile,
    this.fileUrl,
    required this.status,
    this.nhanXet,
  });

  final double gap;
  final String title;
  final String advisor;
  final String? overviewFile;
  final String? fileUrl;
  final String status;
  final String? nhanXet;

  Future<void> _launchURL(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Không thể mở liên kết $url')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Tên đề tài:', value: title),
            _InfoRow(label: 'GVHD:', value: advisor),
            if (fileUrl?.isNotEmpty == true)
              _InfoRow(
                label: 'Tổng quan:',
                valueWidget: InkWell(
                  onTap: () => _launchURL(context, fileUrl),
                  child: Text(
                    'Xem chi tiết',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            _InfoRow(
              label: 'Trạng thái:',
              valueWidget: _Badge(
                text: status == 'CHO_DUYET'
                    ? 'Chờ duyệt'
                    : status == 'DA_DUYET'
                    ? 'Đã duyệt'
                    : status == 'TU_CHOI'
                    ? 'Từ chối'
                    : status,
                fg: status == 'CHO_DUYET'
                    ? Colors.amber
                    : status == 'DA_DUYET'
                    ? Colors.green
                    : status == 'TU_CHOI'
                    ? Colors.red
                    : Colors.black,
              ),
            ),
            if (nhanXet != null && nhanXet!.isNotEmpty)
              _InfoRow(label: 'Nhận xét:', value: nhanXet),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.valueWidget});
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final styleLabel = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.black87,
      fontWeight: FontWeight.w900,
    );
    final styleValue = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Expanded(child: valueWidget ?? Text(value ?? '', style: styleValue)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.fg});
  final String text;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 130, horizontal: 36),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: cs.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.current, required this.onChanged});

  final DoAnTab current;
  final ValueChanged<DoAnTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, c) {
        const tabCount = 2;
        final tabWidth = c.maxWidth / tabCount;
        final left = current == DoAnTab.detai ? 0.0 : tabWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _TabButton(
                    text: 'Đề tài',
                    selected: current == DoAnTab.detai,
                    onTap: () => onChanged(DoAnTab.detai),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    text: 'Đề cương',
                    selected: current == DoAnTab.decuong,
                    onTap: () => onChanged(DoAnTab.decuong),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(height: 1, color: Colors.black12),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: left,
                  child: Container(
                    width: tabWidth,
                    height: 2,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? cs.primary : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
