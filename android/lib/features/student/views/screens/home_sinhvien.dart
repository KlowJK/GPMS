import 'package:flutter/material.dart';
import '../widgets/app_bar.dart'; // nếu không dùng có thể bỏ import này
import 'doan.dart';              // chứa ProjectApp

void main() => runApp(const GPMSApp());

class GPMSApp extends StatelessWidget {
  const GPMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2563EB);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPMS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFDCDEE4),
      ),
      home: const AfterLoginShell(),
    );
  }
}

/// Shell sau khi đăng nhập
class AfterLoginShell extends StatefulWidget {
  const AfterLoginShell({super.key});
  @override
  State<AfterLoginShell> createState() => _AfterLoginShellState();
}

class _AfterLoginShellState extends State<AfterLoginShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeTab(),        // 0 Trang chủ
      const ProjectApp(),     // 1 Đồ án
      const ReportPage(),     // 2 Báo cáo
      const DiaryPage(),      // 3 Nhật ký
      const CouncilPage(),    // 4 Hội đồng
      const ProfilePage(),    // 5 Hồ sơ
    ];

    return Scaffold(
      appBar: _HeaderBar(
        onBellTap: () => setState(() => _index = 2), // mở tab Báo cáo khi bấm chuông
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// BottomNavigationBar hiển thị đúng như ảnh (6 mục)
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onChanged,
      selectedItemColor: cs.primary,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: 'Đồ án',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_outlined), // biểu tượng "Báo cáo"
          activeIcon: Icon(Icons.fact_check),
          label: 'Báo cáo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note),
          label: 'Nhật ký',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment_outlined),
          activeIcon: Icon(Icons.apartment),
          label: 'Hội đồng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const _HeaderBar({super.key, this.onBellTap});
  final VoidCallback? onBellTap;

  final double _height = 60;
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2563EB),
      elevation: 1,
      centerTitle: false,
      titleSpacing: 12,
      title: Row(
        children: [
          SizedBox(
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
          onPressed: onBellTap,
          tooltip: 'Thông báo/Báo cáo',
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
    );
  }
}

/// ================== TAB TRANG CHỦ ==================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final double maxContentWidth =
          w >= 1200 ? 1100 : w >= 900 ? 900 : w >= 600 ? 600 : w;
          final double pad = w >= 900 ? 24 : 16;
          final double gap = w >= 900 ? 16 : 12;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                children: [
                  // Tiến độ đồ án tốt nghiệp
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(gap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tiến độ đồ án tốt nghiệp',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: StadiumBorder(),
                                ),
                                child: const Text(
                                  'Đề cương',
                                  style: TextStyle(
                                    color: Color(0xFF166534),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gap),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: const LinearProgressIndicator(
                              minHeight: 8,
                              value: 0.30,
                            ),
                          ),
                          SizedBox(height: gap),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Tuần 2: Đang chờ duyệt đề cương\n',
                                  style:
                                  Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextSpan(
                                  text:
                                  'Cần ghi nhật ký tuần 5 trước 23:59 20/09',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: gap),

                  // Việc tuần này
                  SectionHeader(
                    title: 'Việc tuần này',
                    trailing: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllTasksPage()),
                      ),
                      child: const Text('Xem tất cả'),
                    ),
                  ),
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
                          subtitle: 'Hạn: 23:59-20/09',
                          actionText: 'Thực hiện',
                          statusColor: null,
                        ),
                        Divider(height: 1),
                        _TaskTile(
                          title: 'Chỉnh sửa đề cương theo góp ý',
                          subtitle: 'Hạn: 23:59-22/09',
                          actionText: 'Thực hiện',
                          statusColor: null,
                        ),
                        Divider(height: 1),
                        _TaskTile(
                          title: 'Nộp bản cập nhật tuần 4',
                          subtitle: 'Hạn: 23:59-15/09 ',
                          actionText: 'Thực hiện',
                          statusColor: Color(0xFFFCA5A5),
                          overdue: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: gap * 1.5),

                  // Thông báo
                  SectionHeader(
                    title: 'Thông báo',
                    trailing: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllNotiPage()),
                      ),
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        _NotiTile(
                          color: Color(0xFFDBEAFE),
                          title: 'Đề cương #P-2025-031 đang chờ duyệt',
                          subtitle: 'GVHD: TS. Trần Văn B • 10:30 18/09',
                        ),
                        Divider(height: 1),
                        _NotiTile(
                          color: Color(0xFFDCFCE7),
                          title: 'Đề tài của bạn đã được duyệt',
                          subtitle: 'Hệ thống • 09:15 17/09',
                        ),
                        Divider(height: 1),
                        _NotiTile(
                          color: Color(0xFFFEE2E2),
                          title: 'Nhật ký tuần 4 quá hạn nộp',
                          subtitle: 'Hệ thống • 08:00 16/09',
                          warn: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: gap * 1.5),

                  // Tin tức
                  SectionHeader(
                    title: 'Tin tức',
                    trailing: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllNewsPage()),
                      ),
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
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
                          title: 'Kế hoạch DATN Kỳ 1 năm học 2025–2026',
                          subtitle: 'Hệ thống • 08:00 16/09',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: gap * 1.5),

                  // Thư viện đề tài
                  const SectionHeader(title: 'Thư viện đề tài'),
                  _TopicLibraryCard(gap: gap),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// ===== Tiles & Cards =====
