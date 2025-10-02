import 'package:flutter/material.dart';


class ThongTinGiangVienPage extends StatelessWidget {
  const ThongTinGiangVienPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        elevation: 0,
        toolbarHeight: 0, // ẩn tiêu đề AppBar
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
          children: [
            // Header Giảng viên
            const _TeacherHeader(
              name: 'ThS. Lê Đức Anh',
              department: 'Khoa Công nghệ thông tin',
              avatarUrl: 'https://placehold.co/120x120',
            ),
            const SizedBox(height: 24),

            // Thông tin cá nhân
            const Text(
              'Thông tin cá nhân',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            const _InfoCard(
              rows: [
                _InfoRow(label: 'Email', value: 'leducanh@e.tlu.vn'),
                _InfoRow(label: 'Ngày sinh', value: '24/09/1988'),
                _InfoRow(label: 'Số điện thoại', value: '0345178542'),
                _InfoRow(label: 'Giới tính', value: 'Nam'),
                _InfoRow(label: 'Mã giảng viên', value: 'GV002'),
                _InfoRow(label: 'Bộ môn', value: 'Lập trình nâng cao'),
                _InfoRow(label: 'Trạng thái', value: 'Đang công tác'),
              ],
            ),

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

      // Thanh điều hướng dưới (demo)

    );
  }
}

/// Header Giảng viên với nền xanh + avatar + mũi nhọn
class _TeacherHeader extends StatelessWidget {
  final String name;
  final String department;
  final String? avatarUrl;

  const _TeacherHeader({
    required this.name,
    required this.department,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 190,
          width: double.infinity,
          color: const Color(0xFF2F7CD3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,

                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                department,

                style: const TextStyle(color: Colors.white, fontSize: 14),

                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -8,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: 3.14159,
              child: const Icon(
                Icons.arrow_drop_up,
                size: 32,
                color: Color(0xFF2F7CD3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Thẻ thông tin
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

          ],

        ],
      ),
    );
  }
}

/// Một dòng thông tin
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {

    final labelStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.black87);

    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF393938),
    );

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
