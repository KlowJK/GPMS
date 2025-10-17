import 'package:GPMS/features/lecturer/views/screens/do_an/do_an.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/views/screens/bao_cao/bao_cao.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/tien_do.dart';
import 'package:GPMS/features/lecturer/views/screens/hoi_dong/hoi_dong.dart';
import 'package:GPMS/features/lecturer/views/screens/ho_so/ho_so.dart';
import 'package:GPMS/features/lecturer/views/screens/trang_chu/trang_chu_page.dart';

class TrangChuGiangVien extends StatefulWidget {
  const TrangChuGiangVien({super.key});

  @override
  State<TrangChuGiangVien> createState() => TrangChuGiangVienState();
}

class TrangChuGiangVienState extends State<TrangChuGiangVien> {
  int _Index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const TrangChuPage(), // Trang chủ
      const DoAn(),
      const TienDo(),
      const BaoCao(),
      const HoiDong(),
      const HoSo(),
    ];

    return Scaffold(
      body: pages[_Index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _Index,
        onDestinationSelected: (i) => setState(() => _Index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Đồ án',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline),
            selectedIcon: Icon(Icons.timeline_outlined),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Hội đồng',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
