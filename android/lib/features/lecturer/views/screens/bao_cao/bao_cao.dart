import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/views/screens/bao_cao/duyet_bao_cao.dart';
import 'package:GPMS/features/lecturer/views/screens/bao_cao/bao_cao_sinh_vien.dart';

class BaoCao extends StatefulWidget {
  const BaoCao({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF2563EB),
          elevation: 1,
          centerTitle: false,
          titleSpacing: 12,
          title: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Text(
                      'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'THUY LOI UNIVERSITY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              tooltip: 'Thông báo',
              icon: const Icon(Icons.notifications_outlined),
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person, size: 18),
              ),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: _TopTabs(),
          ),
        ),

        body: TabBarView(children: const [SinhVienTab(), DuyetBaoCao()]),
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
      color: const Color(0xFFE3E3E8),
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
          Tab(text: 'Duyệt báo cáo'),
        ],
      ),
    );
  }
}
