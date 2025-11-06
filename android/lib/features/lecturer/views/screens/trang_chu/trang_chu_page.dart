import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/views/widgets/news_tile.dart';
import 'package:GPMS/features/lecturer/views/widgets/card_list.dart';
import 'package:GPMS/features/lecturer/views/widgets/section_header.dart';
import 'package:GPMS/features/lecturer/views/widgets/task_tile.dart';
import 'package:GPMS/features/lecturer/views/widgets/notice_tile.dart';
import 'package:GPMS/shared/components/all_news_page.dart';
import 'package:GPMS/features/home/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:GPMS/shared/components/app_card_list.dart';
import 'package:GPMS/shared/components/topic_detail_page.dart';
import 'package:GPMS/shared/components/all_topics_page.dart';
import 'package:GPMS/features/home/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/lecturer/views/widgets/custom_app_bar.dart';
import 'package:GPMS/shared/components/news_detail_page.dart';

class TrangChuPage extends StatefulWidget {
  const TrangChuPage({super.key});

  @override
  State<TrangChuPage> createState() => TrangChuState();
}

class TrangChuState extends State<TrangChuPage>
    with AutomaticKeepAliveClientMixin {
  // Giữ state khi switch tab
  @override
  bool get wantKeepAlive => true;

  late DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('dd/MM/yy');

    // Load data từ ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<HomeViewModel>();
      if (!viewModel.hasData && !viewModel.isLoading) {
        viewModel.loadInitialData();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    _dateFormat = DateFormat('dd/MM/yy', localeTag);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for KeepAlive!

    return Scaffold(
      appBar: const CustomAppBar(),
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

                // Loading skeleton
                if (viewModel.isLoading) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                        children: [
                          _buildSkeletonCard(3),
                          SizedBox(height: gap),
                          _buildSkeletonCard(4),
                        ],
                      ),
                    ),
                  );
                }

                // Error state
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

                // Main content
                return Center(
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
                          // ===== Việc tuần này =====
                          SectionHeader(
                            title: 'Việc tuần này',
                            trailing: TextButton(
                              onPressed: () {},
                              child: const Text('Xem tất cả'),
                            ),
                          ),
                          CardList(
                            children: const [
                              TaskTile(
                                title: 'Duyệt sinh viên đăng kí đề tài',
                                subtitle: 'Hạn: 20/09, 23:59',
                                actionText: 'Thực hiện',
                              ),
                              Divider(height: 1),
                              TaskTile(
                                title: 'Duyệt đề cương sinh viên',
                                subtitle: 'Hạn: 22/09, 23:59',
                                actionText: 'Thực hiện',
                              ),
                              Divider(height: 1),
                              TaskTile(
                                title: 'Xác nhận nhật ký sinh viên',
                                subtitle: 'Hạn: 22/09, 23:59',
                                actionText: 'Thực hiện',
                              ),
                              Divider(height: 1),
                              TaskTile(
                                title: 'Duyệt sinh viên yêu cầu hướng dẫn',
                                subtitle: 'Hạn: 15/09, 23:59',
                                actionText: 'Thực hiện',
                              ),
                            ],
                          ),

                          SizedBox(height: gap * 1.5),

                          // ===== Thông báo =====
                          SectionHeader(
                            title: 'Thông báo',
                            trailing: TextButton(
                              onPressed: () {},
                              child: const Text('Xem tất cả'),
                            ),
                          ),
                          CardList(
                            children: const [
                              NoticeTile(
                                badgeColor: Color(0xFFDBEAFE),
                                title: 'Sinh viên yêu cầu hướng dẫn',
                                subtitle:
                                    'Khoa công nghệ thông tin • 10:30 18/09',
                              ),
                              Divider(height: 1),
                              NoticeTile(
                                badgeColor: Color(0xFFDBEAFE),
                                title: 'Sinh viên đăng ký đề tài',
                                subtitle: 'Hệ thống • 09:15 17/09',
                              ),
                              Divider(height: 1),
                              NoticeTile(
                                badgeColor: Color(0xFFDBEAFE),
                                title: 'Sinh viên nộp đề cương',
                                subtitle: 'Hệ thống • 08:00 16/09',
                              ),
                            ],
                          ),

                          SizedBox(height: gap * 1.5),

                          // ===== Tin tức - Dynamic from ViewModel =====
                          SectionHeader(
                            title: 'Tin tức',
                            trailing:
                                viewModel.notifications != null &&
                                    viewModel.notifications!.isNotEmpty
                                ? TextButton(
                                    onPressed: () {
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
                                  )
                                : null,
                          ),
                          _buildNewsContent(viewModel),

                          SizedBox(height: gap * 1.5),

                          // ===== Đề tài nổi bật - Dynamic from ViewModel =====
                          SectionHeader(
                            title: 'Đề tài nổi bật',
                            trailing:
                                viewModel.topics != null &&
                                    viewModel.topics!.isNotEmpty
                                ? TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const AllTopicsPage(),
                                        ),
                                      );
                                    },
                                    child: const Text('Xem thêm'),
                                  )
                                : null,
                          ),
                          _buildTopicsContent(viewModel),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Build nội dung tin tức từ ViewModel
  Widget _buildNewsContent(HomeViewModel viewModel) {
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
      clipBehavior: Clip.antiAlias,
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

  // Build nội dung đề tài từ ViewModel
  Widget _buildTopicsContent(HomeViewModel viewModel) {
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
      clipBehavior: Clip.antiAlias,
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

  // Widget skeleton loading
  Widget _buildSkeletonCard(int itemCount) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return Padding(
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
                        width: 150,
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
          );
        },
      ),
    );
  }
}
