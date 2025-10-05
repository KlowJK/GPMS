import 'package:flutter/material.dart';
import 'features/auth/views/screens/login.dart';
import 'package:provider/provider.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel()..loadUserFromStorage(),
      child: const GPMSApp(),
    ),
  );
}

class GPMSApp extends StatelessWidget {
  const GPMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF2563EB);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPMS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFDCDEE4),
      ),
      home: const HomeGuestResponsive(),
      routes: {'/login': (_) => const LoginScreen()},
    );
  }
}

class HomeGuestResponsive extends StatelessWidget {
  const HomeGuestResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _HeaderBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // Giới hạn bề rộng nội dung để đọc thoải mái trên màn hình lớn
            final double maxContentWidth = w >= 1200
                ? 1100
                : w >= 900
                ? 900
                : w >= 600
                ? 600
                : w; // mobile: full width

            // khoảng cách, kích cỡ chữ linh hoạt theo kích thước màn hình
            final double pad = w >= 900 ? 24 : 16;
            final double gap = w >= 900 ? 16 : 12;

            final content = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                  children: [
                    // Tin tức
                    SectionHeader(
                      title: 'Tin tức',
                      trailing: TextButton(
                        onPressed: () {},
                        child: const Text('Xem thêm'),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.only(bottom: gap),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _NewsItem(
                            title: 'Công bố lịch bảo vệ đợt 10/2025',
                            subtitle: 'Khoa Công nghệ Thông tin • 10:30 18/09',
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          _NewsItem(
                            title: 'Mở đăng ký đề tài cho sinh viên K64',
                            subtitle: 'Hệ thống • 09:15 17/09',
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          _NewsItem(
                            title: 'Kế hoạch ĐATN Kỳ 1 năm học 2025–2026',
                            subtitle: 'Hệ thống • 08:00 16/09',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // Thư viện đề tài (tìm kiếm + bộ lọc)
                    SizedBox(height: gap),
                    const SectionHeader(title: 'Thư viện đề tài'),
                    _TopicLibraryCard(gap: gap),

                    // Danh sách đề tài nổi bật
                    SizedBox(height: gap),
                    SectionHeader(
                      title: 'Đề tài nổi bật',
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllTopicsPage(),
                            ),
                          );
                        },
                        child: const Text('Xem tất cả đề tài'),
                      ),
                    ),

                    _TopicList(gap: gap),
                  ],
                ),
              ),
            );

            // Với tablet/desktop có thể tách layout 2 cột (tuỳ ý bật)
            if (w >= 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: content)],
              );
            }
            return content;
          },
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  _HeaderBar({super.key});

  final double _height = 60;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2563EB),
      elevation: 1,
      centerTitle: false,
      titleSpacing: 12,
      title: Row(
        children: [
          // Logo placeholder
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FilledButton.tonal(
            // Trong _HeaderBar actions:
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },

            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Đăng nhập'),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
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

class _NewsItem extends StatelessWidget {
  const _NewsItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.campaign, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: onTap, child: const Text('Xem')),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      dense: false,
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
            // Bộ lọc (chips) co giãn theo chiều ngang
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(label: 'Đợt 2', selected: true),
                _FilterChip(label: '2023'),
                _FilterChip(label: 'AI'),
                _FilterChip(label: 'Web'),
                _FilterChip(label: 'Mobile'),
                _FilterChip(label: 'IoT'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  const _FilterChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  late bool _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selected: _selected,
      onSelected: (v) => setState(() => _selected = v),
      showCheckmark: false,
      shape: const StadiumBorder(),
    );
  }
}

class _TopicList extends StatelessWidget {
  const _TopicList({required this.gap});
  final double gap;

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Hệ thống quản lý đề tài', 'Học kỳ 2 - 9/2025'),
      ('Ứng dụng học tập di động', 'Học kỳ 2 - 9/2025'),
      ('Nhận diện khuôn mặt', 'Học kỳ 2 - 9/2025'),
    ];

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: gap),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (title, subtitle) = items[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.folder, size: 18),
            ),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class AllTopicsPage extends StatelessWidget {
  const AllTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (i) => ('Đề tài số ${i + 1}', 'Học kỳ 2 - 9/2025'),
    );

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
              // Ô tìm kiếm ở đầu danh sách
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
                  onSubmitted: (q) {
                    // TODO: gọi search
                  },
                ),
              );
            }
            final (title, subtitle) = items[index - 1];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.folder, size: 18),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
