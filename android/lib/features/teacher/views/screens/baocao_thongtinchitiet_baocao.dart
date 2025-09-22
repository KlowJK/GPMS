import 'package:flutter/material.dart';

void main() => runApp(const FigmaToCodeApp());

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chi tiết báo cáo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const ReportDetailScreen(),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Thông tin chi tiết báo cáo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Đề tài: Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Khối thông tin sinh viên
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _InfoRow(label: 'Họ tên', value: 'Hà Văn Thắng'),
                  Divider(),
                  _InfoRow(label: 'Email', value: 'havanthang@e.tlu.vn'),
                  Divider(),
                  _InfoRow(label: 'Ngày sinh', value: '24/09/2003'),
                  Divider(),
                  _InfoRow(label: 'Số điện thoại', value: '0123456789'),
                  Divider(),
                  _InfoRow(label: 'Giới tính', value: 'Nữ'),
                  Divider(),
                  _InfoRow(label: 'Mã sinh viên', value: '2251172362'),
                  Divider(),
                  _InfoRow(label: 'Ngành', value: 'Kỹ thuật phần mềm'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Các phiên bản báo cáo:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Phiên bản 1
          _ReportVersionCard(
            version: 1,
            date: '15/12/2025',
            file: '225117362_DuongVanHung_1.pdf',
          ),
          const SizedBox(height: 12),

          // Phiên bản 2
          _ReportVersionCard(
            version: 2,
            date: '16/12/2025',
            file: '225117362_DuongVanHung_2.pdf',
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Đồ án'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Tiến độ'),
          NavigationDestination(icon: Icon(Icons.summarize), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ReportVersionCard extends StatelessWidget {
  final int version;
  final String date;
  final String file;
  const _ReportVersionCard({
    required this.version,
    required this.date,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản $version:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Ngày nộp: $date'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('File: '),
                Flexible(
                  child: Text(
                    file,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {},
                    child: const Text('Duyệt'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {},
                    child: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
