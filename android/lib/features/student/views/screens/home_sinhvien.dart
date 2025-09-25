
import 'package:flutter/material.dart';

import 'doan.dart';
import 'home_tab.dart';

void main() {
  runApp(const DangKyDeTaiApp());
}

class DangKyDeTaiApp extends StatelessWidget {
  const DangKyDeTaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F7CD3);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đăng ký đề tài',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const HomeSinhvien(),
    );
  }
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
      const HomeTab(), // Trang chủ
      const ProjectApp(), // TODO: thay bằng màn hình thật
      const PlaceholderCenter(title: 'Nhật ký'),
      const PlaceholderCenter(title: 'Hội đồng'),
      const PlaceholderCenter(title: 'Hồ sơ'),
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

class PlaceholderCenter extends StatelessWidget {
  const PlaceholderCenter({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
