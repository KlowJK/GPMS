import 'package:flutter/material.dart';
import 'simple_list_scaffol.dart';

class AllNewsPage extends StatelessWidget {
  const AllNewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Công bố lịch bảo vệ đợt 10/2025', 'Khoa CNTT • 10:30 18/09'),
      ('Mở đăng ký đề tài cho sinh viên K64', 'Hệ thống • 09:15 17/09'),
      ('Kế hoạch DATN Kỳ 1 năm học 2025–2026', 'Hệ thống • 08:00 16/09'),
    ];
    return SimpleListScaffold(
      title: 'Tất cả tin tức',
      items: items,
      icon: Icons.campaign,
    );
  }
}
