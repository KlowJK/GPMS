import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hoan_do_an.dart';
import 'de_tai/dang_ky_de_tai.dart';
import 'de_cuong/de_cuong.dart';
import '../../../viewmodels/do_an_viewmodel.dart';

enum DoAnTab { detai, decuong }

class DoAn extends StatefulWidget {
  const DoAn({super.key});

  @override
  State<DoAn> createState() => DoAnState();
}

class DoAnState extends State<DoAn> {
  DoAnTab _tab = DoAnTab.detai;

  Future<void> _goRegister() async {
    final vm = Provider.of<DoAnViewModel>(context, listen: false);
    if (vm.advisors.isEmpty && !vm.isLoadingAdvisors) {
      await vm.fetchAdvisors();
    }
    if (vm.advisors.isNotEmpty) {
      await Navigator.push<RegisterResult>(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: const DangKyDeTai(),
          ),
        ),
      );
    }
  }

  void _goPostpone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HoanDoAn()),
    );
  }

  @override
  void initState() {
    super.initState();
    // Đã fetch ở DoAnViewModel constructor, không cần gọi lại ở đây
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
            backgroundColor: const Color(0xFF2563EB),
            title: const Text('Đồ án', style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                  children: [
                    _TabsBar(
                      current: _tab,
                      onChanged: (t) => setState(() => _tab = t),
                    ),
                    SizedBox(height: gap),

                    if (_tab == DoAnTab.detai)
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _goRegister,
                                  label: const Text('Đăng ký đề tài'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _goPostpone,
                                  label: const Text('Đề nghị hoãn đồ án'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    SizedBox(height: gap),

                    if (_tab == DoAnTab.detai) ...[
                      if (vm.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (vm.deTaiDetail != null && vm.error == null) ...[
                        SizedBox(height: gap * 1),
                        Text(
                          "Thông tin đề tài",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
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
                          fileUrl: vm.deTaiDetail!.tongQuanDeTaiUrl ?? '',
                          status: vm.deTaiDetail!.trangThai,
                          nhanXet: vm.deTaiDetail!.nhanXet,
                        ),
                      ] else ...[
                        SizedBox(height: gap * 1),
                        const _EmptyState(
                          icon: Icons.assignment,
                          title: 'Bạn chưa đăng ký đề tài',
                          subtitle:
                              'Vui lòng nhấn “Đăng ký đề tài” để bắt đầu.',
                        ),
                      ],
                    ] else ...[
                      if (vm.deTaiDetail != null)
                        DeCuong(gap: gap, onCreate: () {})
                      else
                        DeCuong(
                          gap: gap,
                          onCreate: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Hãy đăng ký đề tài trước khi tạo đề cương.',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProjectInfoCard extends StatelessWidget {
  const _ProjectInfoCard({
    required this.gap,
    required this.title,
    required this.advisor,
    this.overviewFile, // <-- String?
    required this.fileUrl,
    required this.status,
    this.nhanXet,
  });
  final double gap;
  final String title;
  final String advisor;
  final String? overviewFile; // <-- nullable
  final String fileUrl;
  final String status;
  final String? nhanXet;

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
            if (overviewFile != null && overviewFile!.isNotEmpty)
              _InfoRow(label: 'File tổng quan:', value: overviewFile),
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
        crossAxisAlignment:
            CrossAxisAlignment.start, // Đảm bảo label luôn ở top
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
      padding: const EdgeInsets.symmetric(vertical: 144, horizontal: 36),
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
            // Divider xám mảnh + gạch dưới màu primary trượt mượt
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
