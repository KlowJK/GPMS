import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/features/home/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/features/home/services/home_service.dart';
import 'package:GPMS/features/home/viewmodels/home_viewmodel.dart';
import 'package:GPMS/features/auth/views/screens/login.dart';
import 'package:GPMS/features/auth/views/screens/forgot_password.dart';
import 'package:GPMS/core/constants//auth_guard.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/shared/components/news_detail_page.dart';
import 'package:GPMS/shared/components/all_news_page.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:GPMS/shared/components/topic_detail_page.dart';
import 'package:GPMS/shared/components/all_topics_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..loadUserFromStorage(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              HomeViewModel(HomeService(), context.read<AuthViewModel>()),
        ),
      ],
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
      // ✅ Wrap home with AuthGuard
      home: const HomeGuestGuard(homeGuest: HomeGuestResponsive()),
      routes: {
        // ✅ Wrap login with AuthGuard
        '/login': (_) => const LoginScreenGuard(loginScreen: LoginScreen()),
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
  late DateFormat _dateFormat;
  bool _didInitDeps = false;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('dd/MM/yy');

    // Load dữ liệu lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadInitialData();
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

    // Refresh khi đăng nhập
    final auth = context.watch<AuthViewModel>();
    final homeVM = context.read<HomeViewModel>();
    if (auth.isLoggedIn && homeVM.hasData) {
      homeVM.refreshData().catchError((_) {
        // Error handled in ViewModel
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _HeaderBar(),
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return LayoutBuilder(
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
                if (viewModel.isLoading) {
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

                // Hiển thị lỗi nếu load failed và chưa có data
                if (viewModel.hasError && !viewModel.hasData) {
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
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.retry(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                // Hiển thị dữ liệu
                final content = Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        try {
                          await viewModel.refreshData();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Không thể làm mới dữ liệu: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                        children: [
                          // Tin tức
                          SectionHeader(
                            title: 'Thông báo',
                            trailing: TextButton(
                              onPressed:
                                  viewModel.notifications == null ||
                                      viewModel.notifications!.isEmpty
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => AllNewsPage(
                                            notifications:
                                                viewModel.notifications!,
                                          ),
                                        ),
                                      );
                                    },
                              child: const Text('Xem thêm'),
                            ),
                          ),
                          _buildNewsList(viewModel, gap),

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
                          _buildTopicsList(viewModel, gap),
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
            );
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

  // Build danh sách tin tức từ ViewModel
  Widget _buildNewsList(HomeViewModel viewModel, double gap) {
    if (viewModel.notifications == null || viewModel.notifications!.isEmpty) {
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

    final displayItems = viewModel.notifications!.take(3).toList();

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

  // Build danh sách đề tài từ ViewModel
  Widget _buildTopicsList(HomeViewModel viewModel, double gap) {
    if (viewModel.topics == null || viewModel.topics!.isEmpty) {
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

    final displayItems = viewModel.topics!.take(4).toList();

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
