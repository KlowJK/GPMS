import 'package:flutter/material.dart';

/* ===================== MODEL ===================== */

enum CouncilStatus { upcoming, ongoing, finished }

class CouncilItem {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final CouncilStatus status;

  const CouncilItem({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

/* ================ DEMO DATA (tĩnh) ================= */
final List<CouncilItem> demoCouncils = [
  CouncilItem(
    name: 'Hội đồng A',
    startDate: DateTime(2025, 10, 16),
    endDate: DateTime(2025, 10, 17),
    status: CouncilStatus.upcoming,
  ),
  CouncilItem(
    name: 'Hội đồng B',
    startDate: DateTime(2025, 9, 30, 8),
    endDate: DateTime(2025, 9, 30, 17),
    status: CouncilStatus.ongoing,
  ),
  CouncilItem(
    name: 'Hội đồng C',
    startDate: DateTime(2025, 8, 12),
    endDate: DateTime(2025, 8, 12),
    status: CouncilStatus.finished,
  ),
  CouncilItem(
    name: 'Hội đồng D',
    startDate: DateTime(2025, 11, 1, 7, 30),
    endDate: DateTime(2025, 11, 1, 11, 30),
    status: CouncilStatus.upcoming,
  ),
  CouncilItem(
    name: 'Hội đồng E',
    startDate: DateTime(2025, 9, 20),
    endDate: DateTime(2025, 9, 20),
    status: CouncilStatus.finished,
  ),
];

/* ================== COUNCIL LIST PAGE ================== */

class CouncilListPage extends StatelessWidget {
  const CouncilListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final double maxW =
          w >= 1200 ? 1100 : w >= 900 ? 900 : w >= 600 ? 600 : w;
          final double pad = w >= 900 ? 24 : 16;
          final double gap = w >= 900 ? 16 : 12;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2563EB),
              title: const Text('Hội đồng', style: TextStyle(color: Colors.white)),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
                  children: [
                    Text(
                      'Danh sách hội đồng bảo vệ',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: gap),

                    if (demoCouncils.isEmpty)
                      const _EmptyState(
                        icon: Icons.apartment,
                        title: 'Chưa có hội đồng nào.',
                        subtitle: 'Vui lòng quay lại sau.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: demoCouncils.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CouncilCard(item: demoCouncils[i]),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ================== CARD HIỆN HỘI ĐỒNG ================== */

class _CouncilCard extends StatelessWidget {
  const _CouncilCard({required this.item});
  final CouncilItem item;

  String _fmt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final date = '${two(d.day)}/${two(d.month)}/${d.year}';
    final time = '${two(d.hour)}:${two(d.minute)}';
    // Nếu giờ phút = 00:00 thì chỉ hiển thị ngày
    return (d.hour == 0 && d.minute == 0) ? date : '$date $time';
  }

  (Color bg, Color fg, String label) get _badge {
    switch (item.status) {
      case CouncilStatus.upcoming:
        return (const Color(0xFFDBEAFE), const Color(0xFF1E3A8A), 'Sắp diễn ra');
      case CouncilStatus.ongoing:
        return (const Color(0xFFFDE68A), const Color(0xFF92400E), 'Đang diễn ra');
      case CouncilStatus.finished:
        return (const Color(0xFFD1FAE5), const Color(0xFF065F46), 'Đã kết thúc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _badge;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: const Color(0xFFEFF7FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon tròn
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.primaryContainer,
              child: const Icon(Icons.apartment_rounded),
            ),
            const SizedBox(width: 12),

            // nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên + badge trạng thái
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tên hội đồng: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: item.name),
                            ],
                          ),
                        ),
                      ),
                      _Badge(text: label, bg: bg, fg: fg),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Ngày
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Thời gian: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: '${_fmt(item.startDate)}  –  ${_fmt(item.endDate)}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================== COMMON ================== */

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
      constraints: BoxConstraints(minHeight: h * 0.55),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: cs.primary),
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
          Text(subtitle, textAlign: TextAlign.center),
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
