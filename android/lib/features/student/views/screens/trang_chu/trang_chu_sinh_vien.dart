import 'package:flutter/material.dart';
import 'package:GPMS/features/student/views/screens/trang_chu/trang_chu_page.dart';
import 'package:GPMS/features/student/views/screens/bao_cao/bao_cao.dart';
import 'package:GPMS/features/student/views/screens/do_an/do_an.dart';
import 'package:GPMS/features/student/views/screens/nhat_ky/nhat_ky.dart';
import 'package:GPMS/features/student/views/screens/hoi_dong/hoi_dong.dart';
import 'package:GPMS/features/student/views/screens/ho_so/ho_so.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/ho_so_viewmodel.dart';
import 'package:GPMS/features/student/services/ho_so_service.dart';
import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/shared/models/thong_bao_va_tin_tuc.dart';
import 'package:GPMS/core/services/main_service.dart';
import 'package:intl/intl.dart';

class TrangChuSinhVien extends StatelessWidget {
  const TrangChuSinhVien({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2563EB);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPMS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFDCDEE4),
      ),

      home: const TrangChuWidget(),
    );
  }
}

class TrangChuWidget extends StatefulWidget {
  const TrangChuWidget({super.key});
  @override
  State<TrangChuWidget> createState() => _AfterLoginShellState();
}

class _AfterLoginShellState extends State<TrangChuWidget> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DoAnViewModel()),
        ChangeNotifierProvider(create: (_) => HoSoViewModel(HoSoService())),
      ],
      child: Scaffold(
        body: _buildPage(_index),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
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
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Báo cáo',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: 'Nhật ký',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Hội đồng',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const TrangChuPage();
      case 1:
        return const DoAn();
      case 2:
        return const BaoCao();
      case 3:
        return const NhatKy();
      case 4:
        return const HoiDong();
      case 5:
        return const HoSo();
      default:
        return const TrangChuPage();
    }
  }
}
