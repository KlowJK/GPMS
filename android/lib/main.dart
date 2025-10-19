import 'package:flutter/material.dart';
import 'package:GPMS/features/auth/views/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/core/services/main_service.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/shared/NewsDetailPage.dart';
import 'package:GPMS/shared/AllNewsPage.dart';

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
        scaffoldBackgroundColor: const Color(0xFFE3E3E8),
      ),
      home: const HomeGuestResponsive(),
      routes: {'/login': (_) => const LoginScreen()},
    );
  }
}

class HomeGuestResponsive extends StatefulWidget {
  const HomeGuestResponsive({super.key});

  @override
  State<HomeGuestResponsive> createState() => _HomeGuestResponsiveState();
}

class _HomeGuestResponsiveState extends State<HomeGuestResponsive> {
  late Future<List<ThongBaoVaTinTuc>> _notificationsFuture;
  late DateFormat _dateFormat;
  bool _didInitDeps = false;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu 1 lần duy nhất
    _notificationsFuture = MainService.listThongBao();
    // Định dạng mặc định, sẽ cập nhật theo locale trong didChangeDependencies()
    _dateFormat = DateFormat('dd/MM/yy');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Những gì phụ thuộc context: cập nhật DateFormat theo locale hiện tại
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    _dateFormat = DateFormat('dd/MM/yy', localeTag);

    // Nếu bạn cần chạy logic phụ thuộc Provider/InheritedWidget lần đầu
    if (!_didInitDeps) {
      _didInitDeps = true;
      // Ví dụ (nếu cần): final auth = context.read<AuthViewModel>();
      // if (auth.isLoggedIn) { ... }
    }

    // Nếu muốn refresh khi dependency thay đổi (vd: auth state), có thể watch provider ở đây
    final auth = context.watch<AuthViewModel>();
    if (auth.isLoggedIn) {
      _notificationsFuture = MainService.listThongBao();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _HeaderBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final double maxContentWidth = w >= 1200
                ? 1100
                : w >= 900
                ? 900
                : w >= 600
                ? 600
                : w;
            final double pad = w >= 900 ? 24 : 16;
            final double gap = w >= 900 ? 16 : 12;

            final content = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                  children: [
                    SectionHeader(
                      title: 'Tin tức',
                      trailing: FutureBuilder<List<ThongBaoVaTinTuc>>(
                        future: _notificationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final notifications = snapshot.data!;
                          return TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AllNewsPage(notifications: notifications),
                                ),
                              );
                            },
                            child: const Text('Xem thêm'),
                          );
                        },
                      ),
                    ),

                    FutureBuilder<List<ThongBaoVaTinTuc>>(
                      future: _notificationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Lỗi: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Không có thông báo'),
                          );
                        }

                        final notifications = snapshot.data!;
                        final top3 = notifications.take(3).toList();
                        return Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          margin: EdgeInsets.only(bottom: gap),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: List.generate(top3.length, (i) {
                              final notification = top3[i];
                              final formattedDate = _dateFormat.format(
                                notification.ngayDang,
                              );
                              return Column(
                                children: [
                                  _NewsItem(
                                    title: notification.tieuDe,
                                    subtitle: notification.noiDung,
                                    date: formattedDate,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => NewsDetailPage(
                                            notification: notification,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (i < top3.length - 1)
                                    const Divider(height: 1),
                                ],
                              );
                            }),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: gap),
                    const SectionHeader(title: 'Thư viện đề tài'),
                    _TopicLibraryCard(gap: gap),

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
          SizedBox(
            width: 55,
            height: 55,
            child: Image.asset("assets/images/logo.png"),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'THUY LOI UNIVERSITY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
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
    required this.date,
  });

  final String title;
  final String subtitle;
  final String date;
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
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      dense: false,
      trailing: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Text(
          date,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
        ),
      ),
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
              children: const [
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

class AllTopicsPage extends StatefulWidget {
  const AllTopicsPage({super.key});

  @override
  State<AllTopicsPage> createState() => _AllTopicsPageState();
}

class _AllTopicsPageState extends State<AllTopicsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample data
  final List<(String, String)> _allItems = List.generate(
    30,
    (i) => ('Đề tài số ${i + 1}', 'Học kỳ 2 - 9/2025'),
  );

  List<(String, String)> get _filteredItems {
    if (_searchQuery.isEmpty) return _allItems;
    return _allItems
        .where(
          (item) =>
              item.$1.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.$2.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi text để update danh sách theo thời gian thực
    _searchController.addListener(() {
      final q = _searchController.text;
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tất cả đề tài',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: SafeArea(
        child: Material(
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredItems.length + 1,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _searchController,
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
                  ),
                );
              }
              final (title, subtitle) = _filteredItems[index - 1];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF1F3F6),
                  child: Icon(Icons.folder, size: 18),
                ),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Xem'),
                ),
                onTap: () {},
              );
            },
          ),
        ),
      ),
    );
  }
}
