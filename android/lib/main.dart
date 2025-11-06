import 'package:GPMS/shared/components/app_card_list.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/auth/views/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/core/services/main_service.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/shared/components/news_detail_page.dart';
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
  // Cache dữ liệu
  List<ThongBaoVaTinTuc>? _cachedNotifications;
  List<DeTai>? _cachedDeTai;

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  late DateFormat _dateFormat;
  bool _didInitDeps = false;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('dd/MM/yy');
    _loadInitialData();
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
    if (auth.isLoggedIn && _cachedNotifications != null) {
      _refreshData();
    }
  }

  // Load dữ liệu lần đầu (song song)
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      // Load song song cả 2 API
      final results = await Future.wait([
        MainService.listThongBao(),
        MainService.listDeTai(),
      ]);

      if (mounted) {
        setState(() {
          _cachedNotifications = results[0] as List<ThongBaoVaTinTuc>;
          _cachedDeTai = results[1] as List<DeTai>;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _errorMessage = 'Không thể tải dữ liệu: $e';
        });
      }
    }
  }

  // Làm mới dữ liệu (kéo xuống)
  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      // Load song song cả 2 API
      final results = await Future.wait([
        MainService.listThongBao(),
        MainService.listDeTai(),
      ]);

      if (mounted) {
        setState(() {
          _cachedNotifications = results[0] as List<ThongBaoVaTinTuc>;
          _cachedDeTai = results[1] as List<DeTai>;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _errorMessage = 'Không thể làm mới dữ liệu';
        });

        // Hiển thị snackbar khi refresh failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể làm mới dữ liệu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
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

            // Hiển thị loading skeleton lần đầu
            if (_isInitialLoading) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                    children: [
                      _buildSkeletonSection(gap),
                      SizedBox(height: gap),
                      _buildSkeletonSection(gap),
                    ],
                  ),
                ),
              );
            }

            // Hiển thị lỗi nếu load failed
            if (_errorMessage != null && _cachedNotifications == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadInitialData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Hiển thị dữ liệu đã cache
            final content = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                    children: [
                      // Tin tức
                      SectionHeader(
                        title: 'Tin tức',
                        trailing: TextButton(
                          onPressed:
                              _cachedNotifications == null ||
                                  _cachedNotifications!.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AllNewsPage(
                                        notifications: _cachedNotifications!,
                                      ),
                                    ),
                                  );
                                },
                          child: const Text('Xem thêm'),
                        ),
                      ),
                      _buildNewsList(gap),

                      SizedBox(height: gap),

                      // Đề tài nổi bật
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
                      _buildTopicsList(gap),
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

  // Widget skeleton loading
  Widget _buildSkeletonSection(double gap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.grey[300], radius: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build danh sách tin tức từ cache
  Widget _buildNewsList(double gap) {
    if (_cachedNotifications == null || _cachedNotifications!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Chưa có tin tức nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final displayItems = _cachedNotifications!.take(3).toList();

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final noti = displayItems[index];
          final date = _dateFormat.format(noti.ngayDang);

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewsDetailPage(notification: noti),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.campaign, size: 18),
            ),
            title: Text(
              noti.tieuDe,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              noti.noiDung,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            trailing: Text(
              date,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          );
        },
      ),
    );
  }

  // Build danh sách đề tài từ cache
  Widget _buildTopicsList(double gap) {
    if (_cachedDeTai == null || _cachedDeTai!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Chưa có đề tài nào',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final displayItems = _cachedDeTai!.take(4).toList();

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dt = displayItems[index];

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TopicDetailPage(deTai: dt)),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.description, size: 18),
            ),
            title: Text(
              dt.deTai,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${dt.hocKy} - ${dt.namHoc}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          );
        },
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
          SizedBox(
            width: 55,
            height: 55,
            child: Image.asset("assets/images/logo.png"),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
