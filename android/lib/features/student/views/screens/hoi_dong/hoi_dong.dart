import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/models/hoi_dong_item.dart';
import 'package:GPMS/features/student/viewmodels/hoi_dong_viewmodel.dart';

/* ================== COUNCIL LIST PAGE (MVVM) ================== */

class HoiDong extends StatelessWidget {
  const HoiDong({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HoiDongViewModel()..fetchForCurrentStudent(fallbackToAll: true),
      child: const _HoiDongBody(),
    );
  }
}

class _HoiDongBody extends StatelessWidget {
  const _HoiDongBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Hội đồng'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final double maxW = w >= 1200
                ? 1100
                : w >= 900
                ? 900
                : w >= 600
                ? 600
                : w;
            final double pad = w >= 900 ? 24 : 16;
            final double gap = w >= 900 ? 16 : 12;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Consumer<HoiDongViewModel>(
                  builder: (context, vm, _) {
                    // show error once via SnackBar
                    if (vm.error != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (vm.error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(vm.error!)));
                          vm.clearError();
                        }
                      });
                    }

                    return ListView(
                      padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
                      children: [
                        Text(
                          'Danh sách hội đồng bảo vệ',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: gap),

                        if (vm.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (vm.items.isEmpty)
                          const _EmptyState(
                            icon: Icons.apartment,
                            title: 'Chưa có hội đồng nào.',
                            subtitle: 'Vui lòng quay lại sau.',
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vm.items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _CouncilCardHoiDong(item: vm.items[i]),
                          ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ================== CARD HIỂN THỊ HỘI ĐỒNG (từ HoiDongItem) ================== */

class _CouncilCardHoiDong extends StatelessWidget {
  const _CouncilCardHoiDong({required this.item});
  final HoiDongItem item;

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    String two(int v) => v.toString().padLeft(2, '0');
    final date = '${two(d.day)}/${two(d.month)}/${d.year}';
    final time = '${two(d.hour)}:${two(d.minute)}';
    return (d.hour == 0 && d.minute == 0) ? date : '$date $time';
  }

  (Color bg, Color fg, String label) get _badge {
    final nowUtc = DateTime.now().toUtc();
    final start = item.thoiGianBatDau;
    final end = item.thoiGianKetThuc;

    DateTime? toUtcSafe(DateTime? dt) {
      if (dt == null) return null;
      try {
        return dt.toUtc();
      } catch (_) {
        return dt;
      }
    }

    final startUtc = toUtcSafe(start);
    DateTime? endUtc = toUtcSafe(end);

    // If endUtc is present and looks like a date-only (midnight UTC), treat it as end of day to be inclusive
    if (endUtc != null &&
        endUtc.hour == 0 &&
        endUtc.minute == 0 &&
        endUtc.second == 0 &&
        endUtc.millisecond == 0 &&
        endUtc.microsecond == 0) {
      endUtc = endUtc
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
    }

    // Defensive: if backend returned start after end, swap them and log
    if (startUtc != null && endUtc != null && startUtc.isAfter(endUtc)) {
      debugPrint(
        '[HoiDong] Warning: startUtc > endUtc for id=${item.id}; swapping values startUtc=$startUtc endUtc=$endUtc',
      );
      final tmp = startUtc;
      final newStartUtc = endUtc;
      final newEndUtc = tmp;
      final isBefore = nowUtc.isBefore(newStartUtc!);
      final isAfter = nowUtc.isAfter(newEndUtc);
      debugPrint(
        '[HoiDong] id=${item.id} corrected startUtc=$newStartUtc endUtc=$newEndUtc nowUtc=$nowUtc isBefore=$isBefore isAfter=$isAfter',
      );
      if (isBefore) {
        return (
          const Color(0xFFDBEAFE),
          const Color(0xFF1E3A8A),
          'Sắp diễn ra',
        );
      }
      if (isAfter) {
        return (
          const Color(0xFFD1FAE5),
          const Color(0xFF065F46),
          'Đã kết thúc',
        );
      }
      return (const Color(0xFFFDE68A), const Color(0xFF92400E), 'Đang diễn ra');
    }

    // If both start and end exist, determine status from times (inclusive end)
    if (startUtc != null && endUtc != null) {
      final isBefore = nowUtc.isBefore(startUtc);
      final isAfter = nowUtc.isAfter(endUtc);
      debugPrint(
        '[HoiDong] id=${item.id} startUtc=$startUtc endUtc=$endUtc nowUtc=$nowUtc isBefore=$isBefore isAfter=$isAfter',
      );
      if (isBefore) {
        return (
          const Color(0xFFDBEAFE),
          const Color(0xFF1E3A8A),
          'Sắp diễn ra',
        );
      }
      if (isAfter) {
        return (
          const Color(0xFFD1FAE5),
          const Color(0xFF065F46),
          'Đã kết thúc',
        );
      }
      // now is between start and end (inclusive)
      return (const Color(0xFFFDE68A), const Color(0xFF92400E), 'Đang diễn ra');
    }

    // Fallback to textual status if dates are not present
    final status = (item.trangThai ?? '').toLowerCase();
    if (status.contains('upcoming') ||
        status.contains('sap') ||
        status.contains('sapdienra') ||
        status.contains('sắp')) {
      return (const Color(0xFFDBEAFE), const Color(0xFF1E3A8A), 'Sắp diễn ra');
    }
    if (status.contains('ongoing') ||
        status.contains('dang') ||
        status.contains('đang')) {
      return (const Color(0xFFFDE68A), const Color(0xFF92400E), 'Đang diễn ra');
    }
    return (const Color(0xFFD1FAE5), const Color(0xFF065F46), 'Đã kết thúc');
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
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.primaryContainer,
              child: const Icon(Icons.apartment_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tên hội đồng: ',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: item.tenHoiDong),
                            ],
                          ),
                        ),
                      ),
                      _Badge(text: label, bg: bg, fg: fg),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Thời gian: ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text:
                              '${_fmt(item.thoiGianBatDau)}  –  ${_fmt(item.thoiGianKetThuc)}',
                        ),
                      ],
                    ),
                  ),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
      decoration: const ShapeDecoration(shape: StadiumBorder()),
      child: Container(
        decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }
}
