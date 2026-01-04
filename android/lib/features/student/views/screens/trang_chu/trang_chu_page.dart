import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/views/widgets/section_header.dart';
import 'package:GPMS/shared/components/all_news_page.dart';
import 'package:GPMS/features/home/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:GPMS/features/home/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/student/views/widgets/custom_app_bar.dart';
import 'package:GPMS/shared/components/news_detail_page.dart';
import 'package:GPMS/shared/components/topic_detail_page.dart';
import 'package:GPMS/shared/components/all_topics_page.dart';

class TrangChuPage extends StatefulWidget {
  const TrangChuPage({super.key});

  @override
  State<TrangChuPage> createState() => _TrangChuPageState();
}

class _TrangChuPageState extends State<TrangChuPage>
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
      appBar: CustomAppBar(),
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
                          _buildSkeletonCard(3, gap),
                          SizedBox(height: gap),
                          _buildSkeletonCard(4, gap),
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
                          SectionHeader(
                            title: 'Thông báo',
                            trailing:
                                viewModel.notifications != null &&
                                    viewModel.notifications!.isNotEmpty
                                ? TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AllNewsPage(
                                          notifications:
                                              viewModel.notifications!,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Xem thêm'),
                                  )
                                : null,
                          ),
                          _buildNewsSection(viewModel, gap),

                          SizedBox(height: gap * 1),

                          // Đề tài nổi bật - Dynamic from ViewModel
                          SectionHeader(
                            title: 'Đề tài nổi bật',
                            trailing:
                                viewModel.topics != null &&
                                    viewModel.topics!.isNotEmpty
                                ? TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AllTopicsPage(),
                                      ),
                                    ),
                                    child: const Text('Xem thêm'),
                                  )
                                : null,
                          ),
                          _buildTopicsSection(viewModel, gap),
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

  // Build progress card (static)
  Widget _buildProgressCard(BuildContext context, double gap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: TextStyle(color: Color(0xFF166534), fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: const LinearProgressIndicator(minHeight: 8, value: 0.30),
            ),
            SizedBox(height: gap),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Tuần 2: Đang chờ duyệt đề cương\n',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: 'Cần ghi nhật ký tuần 5 trước 23:59 20/09',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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

  // Build news section from ViewModel
  Widget _buildNewsSection(HomeViewModel viewModel, double gap) {
    if (viewModel.notifications == null || viewModel.notifications!.isEmpty) {
      return _buildEmptyCard('Chưa có tin tức nào');
    }

    final displayItems = viewModel.notifications!.take(3).toList();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final news = displayItems[index];
          return _buildNewsTile(news);
        },
      ),
    );
  }

  // Build news tile
  Widget _buildNewsTile(ThongBaoVaTinTuc news) {
    final dateStr = _dateFormat.format(news.ngayDang);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailPage(notification: news)),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.campaign, size: 18),
      ),
      title: Text(
        news.tieuDe,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${news.noiDung ?? 'Hệ thống'} • $dateStr',
        maxLines: 1,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: Text(
        dateStr,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Build topics section from ViewModel
  Widget _buildTopicsSection(HomeViewModel viewModel, double gap) {
    if (viewModel.topics == null || viewModel.topics!.isEmpty) {
      return _buildEmptyCard('Chưa có đề tài nào');
    }

    final displayItems = viewModel.topics!.take(4).toList();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final topic = displayItems[index];
          return _buildTopicTile(topic);
        },
      ),
    );
  }

  // Build topic tile
  Widget _buildTopicTile(DeTai topic) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TopicDetailPage(deTai: topic)),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.description, size: 18),
      ),
      title: Text(
        topic.deTai,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${topic.hocKy} - ${topic.namHoc}',
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Build empty card
  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  // Widget skeleton loading
  Widget _buildSkeletonCard(int itemCount, double gap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
