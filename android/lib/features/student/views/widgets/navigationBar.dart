import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onChanged,
      selectedItemColor: cs.primary,      // màu xanh mục đang chọn
      unselectedItemColor: Colors.black,  // giống ảnh
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: 'Đồ án',
        ),
        BottomNavigationBarItem(
          // túi + tick -> dùng bag thay thế gần giống ảnh
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Báo cáo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note),
          label: 'Nhật ký',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment_outlined),
          activeIcon: Icon(Icons.apartment),
          label: 'Hội đồng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}
