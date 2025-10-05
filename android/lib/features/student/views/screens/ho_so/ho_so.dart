import 'package:flutter/material.dart';

/// ===== Demo model (có thể thay bằng dữ liệu từ backend) =====
class StudentProfile {
  final String name;
  final String faculty;
  final String email;
  final String dob;
  final String phone;
  final String gender;
  final String studentId;
  final String major;
  final String status;
  final String avatarUrl;

  const StudentProfile({
    required this.name,
    required this.faculty,
    required this.email,
    required this.dob,
    required this.phone,
    required this.gender,
    required this.studentId,
    required this.major,
    required this.status,
    required this.avatarUrl,
  });
}

const _demo = StudentProfile(
  name: 'Hà Văn Thắng',
  faculty: 'Khoa Công nghệ thông tin',
  email: 'havanthang@e.tlu.vn',
  dob: '24/09/2003',
  phone: '0123456789',
  gender: 'Nữ',
  studentId: '2251172362',
  major: 'Kĩ thuật phần mềm',
  status: 'Đang học tập',
  avatarUrl:
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=256&q=80',
);

/// ======= PAGE =======
class HoSo extends StatelessWidget {
  const HoSo({super.key, this.data = _demo});
  final StudentProfile data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar có thể bỏ nếu bạn hiển thị header riêng cho Trang chủ
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Hồ sơ'),
      ),

      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final double maxW = w >= 1200
              ? 900
              : w >= 900
              ? 720
              : 560;
          final double pad = w >= 900 ? 24 : 16;
          final double gap = w >= 900 ? 18 : 12;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  children: [
                    // Header xanh + avatar + tên
                    _ProfileHeader(data: data),

                    // Khối "Thông tin cá nhân"
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, gap, pad, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle('Thông tin cá nhân'),
                          Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                _InfoRow(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: data.email,
                                ),
                                const Divider(height: 1),
                                _InfoRow(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'Ngày sinh',
                                  value: data.dob,
                                ),
                                const Divider(height: 1),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Số điện thoại',
                                  value: data.phone,
                                ),
                                const Divider(height: 1),
                                _InfoRow(
                                  icon: Icons.wc_outlined,
                                  label: 'Giới tính',
                                  value: data.gender,
                                ),
                                const Divider(height: 1),
                                _InfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'Mã sinh viên',
                                  value: data.studentId,
                                ),
                                const Divider(height: 1),
                                _InfoRow(
                                  icon: Icons.school_outlined,
                                  label: 'Ngành',
                                  value: data.major,
                                ),
                                const Divider(height: 1),
                                _InfoRow(
                                  icon: Icons.verified_outlined,
                                  label: 'Trạng thái',
                                  value: data.status,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: gap * 1.5),

                          // Cài đặt
                          _SectionTitle('Cài đặt'),
                          Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.history),
                                  title: const Text('Lịch sử thao tác'),
                                  onTap: () {},
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.help_outline),
                                  title: const Text('Trợ giúp'),
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: gap * 2),

                          // Đăng xuất
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFBF2D2D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Đăng xuất',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                          SizedBox(height: gap * 2.5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ======= HEADER =======
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data});
  final StudentProfile data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2F7CD3),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage(data.avatarUrl),
          ),
          const SizedBox(height: 10),
          Text(
            data.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.faculty,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: const StadiumBorder(),
            ),
            onPressed: () {},
            child: const Text('Tải lên CV'),
          ),
        ],
      ),
    );
  }
}

/// ======= TIÊU ĐỀ NHỎ =======
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// ======= DÒNG THÔNG TIN =======
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.black87);
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF393938),
    );

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Icon(icon),
      title: Text(label, style: labelStyle),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: valueStyle,
        ),
      ),
      onTap: () {}, // có thể mở form chỉnh sửa sau này
    );
  }
}
