import 'package:flutter/material.dart';
import 'package:GPMS/features/student/views/widgets/task_tile.dart';
import 'package:GPMS/features/student/views/widgets/all_tasks_page.dart';
import 'package:GPMS/features/student/views/widgets/section_header.dart';
import 'package:GPMS/features/student/views/widgets/noti_tile.dart';
import 'package:GPMS/features/student/views/widgets/all_noti_page.dart';
import 'package:GPMS/features/student/views/widgets/all_news_page.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/shared/models/de_tai.dart';
import 'package:GPMS/core/services/main_service.dart';
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

class _TrangChuPageState extends State<TrangChuPage> {
  // Cache dữ liệu
  List<ThongBaoVaTinTuc>? _cachedNews;
  List<DeTai>? _cachedTopics;

  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  late DateFormat _dateFormat;

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
          _cachedNews = results[0] as List<ThongBaoVaTinTuc>;
          _cachedTopics = results[1] as List<DeTai>;
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
          _cachedNews = results[0] as List<ThongBaoVaTinTuc>;
          _cachedTopics = results[1] as List<DeTai>;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
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
      appBar: CustomAppBar(),
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

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: RefreshIndicator(
                  onRefresh: _refreshData,
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
                                          ?.copyWith(
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    TextSpan(
                                      text:
                                          'Cần ghi nhật ký tuần 5 trước 23:59 20/09',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
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
                            MaterialPageRoute(
                              builder: (_) => const AllTasksPage(),
                            ),
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
                        child: Column(
                          children: const [
                            TaskTile(
                              title: 'Ghi nhật ký tuần 5',
                              subtitle: 'Hạn: 23:59-20/09',
                              actionText: 'Thực hiện',
                              statusColor: null,
                            ),
                            Divider(height: 1),
                            TaskTile(
                              title: 'Chỉnh sửa đề cương theo góp ý',
                              subtitle: 'Hạn: 23:59-22/09',
                              actionText: 'Thực hiện',
                              statusColor: null,
                            ),
                            Divider(height: 1),
                            TaskTile(
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
                            MaterialPageRoute(
                              builder: (_) => const AllNotiPage(),
                            ),
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
                        child: Column(
                          children: const [
                            NotiTile(
                              color: Color(0xFFDBEAFE),
                              title: 'Đề cương #P-2025-031 đang chờ duyệt',
                              subtitle: 'GVHD: TS. Trần Văn B • 10:30 18/09',
                            ),
                            Divider(height: 1),
                            NotiTile(
                              color: Color(0xFFDCFCE7),
                              title: 'Đề tài của bạn đã được duyệt',
                              subtitle: 'Hệ thống • 09:15 17/09',
                            ),
                            Divider(height: 1),
                            NotiTile(
                              color: Color(0xFFFEE2E2),
                              title: 'Nhật ký tuần 4 quá hạn nộp',
                              subtitle: 'Hệ thống • 08:00 16/09',
                              warn: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: gap * 1.5),

                      // Tin tức - PHẦN ĐỘNG
                      SectionHeader(
                        title: 'Tin tức',
                        trailing: _cachedNews != null && _cachedNews!.isNotEmpty
                            ? TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AllNewsPage(),
                                  ),
                                ),
                                child: const Text('Xem thêm'),
                              )
                            : null,
                      ),
                      _buildNewsSection(gap),

                      SizedBox(height: gap * 1.5),

                      // Thư viện đề tài - PHẦN ĐỘNG
                      SectionHeader(
                        title: 'Đề tài nổi bật',
                        trailing:
                            _cachedTopics != null && _cachedTopics!.isNotEmpty
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
                      _buildTopicLibrarySection(gap),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build section tin tức động
  Widget _buildNewsSection(double gap) {
    // Đang loading lần đầu
    if (_isInitialLoading) {
      return _buildSkeletonCard(3);
    }

    // Có lỗi và chưa có cache
    if (_errorMessage != null && _cachedNews == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
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
          ),
        ),
      );
    }

    // Không có dữ liệu
    if (_cachedNews == null || _cachedNews!.isEmpty) {
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

    // Hiển thị dữ liệu
    final displayItems = _cachedNews!.take(3).toList();

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

  // Build tile tin tức
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
        news.ngayDang != null ? dateStr : '',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Build section thư viện đề tài động
  Widget _buildTopicLibrarySection(double gap) {
    // Đang loading lần đầu
    if (_isInitialLoading) {
      return _buildSkeletonCard(4);
    }

    // Có lỗi và chưa có cache
    if (_errorMessage != null && _cachedTopics == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
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
          ),
        ),
      );
    }

    // Không có dữ liệu
    if (_cachedTopics == null || _cachedTopics!.isEmpty) {
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

    // Hiển thị dữ liệu
    final displayItems = _cachedTopics!.take(4).toList();

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

  // Build tile đề tài
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

  // Widget skeleton loading
  Widget _buildSkeletonCard(int itemCount) {
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
