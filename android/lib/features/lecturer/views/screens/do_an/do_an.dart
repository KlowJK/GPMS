import 'package:GPMS/features/lecturer/views/screens/do_an/de_tai/duyet_de_tai.dart';
import 'package:flutter/material.dart';
import 'sinh_vien/sinh_vien.dart';

class DoAn extends StatefulWidget {
  const DoAn({super.key});

  @override
  State<DoAn> createState() => DoAnState();
}

class DoAnState extends State<DoAn> {
  int bottomIndex = 1;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2F7CD3);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Đồ án'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: primary,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color: Color(0xFF2F7CD3)),
                  insets: EdgeInsets.symmetric(horizontal: 24),
                ),
                tabs: const [
                  Tab(text: 'Sinh viên'),
                  Tab(text: 'Duyệt Đề tài'),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            // ---------------- Tab "Sinh viên"
            const SinhVienTab(),

            // ---------------- Tab "Duyệt đề tài"
            const DuyetDeTai(),
          ],
        ),
      ),
    );
  }
}
