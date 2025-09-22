import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// App tối giản + chủ đề nhẹ
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thông tin Giảng viên',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const ThongTinGiangVienPage(),
    );
  }
}

/// Màn hình “Thông tin giảng viên” viết lại theo layout co giãn
class ThongTinGiangVienPage extends StatelessWidget {
  const ThongTinGiangVienPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).size.width * 0.05; // padding theo màn hình

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Thông tin chi tiết'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
          children: [
            // Header
            _HeaderCard(
              name: 'ThS. Lê Đức Anh',
              department: 'Khoa Công nghệ thông tin',
            ),
            const SizedBox(height: 16),

            // Thông tin cá nhân
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const _InfoCard(rows: [
              _InfoRow(label: 'Email', value: 'leducanh@e.tlu.vn'),
              _InfoRow(label: 'Ngày sinh', value: '24/09/1988'),
              _InfoRow(label: 'Số điện thoại', value: '0345178542'),
              _InfoRow(label: 'Giới tính', value: 'Nam'),
              _InfoRow(label: 'Mã giảng viên', value: 'GV002'),
              _InfoRow(label: 'Bộ môn', value: 'Lập trình nâng cao'),
              _InfoRow(label: 'Trạng thái', value: 'Đang công tác'),
            ]),
            const SizedBox(height: 24),

            // Cài đặt
            const Text(
              'Cài đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Lịch sử thao tác'),
                    onTap: () {
                      // TODO: điều hướng lịch sử thao tác
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Trợ giúp'),
                    onTap: () {
                      // TODO: mở trang trợ giúp
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Đăng xuất
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF2D2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  // TODO: xử lý đăng xuất
                },
              ),
            ),
          ],
        ),
      ),

      // Thanh điều hướng dưới (minh họa)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // ví dụ đang ở "Hồ sơ"
        onDestinationSelected: (i) {
          // TODO: điều hướng các tab
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Đồ án'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Hồ sơ'),
          NavigationDestination(icon: Icon(Icons.summarize_outlined), label: 'Báo cáo'),
        ],
      ),
    );
  }
}

/// Header Card với nền xanh + avatar
class _HeaderCard extends StatelessWidget {
  final String name;
  final String department;

  const _HeaderCard({required this.name, required this.department});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F7CD3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/avatar_placeholder.png'),
            // Nếu chưa có asset, có thể dùng backgroundColor:
            // backgroundColor: Colors.white24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    department,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// Thẻ thông tin dạng nhãn-trị
class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: rows[i],
            ),
            if (i != rows.length - 1) const Divider(height: 1),
          ]
        ],
      ),
    );
  }
}

/// Một dòng thông tin: Label bên trái, Value bên phải
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black87);
    final valueStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF393938));

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
