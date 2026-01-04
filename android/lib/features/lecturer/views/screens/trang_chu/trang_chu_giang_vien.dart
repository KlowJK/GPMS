import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/views/screens/do_an/do_an.dart';
import 'package:GPMS/features/lecturer/views/screens/bao_cao/bao_cao.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/tien_do.dart';
import 'package:GPMS/features/lecturer/views/screens/hoi_dong/hoi_dong.dart';
import 'package:GPMS/features/lecturer/views/screens/ho_so/ho_so.dart';
import 'package:GPMS/features/lecturer/views/screens/trang_chu/trang_chu_page.dart';

import 'package:GPMS/features/auth/services/auth_service.dart';
import 'package:GPMS/features/lecturer/services/de_tai_service.dart';
import 'package:GPMS/features/lecturer/services/de_cuong_service.dart';
import 'package:GPMS/features/lecturer/services/sinh_vien_service.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';
import 'package:GPMS/features/lecturer/services/tien_do_service.dart';
import 'package:GPMS/features/lecturer/services/ho_so_service.dart';
import 'package:GPMS/features/lecturer/services/hoi_dong_service.dart';

import 'package:GPMS/features/lecturer/viewmodels/de_tai_viewmodel.dart';
import 'package:GPMS/features/lecturer/viewmodels/de_cuong_viewmodel.dart';
import 'package:GPMS/features/lecturer/viewmodels/sinh_vien_viewmodel.dart';
import 'package:GPMS/features/lecturer/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/viewmodels/ho_so_viewmodel.dart';
import 'package:GPMS/features/lecturer/viewmodels/hoi_dong_viewmodel.dart';

class TrangChuGiangVien extends StatefulWidget {
  const TrangChuGiangVien({super.key});

  @override
  State<TrangChuGiangVien> createState() => _TrangChuGiangVienState();
}

class _TrangChuGiangVienState extends State<TrangChuGiangVien> {
  int _index = 0;
  int? _teacherId;

  // Services
  late final DeTaiService _deTaiService;
  late final DeCuongService _deCuongService;
  late final SinhVienService _sinhVienService;
  late final BaoCaoService _baoCaoService;
  late final TienDoService _tienDoService;
  late final HoSoService _hoSoService;
  late final HoiDongService _hoiDongService;

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadTeacherId();
  }

  void _initServices() {
    final getToken = () => AuthService.getToken();
    final baseUrl = AuthService.baseUrl;

    _deTaiService = DeTaiService(baseUrl: baseUrl, tokenProvider: getToken);
    _deCuongService = DeCuongService(baseUrl: baseUrl, tokenProvider: getToken);
    _sinhVienService = SinhVienService(
      baseUrl: baseUrl,
      tokenProvider: getToken,
    );
    _baoCaoService = BaoCaoService(baseUrl: baseUrl, tokenProvider: getToken);
    _tienDoService = TienDoService(baseUrl: baseUrl, tokenProvider: getToken);
    _hoSoService = HoSoService();
    _hoiDongService = HoiDongService(baseUrl: baseUrl, tokenProvider: getToken);
  }

  Future<void> _loadTeacherId() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _teacherId = user?.teacherId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeTaiViewModel(_deTaiService)),
        ChangeNotifierProvider(
          create: (_) => DeCuongViewModel(_deCuongService),
        ),
        ChangeNotifierProvider(
          create: (_) => SinhVienViewModel(_sinhVienService),
        ),
        ChangeNotifierProvider(
          create: (_) => BaoCaoViewModel(service: _baoCaoService),
        ),
        ChangeNotifierProvider(
          create: (_) => TienDoViewModel(service: _tienDoService),
        ),
        ChangeNotifierProvider(create: (_) => HoSoViewModel(_hoSoService)),
        ChangeNotifierProvider(
          create: (_) => HoiDongViewModel(service: _hoiDongService),
        ),
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
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Báo cáo',
            ),
            NavigationDestination(
              icon: Icon(Icons.timeline),
              selectedIcon: Icon(Icons.timeline_outlined),
              label: 'Tiến độ',
            ),
            NavigationDestination(
              icon: Icon(Icons.apartment_rounded),
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
        return const TienDo();
      case 4:
        // HoiDong requires teacherId
        if (_teacherId == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return HoiDongScreen(teacherId: _teacherId!);
      case 5:
        return const HoSo();
      default:
        return const TrangChuPage();
    }
  }
}