class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.statusColor,
    this.overdue = false,
  });

  final String title;
  final String subtitle;
  final String actionText;
  final Color? statusColor;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final borderColor = statusColor ?? const Color(0xFFD1D5DB);
    return Container(
      color: overdue ? const Color(0xFFFEF2F2) : null,
      child: ListTile(
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(title),
        subtitle: Row(
          children: [
            Text(subtitle),
            if (overdue) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Quá hạn',
                  style:
                  TextStyle(color: Color(0xFF991B1B), fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        trailing: TextButton(onPressed: () {}, child: Text(actionText)),
        onTap: () {},
      ),
    );
  }
}

class _NotiTile extends StatelessWidget {
  const _NotiTile({
    required this.color,
    required this.title,
    required this.subtitle,
    this.warn = false,
  });
  final Color color;
  final String title;
  final String subtitle;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(
          warn ? Icons.warning_amber_rounded : Icons.notifications,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
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
      leading: CircleAvatar(
        backgroundColor:
        Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.campaign, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
      onTap: () {},
    );
  }
}

class _TopicLibraryCard extends StatelessWidget {
  const _TopicLibraryCard({required this.gap});
  final double gap;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Card(
      elevation: 0,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ô tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đề tài...',
                prefixIcon: const Icon(Icons.search),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                isDense: true,
              ),
              onSubmitted: (q) {},
            ),
            SizedBox(height: gap),
            // Bộ lọc (chips)
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StaticChip(label: 'Đợt 2', selected: true),
                _StaticChip(label: '2023'),
                _StaticChip(label: 'AI'),
                _StaticChip(label: 'Web'),
                _StaticChip(label: 'Mobile'),
                _StaticChip(label: 'IoT'),
              ],
            ),
            SizedBox(height: gap),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllTopicsPage()),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('Xem tất cả đề tài'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticChip extends StatelessWidget {
  const _StaticChip({required this.label, this.selected = false});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      showCheckmark: false,
      shape: const StadiumBorder(),
    );
  }
}

/// ===== Các trang danh sách mẫu =====
class AllTasksPage extends StatelessWidget {
  const AllTasksPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Ghi nhật ký tuần 5', 'Hạn: 20/09, 23:59 • SV'),
      ('Chỉnh sửa đề cương theo góp ý', 'Hạn: 22/09, 23:59 • SV'),
      ('Nộp bản cập nhật tuần 4', 'Hạn: 15/09, 23:59 • SV'),
    ];
    return _SimpleListScaffold(
      title: 'Tất cả việc tuần',
      items: items,
      icon: Icons.checklist,
    );
  }
}

class AllNotiPage extends StatelessWidget {
  const AllNotiPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Đề cương #P-2025-031 đang chờ duyệt',
      'GVHD: TS. Trần Văn B • 10:30 18/09'),
      ('Đề tài của bạn đã được duyệt', 'Hệ thống • 09:15 17/09'),
      ('Nhật ký tuần 4 quá hạn nộp', 'Hệ thống • 08:00 16/09'),
    ];
    return _SimpleListScaffold(
      title: 'Tất cả thông báo',
      items: items,
      icon: Icons.notifications,
    );
  }
}

class AllNewsPage extends StatelessWidget {
  const AllNewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Công bố lịch bảo vệ đợt 10/2025', 'Khoa CNTT • 10:30 18/09'),
      ('Mở đăng ký đề tài cho sinh viên K64', 'Hệ thống • 09:15 17/09'),
      ('Kế hoạch DATN Kỳ 1 năm học 2025–2026', 'Hệ thống • 08:00 16/09'),
    ];
    return _SimpleListScaffold(
      title: 'Tất cả tin tức',
      items: items,
      icon: Icons.campaign,
    );
  }
}

class AllTopicsPage extends StatelessWidget {
  const AllTopicsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items =
    List.generate(30, (i) => ('Đề tài số ${i + 1}', 'Học kỳ 2 - 9/2025'));
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả đề tài')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đề tài...',
                    prefixIcon: const Icon(Icons.search),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (q) {},
                ),
              );
            }
            final (title, subtitle) = items[index - 1];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.folder, size: 18),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing:
              TextButton(onPressed: () {}, child: const Text('Xem')),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}

/// ===== Phụ trợ =====
class _SimpleListScaffold extends StatelessWidget {
  const _SimpleListScaffold({
    required this.title,
    required this.items,
    required this.icon,
  });
  final String title;
  final List<(String, String)> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (t, s) = items[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon, size: 18),
            ),
            title: Text(t),
            subtitle: Text(s),
            trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
            onTap: () {},
          );
        },
      ),
    );
  }
}

/// ===== Trang placeholder cho 4 tab còn lại =====
class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Báo cáo'));
}

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Nhật ký'));
}

class CouncilPage extends StatelessWidget {
  const CouncilPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Hội đồng'));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Hồ sơ'));
}
