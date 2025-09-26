import 'package:flutter/material.dart';
import 'baocao_sinhvien.dart';
import 'baocao_tiendo.dart';
import 'baocao_danhsach_sinhvien.dart';

void main() {
  runApp(const Giangvien());
}

class Giangvien extends StatelessWidget {
  const Giangvien({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F7CD3);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đăng ký đề tài',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const HomeGiangvien(),
    );
  }
}

class HomeGiangvien extends StatelessWidget {
  const HomeGiangvien({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F7CD3);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPMS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),

      home: const HomeResponsiveScreen(),
    );
  }
}

class HomeResponsiveScreen extends StatefulWidget {
  const HomeResponsiveScreen({super.key});

  @override
  State<HomeResponsiveScreen> createState() => _HomeResponsiveScreenState();
}

class _HomeResponsiveScreenState extends State<HomeResponsiveScreen> {
  int _Index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeTab(), // Trang chủ
      const ProjectHome(), // TODO: thay bằng màn hình thật
      const ProgressScreen(),
      const ReportScreen(),
      const PlaceholderCenter(title: 'Hồ sơ'),
    ];

    return Scaffold(
      body: pages[_Index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _Index,
        onDestinationSelected: (i) => setState(() => _Index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Sinh viên',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Đồ án',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Giới hạn bề rộng nội dung để đọc tốt trên tablet/desktop
    final double maxContentWidth = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 600
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    return Scaffold(
      appBar: AppBar(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '  KHOA CÔNG NGHỆ THÔNG TIN',
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
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: gap)),
                // ===== Việc tuần này =====
                _SectionHeader(
                  title: 'Việc tuần này',
                  actionText: 'Xem tất cả',
                  onAction: () {},
                  horizontalPadding: pad,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                  sliver: SliverToBoxAdapter(
                    child: _CardList(
                      children: const [
                        _TaskTile(
                          title: 'Duyệt sinh viên đăng kí đề tài',
                          subtitle: 'Hạn: 20/09, 23:59',
                          actionText: 'Thực hiện',
                        ),
                        Divider(height: 1),
                        _TaskTile(
                          title: 'Duyệt đề cương sinh viên',
                          subtitle: 'Hạn: 22/09, 23:59',
                          actionText: 'Thực hiện',
                        ),
                        Divider(height: 1),
                        _TaskTile(
                          title: 'Xác nhận nhật ký sinh viên',
                          subtitle: 'Hạn: 22/09, 23:59',
                          actionText: 'Thực hiện',
                        ),
                        Divider(height: 1),
                        _TaskTile(
                          title: 'Duyệt sinh viên yêu cầu hướng dẫn',
                          subtitle: 'Hạn: 15/09, 23:59',
                          actionText: 'Thực hiện',
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Thông báo =====
                _SectionHeader(
                  title: 'Thông báo',
                  actionText: 'Xem tất cả',
                  onAction: () {},
                  horizontalPadding: pad,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                  sliver: SliverToBoxAdapter(
                    child: _CardList(
                      children: const [
                        _NoticeTile(
                          badgeColor: Color(0xFFDBEAFE),
                          title: 'Sinh viên yêu cầu hướng dẫn',
                          subtitle: 'Khoa công nghệ thông tin • 10:30 18/09',
                        ),
                        Divider(height: 1),
                        _NoticeTile(
                          badgeColor: Color(0xFFDBEAFE),
                          title: 'Sinh viên đăng ký đề tài',
                          subtitle: 'Hệ thống • 09:15 17/09',
                        ),
                        Divider(height: 1),
                        _NoticeTile(
                          badgeColor: Color(0xFFDBEAFE),
                          title: 'Sinh viên nộp đề cương',
                          subtitle: 'Hệ thống • 08:00 16/09',
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Tin tức =====
                _SectionHeader(
                  title: 'Tin tức',
                  actionText: 'Xem tất cả',
                  onAction: () {},
                  horizontalPadding: pad,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                  sliver: SliverToBoxAdapter(
                    child: _CardList(
                      children: const [
                        _NewsTile(
                          title: 'Công bố lịch bảo vệ đợt 10/2025',
                          subtitle: 'Khoa công nghệ thông tin • 10:30 18/09',
                        ),
                        Divider(height: 1),
                        _NewsTile(
                          title: 'Mở đăng ký đề tài cho sinh viên K64',
                          subtitle: 'Hệ thống • 09:15 17/09',
                        ),
                        Divider(height: 1),
                        _NewsTile(
                          title: 'Kế hoạch DATN Kỳ 1 năm học 2025-2026',
                          subtitle: 'Hệ thống • 08:00 16/09',
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Thư viện đề tài =====
                _SectionHeader(
                  title: 'Thư viện đề tài',
                  actionText: 'Xem tất cả đề tài',
                  onAction: () {
                    // TODO: điều hướng danh sách đề tài
                  },
                  horizontalPadding: pad,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SearchField(hintText: 'Tìm kiếm đề tài...'),
                        SizedBox(height: gap),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _ChipPill(label: 'Đợt 2', selected: true),
                            _ChipPill(label: '2023'),
                            _ChipPill(label: 'AI'),
                            _ChipPill(label: 'Mobile'),
                            _ChipPill(label: 'Web'),
                          ],
                        ),
                        SizedBox(height: gap * 2),
                      ],
                    ),
                  ),
                ),

                // Spacer cuối trang
                SliverToBoxAdapter(child: SizedBox(height: pad)),
              ],
            ),
          ),
        ),
      ),

      // ===== Navigation bar (5 mục là hợp lý trên mobile) =====
    );
  }
}
/* -------------------------- Widgets tái sử dụng -------------------------- */

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.horizontalPadding,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            Text(title, style: textStyle),
            const Spacer(),
            TextButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.actionText,
  });
  final String title;
  final String subtitle;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: const Icon(Icons.task_alt, size: 18),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: Text(actionText)),
      onTap: () {},
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.title,
    required this.subtitle,
    required this.badgeColor,
  });
  final String title;
  final String subtitle;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: badgeColor,
        child: const Icon(Icons.notifications, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
      onTap: () {},
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: const Icon(Icons.campaign, size: 18)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
      onTap: () {},
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText});
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (v) {
        /* TODO: tìm kiếm */
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      showCheckmark: false,
      selectedColor: cs.primaryContainer,
      shape: const StadiumBorder(),
    );
  }
}

class PlaceholderCenter extends StatelessWidget {
  const PlaceholderCenter({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
