import 'package:flutter/material.dart';
import 'sinh_vien/sinh_vien.dart';
import 'de_tai/duyet_de_tai.dart';
import 'de_cuong/duyet_de_cuong.dart';

class DoAn extends StatelessWidget {
  const DoAn({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F7CD3);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Đồ án',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),

          // TabBar nền trắng, giống hệt ảnh
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const _TopTabs(),
            ),
          ),
        ),

        body: const TabBarView(
          children: [
            SinhVienTab(),
            DuyetDeTai(),
            DuyetDeCuong(),
          ],
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

    return TabBar(
      labelColor: blue,                           // tab đang chọn: xanh
      unselectedLabelColor: Color(0xFF888888),   // tab chưa chọn: xám
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      indicatorSize: TabBarIndicatorSize.label,  // gạch chân theo đúng độ rộng label
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: blue, width: 2),
        insets: EdgeInsets.symmetric(horizontal: 16), // thụt vào nhẹ như ảnh
      ),
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      tabs: const [
        Tab(text: 'Sinh viên'),
        Tab(text: 'Duyệt Đề tài'),
        Tab(text: 'Duyệt Đề cương'),
      ],
    );
  }
}
