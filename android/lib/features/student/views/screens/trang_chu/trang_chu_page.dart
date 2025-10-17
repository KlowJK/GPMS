import 'package:flutter/material.dart';
import 'package:GPMS/features/student/views/widgets/task_tile.dart';
import 'package:GPMS/features/student/views/widgets/all_tasks_page.dart';
import 'package:GPMS/features/student/views/widgets/section_header.dart';
import 'package:GPMS/features/student/views/widgets/noti_tile.dart';
import 'package:GPMS/features/student/views/widgets/all_noti_page.dart';
import 'package:GPMS/features/student/views/widgets/news_tile.dart';
import 'package:GPMS/features/student/views/widgets/all_news_page.dart';
import 'package:GPMS/features/student/views/widgets/topic_library_card.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TrangChuPage extends StatelessWidget {
  const TrangChuPage({super.key});

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
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    shape: const StadiumBorder(),
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
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: 0.30, // ~115/384 từ bản Figma → 30%
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
                            statusColor: Color(0xFFFCA5A5), // quá hạn
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

                    // Tin tức
                    SectionHeader(
                      title: 'Tin tức',
                      trailing: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllNewsPage(),
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
                            title: 'Kế hoạch DATN Kỳ 1 năm học 2025–2026',
                            subtitle: 'Hệ thống • 08:00 16/09',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: gap * 1.5),

                    // Thư viện đề tài
                    const SectionHeader(title: 'Thư viện đề tài'),
                    TopicLibraryCard(gap: gap),
                  ],
                ),
              ),
            );
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
          Container(
            width: 55,
            height: 55,
            child: Image.asset("assets/images/logo.png"),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
