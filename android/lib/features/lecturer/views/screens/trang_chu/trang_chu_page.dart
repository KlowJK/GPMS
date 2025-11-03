import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/views/widgets/search_field.dart';
import 'package:GPMS/features/lecturer/views/widgets/news_tile.dart';
import 'package:GPMS/features/lecturer/views/widgets/card_list.dart';
import 'package:GPMS/features/lecturer/views/widgets/chip_pill.dart';
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

class TrangChuPage extends StatefulWidget {
  const TrangChuPage({super.key});

  @override
  State<TrangChuPage> createState() => TrangChuState();
}

class TrangChuState extends State<TrangChuPage> {
  late Future<List<ThongBaoVaTinTuc>> _notificationsFuture;
  late Future<List<DeTai>> _deTaiList;
  late DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Khởi tạo lần đầu
    _dateFormat = DateFormat('dd/MM/yy');
  }

  Future<void> _refreshData() async {
    setState(() {
      _notificationsFuture = MainService.listThongBao();
      _deTaiList = MainService.listDeTai();
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Giới hạn bề rộng nội dung để đọc tốt trên tablet/desktop
    final double maxContentWidth = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 600
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2563EB),
        elevation: 1,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              child: Image.asset("assets/images/logo.png"),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Text(
                    'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'THUY LOI UNIVERSITY',
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
            onPressed: () {},
            tooltip: 'Thông báo',
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
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: gap)),
                // ===== Việc tuần này =====
                SectionHeader(
                  title: 'Việc tuần này',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Xem tất cả'),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                  sliver: SliverToBoxAdapter(
                    child: CardList(
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
                  ),
                ),

                // ===== Thông báo =====
                SectionHeader(
                  title: 'Thông báo',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Xem tất cả'),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                  sliver: SliverToBoxAdapter(
                    child: CardList(
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
                  ),
                ),

                SectionHeader(
                  title: 'Tin tức',
                  trailing: FutureBuilder<List<ThongBaoVaTinTuc>>(
                    future: _notificationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                  sliver: SliverToBoxAdapter(
                    child: CardList(
                      children: const [
                        NewsTile(
                          title: 'Công bố lịch bảo vệ đợt 10/2025',
                          subtitle: 'Khoa công nghệ thông tin • 10:30 18/09',
                        ),
                        Divider(height: 1),
                        NewsTile(
                          title: 'Mở đăng ký đề tài cho sinh viên K64',
                          subtitle: 'Hệ thống • 09:15 17/09',
                        ),
                        Divider(height: 1),
                        NewsTile(
                          title: 'Kế hoạch DATN Kỳ 1 năm học 2025-2026',
                          subtitle: 'Hệ thống • 08:00 16/09',
                        ),
                      ],
                    ),
                  ),
                ),

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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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

                // Spacer cuối trang
                SliverToBoxAdapter(child: SizedBox(height: pad)),
              ],
            ),
          ),
        ),
      ),

      // ===== Navigation bar (5 mục là hợp lý trên mobile) =====
    );
  }
}

/* -------------------------- Widgets tái sử dụng -------------------------- */
