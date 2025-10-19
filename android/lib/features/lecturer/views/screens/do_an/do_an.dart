import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/views/screens/do_an/sinh_vien/sinh_vien.dart'; // => chứa class SinhVienScreen
import 'package:GPMS/features/lecturer/views/screens/do_an/de_tai/duyet_de_tai.dart';
import 'package:GPMS/features/lecturer/views/screens/do_an/de_cuong/duyet_de_cuong.dart';

class DoAn extends StatelessWidget {
  const DoAn({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false, // ẩn mũi tên back
          title: const Text(
            'Đồ án',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: _TopTabs(),
          ),
        ),

        body: TabBarView(
          children: const [SinhVienTab(), DuyetDeTai(), DuyetDeCuong()],
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F7CD3);

    return Container(
      color: Color(0xFFE3E3E8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        labelColor: blue,
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: blue, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: const [
          Tab(text: 'Sinh viên'),
          Tab(text: 'Duyệt đề tài'),
          Tab(text: 'Duyệt đề cương'),
        ],
      ),
    );
  }
}
