import 'package:flutter/material.dart';
import 'DeNghiHoanPage.dart'; // chỉnh đường dẫn đúng với dự án của bạn
import 'dangkydetai.dart';   // file chứa RegisterProjectPage & RegisterResult

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F7CD3);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đồ án',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const ProjectScreen(),
    );
  }
}

enum ProjectTab { detai, decuong }

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  ProjectTab _tab = ProjectTab.detai;

  // Trạng thái sau đăng ký
  bool _hasProject = false;
  String? _projectTitle;
  String? _advisor;
  String? _overviewFile;

  Future<void> _goRegister() async {
    final result = await Navigator.push<RegisterResult>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterProjectPage()),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _hasProject = true;
        _projectTitle = result.title;
        _advisor = result.advisor;
        _overviewFile = result.overviewFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký đề tài thành công')),
      );
    }
  }

  void _goPostpone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeNghiHoanPage()),
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
                // Segmented tabs: Đề tài / Đề cương
                SegmentedButton<ProjectTab>(
                  segments: const [
                    ButtonSegment(
                      value: ProjectTab.detai,
                      label: Text('Đề tài'),
                    ),
                    ButtonSegment(
                      value: ProjectTab.decuong,
                      label: Text('Đề cương'),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),

                SizedBox(height: gap),

                // === HÀNG NÚT HÀNH ĐỘNG CHỈ Ở TAB "ĐỀ TÀI" ===
                if (_tab == ProjectTab.detai)
                  LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 520;

                      if (isWide) {
                        // Tablet/Desktop
                        return Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _goRegister,
                                icon: const Icon(Icons.add_box_outlined),
                                label: const Text('Đăng ký đề tài'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _goPostpone,
                                icon: const Icon(Icons.snooze_outlined),
                                label: const Text('Đề nghị hoãn đồ án'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Mobile
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _goRegister,
                              icon: const Icon(Icons.add_box_outlined),
                              label: const Text('Đăng ký đề tài'),
                              style: FilledButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _goPostpone,
                              icon: const Icon(Icons.snooze_outlined),
                              label: const Text('Đề nghị hoãn đồ án'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                SizedBox(height: gap * 1.5),
                Text(
                  _tab == ProjectTab.detai ? "Thông tin đề tài" : "Đề cương",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: gap * 1.2),

                // === NỘI DUNG THEO TAB ===
                if (_tab == ProjectTab.detai) ...[
                  if (_hasProject)
                    _ProjectInfoCard(
                      gap: gap,
                      title: _projectTitle ?? 'Đề tài của tôi',
                      advisor: _advisor ?? 'Đang cập nhật',
                      overviewFile: _overviewFile,
                    )
                  else
                    const _EmptyState(
                      icon: Icons.assignment,
                      title: 'Bạn chưa đăng ký đồ án',
                      subtitle: 'Vui lòng nhấn “Đăng ký đề tài” để bắt đầu.',
                    ),
                ] else ...[
                  // TAB ĐỀ CƯƠNG: KHÔNG có hai nút, hiển thị khung trống + nút "+"
                  if (_hasProject)
                    _DecuongEmptyCard(
                      gap: gap,
                      onCreate: () {
                        // TODO: điều hướng sang màn "Tạo đề cương"
                      },
                    )
                  else
                    _DecuongEmptyCard(
                      gap: gap,
                      onCreate: () {
                        // Nếu chưa có đề tài, vẫn có thể chặn và nhắc:
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Hãy đăng ký đề tài trước khi tạo đề cương.'),
                          ),
                        );
                      },
                    ),
                ],

                SizedBox(height: gap * 2),

                // Phụ: thông tin/nhắc việc liên quan (tuỳ chọn)
                if (_hasProject) ...[
                  Text(
                    'Việc cần làm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: gap),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        _TaskTile(
                          title: 'Ghi nhật ký tuần 5',
                          subtitle: 'Hạn: 20/09, 23:59 • SV',
                        ),
                        Divider(height: 1),
                        _TaskTile(
                          title: 'Chỉnh sửa đề cương theo góp ý',
                          subtitle: 'Hạn: 22/09, 23:59 • SV',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectInfoCard extends StatelessWidget {
  const _ProjectInfoCard({
    required this.gap,
    required this.title,
    required this.advisor,
    this.overviewFile,
  });
  final double gap;
  final String title;
  final String advisor;
  final String? overviewFile;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đề tài',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: gap),
            _InfoRow(label: 'Tên đề tài', value: title),
            _InfoRow(label: 'GVHD', value: advisor),
            if (overviewFile != null && overviewFile!.isNotEmpty)
              _InfoRow(label: 'Tổng quan', value: overviewFile),
            const _InfoRow(
              label: 'Trạng thái',
              valueWidget: _Badge(
                text: 'Đã duyệt',
                bg: Color(0xFFDCFCE7),
                fg: Color(0xFF166534),
              ),
            ),
            _InfoRow(
              label: 'Tiến độ',
              valueWidget: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: const LinearProgressIndicator(
                        minHeight: 8,
                        value: 0.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('35%', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
            SizedBox(height: gap),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    // TODO: mở chi tiết đề tài
                  },
                  child: const Text('Xem chi tiết'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // TODO: đổi/huỷ đăng ký
                  },
                  child: const Text('Thao tác khác'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecuongEmptyCard extends StatelessWidget {
  const _DecuongEmptyCard({required this.gap, required this.onCreate});
  final double gap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(gap),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 260),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 66, color: Theme.of(context).hintColor),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn chưa có đề cương trong hệ thống.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.small(
                  onPressed: onCreate,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
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
    final styleLabel = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(context).hintColor);
    final styleValue = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 120, child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Expanded(child: valueWidget ?? Text(value ?? '', style: styleValue)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: bg,                     // màu động
        shape: const StadiumBorder(),  // có thể const riêng phần shape
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
    );
  }


}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.checklist, size: 18),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: const Text('Thực hiện')),
      onTap: () {},
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
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
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
