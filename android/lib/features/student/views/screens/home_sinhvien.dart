
import 'package:flutter/material.dart';
import 'trangbaocao.dart'; // ReportListPage
import 'doan.dart';       // ProjectApp
import 'traghatky.dart';  // DiaryListPage  (đổi tên file cho đúng nếu khác)
import 'tranghoidong.dart';    // <-- THÊM: chứa CouncilListPage

void main() {
  runApp(const HomeSinhvienApp());
}

class HomeSinhvienApp extends StatelessWidget {
  const HomeSinhvienApp({super.key});

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

/// Shell sau khi đăng nhập: 6 tab
class AfterLoginShell extends StatefulWidget {
  const AfterLoginShell({super.key});
  @override
  State<AfterLoginShell> createState() => _AfterLoginShellState();
}

class _AfterLoginShellState extends State<AfterLoginShell> {
  int _index = 0;

  void _goReportTab()   => setState(() => _index = 2);
  void _goDiaryTab()    => setState(() => _index = 3);
  void _goCouncilTab()  => setState(() => _index = 4); // <-- THÊM

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTab(
        onGoReport: _goReportTab,
        onGoDiary:  _goDiaryTab,
        onGoCouncil: _goCouncilTab, // <-- THÊM
      ),                          // 0 Trang chủ
      const ProjectApp(),         // 1 Đồ án
      const ReportListPage(),     // 2 Báo cáo
      const DiaryListPage(),      // 3 Nhật ký
      const CouncilListPage(),    // 4 Hội đồng  <-- DÙNG TRANG HỘI ĐỒNG MỚI
      const ProfilePage(),        // 5 Hồ sơ
    ];

    return Scaffold(
      appBar: _HeaderBar(onBellTap: _goReportTab),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// App bar
class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const _HeaderBar({super.key, this.onBellTap});
  final VoidCallback? onBellTap;

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
          const SizedBox(
            width: 55,
            height: 55,
            child: Image(image: AssetImage("assets/images/logo.png")),
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

/// BottomNavigationBar 6 mục
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
          icon: Icon(Icons.fact_check_outlined),
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

/// ================== TAB TRANG CHỦ ==================
class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.onGoReport,
    required this.onGoDiary,
    required this.onGoCouncil, // <-- THÊM
  });
  final VoidCallback onGoReport;
  final VoidCallback onGoDiary;
  final VoidCallback onGoCouncil; // <-- THÊM

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
                      onPressed: () {},
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _TaskTile(
                          title: 'Ghi nhật ký tuần 5',
                          subtitle: 'Hạn: 23:59-20/09',
                          actionText: 'Thực hiện',
                          onAction: onGoDiary,
                          onTap: onGoDiary,
                        ),
                        const Divider(height: 1),
                        const _TaskTile(
                          title: 'Chỉnh sửa đề cương theo góp ý',
                          subtitle: 'Hạn: 23:59-22/09',
                          actionText: 'Thực hiện',
                        ),
                        const Divider(height: 1),
                        const _TaskTile(
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
                      onPressed: onGoReport,
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _NotiTile(
                          color: const Color(0xFFDBEAFE),
                          title: 'Đề cương #P-2025-031 đang chờ duyệt',
                          subtitle: 'GVHD: TS. Trần Văn B • 10:30 18/09',
                          onOpen: onGoReport,
                        ),
                        const Divider(height: 1),
                        _NotiTile(
                          color: const Color(0xFFDCFCE7),
                          title: 'Đề tài của bạn đã được duyệt',
                          subtitle: 'Hệ thống • 09:15 17/09',
                          onOpen: onGoReport,
                        ),
                        const Divider(height: 1),
                        _NotiTile(
                          color: const Color(0xFFFEE2E2),
                          title: 'Nhật ký tuần 4 quá hạn nộp',
                          subtitle: 'Hệ thống • 08:00 16/09',
                          warn: true,
                          onOpen: onGoDiary,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: gap * 1.5),

                  // Tin tức
                  SectionHeader(
                    title: 'Tin tức',
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Xem tất cả'),
                    ),
                  ),
                  const _NewsListCard(),

                  SizedBox(height: gap * 1.5),

                  // HỘI ĐỒNG (nút đi tới danh sách)
                  SectionHeader(
                    title: 'Hội đồng',
                    trailing: TextButton(
                      onPressed: onGoCouncil, // <-- NHẤN -> CHUYỂN TAB HỘI ĐỒNG
                      child: const Text('Xem danh sách'),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.apartment_rounded, size: 18),
                      ),
                      title: const Text('Danh sách hội đồng bảo vệ'),
                      subtitle: const Text('Lịch bảo vệ sắp diễn ra • bấm để mở'),
                      trailing:
                      TextButton(onPressed: onGoCouncil, child: const Text('Mở')),
                      onTap: onGoCouncil,
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
    final style =
    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
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
    this.onAction,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionText;
  final Color? statusColor;
  final bool overdue;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Quá hạn',
                  style: TextStyle(color: Color(0xFF991B1B), fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        trailing: TextButton(onPressed: onAction, child: Text(actionText)),
        onTap: onTap,
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
    this.onOpen,
  });
  final Color color;
  final String title;
  final String subtitle;
  final bool warn;
  final VoidCallback? onOpen;

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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: onOpen, child: const Text('Xem')),
      onTap: onOpen,
    );
  }
}

class _NewsListCard extends StatelessWidget {
  const _NewsListCard();

  @override
  Widget build(BuildContext context) {
    return Card(
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.campaign, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                onPressed: () {},
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

/// ===== Placeholder còn lại =====
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Hồ sơ'));
}
