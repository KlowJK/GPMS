import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'trangbaocao.dart'; // ReportListPage
import 'doan.dart'; // ProjectApp
import 'traghatky.dart'; // DiaryListPage
import 'tranghoidong.dart'; // CouncilListPage
import 'tranghoso.dart'; // chứa class StudentProfilePage

void main() {
  runApp(const HomeSinhvien());
}

class HomeSinhvien extends StatelessWidget {
  const HomeSinhvien({super.key});

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

      home: const AfterLoginShell(),
    );
  }
}

class AfterLoginShell extends StatefulWidget {
  const AfterLoginShell({super.key});
  @override
  State<AfterLoginShell> createState() => _AfterLoginShellState();
}

class _AfterLoginShellState extends State<AfterLoginShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeTab(),
      const ProjectApp(),
      const ReportListPage(),
      const DiaryListPage(),
      const CouncilListPage(),
      const StudentProfilePage(),
    ];

    return Scaffold(
      body: pages[_index],
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
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
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
    );
  }
}
