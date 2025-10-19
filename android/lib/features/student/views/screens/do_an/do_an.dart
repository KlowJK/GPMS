import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/views/screens/do_an/hoan_do_an.dart';
import 'package:GPMS/features/student/views/screens/do_an/de_tai/dang_ky_de_tai.dart';
import 'package:GPMS/features/student/views/screens/do_an/de_cuong/de_cuong.dart';
import 'package:GPMS/features/student/views/screens/do_an/de_cuong/nop_de_cuong_screen.dart';
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

enum DoAnTab { detai, decuong }

class DoAn extends StatefulWidget {
  const DoAn({super.key});

  @override
  State<DoAn> createState() => DoAnState();
}

class DoAnState extends State<DoAn> {
  DoAnTab _tab = DoAnTab.detai;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DoAnViewModel>();
      if (!vm.isLoadingAdvisors && vm.advisors.isEmpty) {
        vm.fetchAdvisors();
      }
    });
  }

  Future<void> _goRegister() async {
    final vm = context.read<DoAnViewModel>();

    if (vm.advisors.isEmpty && !vm.isLoadingAdvisors) {
      // Thử nạp ngay
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

    // Thông báo lỗi/không có dữ liệu
    final msg = vm.advisorError?.isNotEmpty == true
        ? vm.advisorError!
        : 'Không có giảng viên hướng dẫn hoặc không thể tải dữ liệu. Vui lòng thử lại.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goPostpone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HoanDoAn()),
    );
  }

  void _goToNopDeCuong() {
    final vm = Provider.of<DoAnViewModel>(context, listen: false);
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.person, size: 18),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                // Using a Column with an Expanded child is more robust for tabbed views
                // than a single ListView was.
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
                    // Expanded provides the Tab content with bounded constraints, fixing layout errors.
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
    // This tab content is now wrapped in its own ListView to be scrollable.
    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 520;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _goRegister,
                      label: const Text('Đăng ký đề tài'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _goPostpone,
                      label: const Text('Đề nghị hoãn đồ án'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _goRegister,
                  label: const Text('Đăng ký đề tài'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _goPostpone,
                  label: const Text('Đề nghị hoãn đồ án'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: gap),
        if (vm.isLoadingDeTai)
          const Center(child: CircularProgressIndicator())
        else if (vm.deTaiDetail != null && vm.deTaiError == null) ...[
          SizedBox(height: gap * 1),
          Text(
            "Thông tin đề tài",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: gap * 1),
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
          SizedBox(height: gap * 1),
          const _EmptyState(
            icon: Icons.assignment,
            title: 'Bạn chưa đăng ký đề tài',
            subtitle: 'Vui lòng nhấn “Đăng ký đề tài” để bắt đầu.',
          ),
        ],
      ],
    );
  }

  Widget _buildDeCuongTab(BuildContext context, DoAnViewModel vm, double gap) {
    // The DeCuong widget now receives proper constraints from the Expanded parent.
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
    this.overviewFile, // <-- String?
    this.fileUrl,
    required this.status,
    this.nhanXet,
  });
  final double gap;
  final String title;
  final String advisor;
  final String? overviewFile; // <-- nullable
  final String? fileUrl;
  final String status;
  final String? nhanXet;

  Future<void> _launchURL(String? url) async {
    if (await canLaunch(url ?? '')) {
      await launch(url ?? '');
    } else {
      throw 'Không thể mở liên kết $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // ...
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
                valueWidget: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _launchURL(fileUrl),
                      child: Text(
                        'Xem chi tiết',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
          SizedBox(width: 80, child: Text(label, style: styleLabel)),
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
    return Text(text, style: TextStyle(color: fg, fontSize: 12));
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
        final tabCount = 2;
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
