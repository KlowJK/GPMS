import 'package:flutter/material.dart';

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

  /// Demo: đổi cờ này để mô phỏng đã/ chưa đăng ký đề tài.
  bool _hasProject = false;

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

                // Hàng nút hành động chính
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 520;

                    if (isWide) {
                      // Tablet/Desktop: nằm ngang, dùng Expanded ok
                      return Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},

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
                              onPressed: () {},

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

                    // Mobile: xếp dọc, KHÔNG dùng Expanded trong Column
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {},
                            label: const Text('Đăng ký đề tài'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},

                            label: const Text(
                              'Đề nghị hoãn đồ án',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: gap * 1.5),
                Text(
                  "Thông tin đề tài",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: gap * 1.2),

                // Nội dung theo tab
                if (_tab == ProjectTab.detai) ...[
                  if (_hasProject)
                    _ProjectInfoCard(gap: gap)
                  else
                    _EmptyState(
                      icon: Icons.assignment,
                      title: 'Bạn chưa đăng ký đồ án',
                      subtitle: 'Vui lòng nhấn “Đăng ký đề tài” để bắt đầu.',
                    ),
                ] else ...[
                  if (_hasProject)
                    _OutlineInfoCard(gap: gap)
                  else
                    _EmptyState(
                      icon: Icons.description_outlined,
                      title: 'Chưa có đề cương',
                      subtitle:
                          'Hãy đăng ký đề tài trước, sau đó tạo đề cương.',
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
                    child: Column(
                      children: const [
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
  const _ProjectInfoCard({required this.gap});
  final double gap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: gap),
            _InfoRow(
              label: 'Tên đề tài',
              value: 'Hệ thống quản lý đề tài khoa CNTT',
            ),
            _InfoRow(label: 'GVHD', value: 'TS. Trần Văn B'),
            _InfoRow(
              label: 'Trạng thái',
              valueWidget: _Badge(
                text: 'Đã duyệt',
                bg: const Color(0xFFDCFCE7),
                fg: const Color(0xFF166534),
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
                    /* TODO: mở chi tiết đề tài */
                  },
                  child: const Text('Xem chi tiết'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    /* TODO: đổi/huỷ đăng ký */
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

class _OutlineInfoCard extends StatelessWidget {
  const _OutlineInfoCard({required this.gap});
  final double gap;

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
              'Đề cương',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: gap),
            _InfoRow(label: 'Mã đề cương', value: '#P-2025-031'),
            _InfoRow(
              label: 'Trạng thái',
              valueWidget: const _Badge(
                text: 'Chờ duyệt',
                bg: Color(0xFFFFF7ED),
                fg: Color(0xFF9A3412),
              ),
            ),
            _InfoRow(label: 'Cập nhật cuối', value: '18/09, 10:30'),
            SizedBox(height: gap),
            Row(
              children: [
                FilledButton(
                  onPressed: () {
                    /* TODO: chỉnh sửa đề cương */
                  },
                  child: const Text('Chỉnh sửa đề cương'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    /* TODO: xem bản PDF */
                  },
                  child: const Text('Xem bản hiện tại'),
                ),
              ],
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
    final styleLabel = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor);
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
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
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
