import 'package:GPMS/shared/components/app_card_list.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/auth/views/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/core/services/main_service.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/shared/components/NewsDetailPage.dart';
import 'package:GPMS/shared/components/all_news_page.dart';
import 'package:GPMS/shared/models/de_tai.dart';
import 'package:GPMS/shared/components/topic_detail_page.dart';
import 'package:GPMS/shared/components/all_topics_page.dart';
import 'package:GPMS/features/auth/views/screens/forgot_password.dart';

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
      routes: {
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
      },
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
  late Future<List<DeTai>> _deTaiList;
  late DateFormat _dateFormat;
  bool _didInitDeps = false;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Khởi tạo lần đầu
    _dateFormat = DateFormat('dd/MM/yy');
  }

  // HÀM LÀM MỚI DỮ LIỆU
  Future<void> _refreshData() async {
    setState(() {
      _notificationsFuture = MainService.listThongBao();
      _deTaiList = MainService.listDeTai();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    _dateFormat = DateFormat('dd/MM/yy', localeTag);

    if (!_didInitDeps) {
      _didInitDeps = true;
    }

    final auth = context.watch<AuthViewModel>();
    if (auth.isLoggedIn) {
      _refreshData(); // Refresh khi đăng nhập
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
                child: RefreshIndicator(
                  onRefresh: _refreshData,
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
                                    builder: (_) => AllNewsPage(
                                      notifications: notifications,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Xem thêm'),
                            );
                          },
                        ),
                      ),

                      AppCardList<ThongBaoVaTinTuc>(
                        future: _notificationsFuture,
                        maxItems: 3,
                        leadingIcon: Icons.campaign,
                        trailingTextBuilder: (noti) =>
                            _dateFormat.format(noti.ngayDang),
                        itemBuilder: (noti, date) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NewsDetailPage(notification: noti),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: const Icon(Icons.campaign, size: 18),
                            ),
                            title: Text(
                              noti.tieuDe,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              noti.noiDung,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (date != null)
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          );
                        },
                      ),

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
                          child: const Text('Xem thêm'),
                        ),
                      ),

                      AppCardList<DeTai>(
                        future: _deTaiList,
                        maxItems: 4,
                        leadingIcon: Icons.description,
                        showTrailingText: false, // Không có ngày
                        itemBuilder: (dt, _) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TopicDetailPage(deTai: dt),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: const Icon(Icons.description, size: 18),
                            ),
                            title: Text(
                              dt.deTai,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${dt.hocKy} - ${dt.namHoc}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
