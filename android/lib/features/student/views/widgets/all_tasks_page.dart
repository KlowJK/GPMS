import 'package:flutter/material.dart';
import 'simple_list_scaffol.dart';

class AllTasksPage extends StatelessWidget {
  const AllTasksPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Ghi nhật ký tuần 5', 'Hạn: 20/09, 23:59 • SV'),
      ('Chỉnh sửa đề cương theo góp ý', 'Hạn: 22/09, 23:59 • SV'),
      ('Nộp bản cập nhật tuần 4', 'Hạn: 15/09, 23:59 • SV'),
    ];
    return SimpleListScaffold(
      title: 'Tất cả việc tuần',
      items: items,
      icon: Icons.checklist,
    );
  }
}
