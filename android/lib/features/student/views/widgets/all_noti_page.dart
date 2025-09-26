import 'package:flutter/material.dart';
import 'simple_list_scaffol.dart';

class AllNotiPage extends StatelessWidget {
  const AllNotiPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        'Đề cương #P-2025-031 đang chờ duyệt',
        'GVHD: TS. Trần Văn B • 10:30 18/09',
      ),
      ('Đề tài của bạn đã được duyệt', 'Hệ thống • 09:15 17/09'),
      ('Nhật ký tuần 4 quá hạn nộp', 'Hệ thống • 08:00 16/09'),
    ];
    return SimpleListScaffold(
      title: 'Tất cả thông báo',
      items: items,
      icon: Icons.notifications,
    );
  }
}
