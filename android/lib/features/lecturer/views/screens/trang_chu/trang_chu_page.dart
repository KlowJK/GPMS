import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/views/widgets/news_tile.dart';
import 'package:GPMS/features/lecturer/views/widgets/card_list.dart';
import 'package:GPMS/features/lecturer/views/widgets/section_header.dart';
import 'package:GPMS/features/lecturer/views/widgets/task_tile.dart';
import 'package:GPMS/features/lecturer/views/widgets/notice_tile.dart';
import 'package:GPMS/shared/components/all_news_page.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/shared/models/de_tai.dart';
import 'package:GPMS/shared/components/app_card_list.dart';
import 'package:GPMS/shared/components/topic_detail_page.dart';
import 'package:GPMS/shared/components/all_topics_page.dart';
import 'package:GPMS/core/services/main_service.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/lecturer/views/widgets/custom_app_bar.dart';
import 'package:GPMS/shared/components/news_detail_page.dart';

class TrangChuPage extends StatefulWidget {
  const TrangChuPage({super.key});

  @override
  State<TrangChuPage> createState() => TrangChuState();
}

class TrangChuState extends State<TrangChuPage> {
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
      appBar: const CustomAppBar(),
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
                            subtitle: 'Khoa công nghệ thông tin • 10:30 18/09',
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

                      // ===== Tin tức - PHẦN ĐỘNG =====
                      SectionHeader(
                        title: 'Tin tức',
                        trailing: _cachedNews != null && _cachedNews!.isNotEmpty
                            ? TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AllNewsPage(
                                        notifications: _cachedNews!,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Xem thêm'),
                              )
                            : null,
                      ),

                      _buildNewsContent(),

                      SizedBox(height: gap * 1.5),

                      // ===== Đề tài nổi bật - PHẦN ĐỘNG =====
                      SectionHeader(
                        title: 'Đề tài nổi bật',
                        trailing:
                            _cachedTopics != null && _cachedTopics!.isNotEmpty
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

                      _buildTopicsContent(),
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

  // Build nội dung tin tức (trả về Widget thông thường cho ListView)
  Widget _buildNewsContent() {
    // Đang loading lần đầu
    if (_isInitialLoading) {
      return _buildSkeletonCard(3);
    }

    // Có lỗi và chưa có cache
    if (_errorMessage != null && _cachedNews == null) {
      return Card(
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

  // Build nội dung đề tài (trả về Widget thông thường cho ListView)
  Widget _buildTopicsContent() {
    // Đang loading lần đầu
    if (_isInitialLoading) {
      return _buildSkeletonCard(4);
    }

    // Có lỗi và chưa có cache
    if (_errorMessage != null && _cachedTopics == null) {
      return Card(
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
