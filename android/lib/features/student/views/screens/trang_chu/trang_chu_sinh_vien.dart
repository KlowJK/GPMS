import 'package:GPMS/features/student/views/screens/do_an/hoan_do_an.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Core
import 'package:GPMS/core/services/token_provider.dart';
import 'package:GPMS/features/student/views/screens/trang_chu/trang_chu_page.dart';
import 'package:GPMS/features/student/views/screens/bao_cao/bao_cao.dart';
import 'package:GPMS/features/student/views/screens/do_an/do_an.dart';
import 'package:GPMS/features/student/views/screens/nhat_ky/nhat_ky.dart';
import 'package:GPMS/features/student/views/screens/hoi_dong/hoi_dong.dart';
import 'package:GPMS/features/student/views/screens/ho_so/ho_so.dart';
// Services
import 'package:GPMS/features/student/services/do_an_service.dart';
import 'package:GPMS/features/student/services/hoi_dong_service.dart';
import 'package:GPMS/features/student/services/bao_cao_service.dart';
import 'package:GPMS/features/student/services/hoan_do_an_service.dart';
import 'package:GPMS/features/student/services/nhat_ky_service.dart';
import 'package:GPMS/features/student/services/ho_so_service.dart';
// ViewModels
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/hoi_dong_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/hoan_do_an_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/ho_so_viewmodel.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/nhat_ky_viewmodel.dart';
import 'package:GPMS/features/student/viewmodels/nop_nhat_ky_viewmodel.dart';

/// Main shell cho sinh viên sau khi đăng nhập
///
/// Refactored để:
/// - Setup proper dependency injection cho tất cả services
/// - Provide ViewModels với services đã inject
/// - Maintain tab state với AutomaticKeepAliveClientMixin
class TrangChuSinhVien extends StatefulWidget {
  const TrangChuSinhVien({super.key});

  @override
  State<TrangChuSinhVien> createState() => _TrangChuSinhVienState();
}

class _TrangChuSinhVienState extends State<TrangChuSinhVien> {
  int _selectedIndex = 0;

  // Shared instances
  late final TokenProvider _tokenProvider;
  late final Dio _dio;

  // Services
  late final DoAnService _doAnService;
  late final HoiDongService _hoiDongService;
  late final BaoCaoService _baoCaoService;
  late final HoanDoAnService _hoanDoAnService;
  late final NhatKyService _nhatKyService;
  late final HoSoService _hoSoService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    // ← THÊM DÒNG NÀY
  }

  /// Initialize all services với proper dependency injection
  void _initializeServices() {
    // Create shared instances
    _tokenProvider = TokenProvider();

    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Create services with dependency injection
    _doAnService = DoAnService(tokenProvider: () => _tokenProvider.getToken());

    _hoiDongService = HoiDongService(
      dio: _dio,
      tokenProvider: () => _tokenProvider.getToken(),
    );

    _baoCaoService = BaoCaoService(
      dio: _dio,
      tokenProvider: () => _tokenProvider.getToken(),
    );

    _hoanDoAnService = HoanDoAnService(
      tokenProvider: () => _tokenProvider.getToken(),
    );

    _nhatKyService = NhatKyService(
      dio: _dio,
      tokenProvider: () => _tokenProvider.getToken(),
    );

    _hoSoService = HoSoService(
      dio: _dio,
      tokenProvider: () => _tokenProvider.getToken(),
    );
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    const useEmulator = true;
    if (useEmulator) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://192.168.1.10:8080';
    }
  }

  @override
  void dispose() {
    // Dispose services to clean up resources
    _doAnService.dispose();
    _hoiDongService.dispose();
    _baoCaoService.dispose();
    _nhatKyService.dispose();
    _hoSoService.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, _) {
        final studentId = authVm.user?.studentId; // ← DÒNG 1

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DoAnViewModel(_doAnService)),

            ChangeNotifierProvider(
              create: (_) => HoiDongViewModel(
                hoiDongService: _hoiDongService,
                doAnService: _doAnService,
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => BaoCaoViewModel(service: _baoCaoService),
            ),

            ChangeNotifierProvider(
              create: (_) => HoanDoAnViewModel(service: _hoanDoAnService),
            ),

            ChangeNotifierProvider(
              create: (_) => NhatKyViewModel(service: _nhatKyService),
            ),

            ChangeNotifierProvider(
              create: (_) => SubmitDiaryViewModel(service: _nhatKyService),
            ),

            // ← HO SO: DÙNG studentId
            ChangeNotifierProvider(
              create: (_) => HoSoViewModel(
                service: _hoSoService,
                currentUserId: studentId, // ← DÒNG 2
              ),
              lazy: false,
            ),
          ],
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: const [
                TrangChuPage(),
                DoAn(),
                BaoCao(),
                NhatKy(),
                HoiDong(),
                HoSo(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
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
      },
    );
  }
}
