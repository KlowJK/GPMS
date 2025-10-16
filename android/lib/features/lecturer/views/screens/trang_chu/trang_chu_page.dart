import 'package:flutter/material.dart';

import '../../widgets/search_field.dart';
import '../../widgets/news_tile.dart';
import '../../widgets/card_list.dart';
import '../../widgets/chip_pill.dart';
import '../../widgets/section_header.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/notice_tile.dart';

class TrangChuPage extends StatelessWidget {
  const TrangChuPage({super.key});

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
                  actionText: 'Xem tất cả',
                  onAction: () {},
                  horizontalPadding: pad,
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
                  actionText: 'Xem tất cả',
                  onAction: () {},
                  horizontalPadding: pad,
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

                // ===== Tin tức =====
                SectionHeader(
                  title: 'Tin tức',
                  actionText: 'Xem tất cả',
                  onAction: () {},
                  horizontalPadding: pad,
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

                // ===== Thư viện đề tài =====
                SectionHeader(
                  title: 'Thư viện đề tài',
                  actionText: 'Xem tất cả đề tài',
                  onAction: () {
                    // TODO: điều hướng danh sách đề tài
                  },
                  horizontalPadding: pad,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SearchField(hintText: 'Tìm kiếm đề tài...'),
                        SizedBox(height: gap),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            ChipPill(label: 'Đợt 2', selected: true),
                            ChipPill(label: '2023'),
                            ChipPill(label: 'AI'),
                            ChipPill(label: 'Mobile'),
                            ChipPill(label: 'Web'),
                          ],
                        ),
                        SizedBox(height: gap * 2),
                      ],
                    ),
                  ),
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
