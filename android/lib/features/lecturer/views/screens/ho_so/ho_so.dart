import 'package:GPMS/features/lecturer/models/giang_vien_profile.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/views/screens/ho_so/LogoutButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/viewmodels/ho_so_viewmodel.dart';

class HoSo extends StatefulWidget {
  const HoSo({super.key});

  @override
  State<HoSo> createState() => _HoSoPageState();
}

class _HoSoPageState extends State<HoSo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HoSoViewModel>().loadForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).size.width * 0.05;
    final vm = context.watch<HoSoViewModel>();
    final data = vm.profile;

    return Scaffold(
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
      ),

      body: Builder(
        builder: (context) {
          if (vm.isLoading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lỗi: ${vm.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => vm.loadForCurrentUser(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (data == null) {
            return const Center(child: Text('Không có dữ liệu hồ sơ.'));
          }

          return _HoSoBody(data: data);
        },
      ),

      // Thanh điều hướng dưới (demo)
    );
  }
}

class _HoSoBody extends StatelessWidget {
  const _HoSoBody({required this.data});
  final GiangVienProfile data;

  String get hoTen {
    final parts = [
      (data.hocHam ?? '').trim(),
      (data.hocVi ?? '').trim(),
      (data.hoTen ?? '').trim(),
    ].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? '—' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                  _ProfileHeader(
                    data: data,

                    onChangeAvatar: () async {
                      final url = await context
                          .read<HoSoViewModel>()
                          .pickAndUploadAvatar(context);
                      if (!context.mounted) return;
                      if (url != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật ảnh đại diện thành công'),
                          ),
                        );
                      }
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, gap, pad, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Thông tin cá nhân'),
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
                                icon: Icons.badge_outlined,
                                label: 'Mã giảng viên',
                                value: _v(data.maGiangVien),
                              ),
                              const Divider(height: 1),
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: 'Họ và tên',
                                value: _v(hoTen),
                              ),
                              const Divider(height: 1),
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _v(data.email),
                              ),
                              const Divider(height: 1),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Số điện thoại',
                                value: _v(data.soDienThoai),
                              ),

                              const Divider(height: 1),
                              _InfoRow(
                                icon: Icons.school_outlined,
                                label: 'Bộ môn',
                                value: _v(data.tenBoMon),
                              ),
                              const Divider(height: 1),
                            ],
                          ),
                        ),

                        // Đăng xuất
                        SizedBox(height: gap * 2),
                        const LogoutButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data, this.onChangeAvatar});

  final GiangVienProfile data;

  final Future<void> Function()? onChangeAvatar;
  String get hoTen {
    final parts = [
      (data.hocHam ?? '').trim(),
      (data.hocVi ?? '').trim(),
      (data.hoTen ?? '').trim(),
    ].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? '—' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final name = hoTen ?? '';
    final initials = _initials(name);
    final avatarUrl = context.watch<HoSoViewModel>().avatarUrl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black26,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onChangeAvatar, // giờ là async ok
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.edit, size: 18, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name.isEmpty ? '—' : name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

/// Một dòng thông tin
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
        constraints: const BoxConstraints(maxWidth: 220),
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: valueStyle,
        ),
      ),
    );
  }
}

String _v(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.characters.take(1).toString();
  return (parts.first.characters.take(1).toString() +
          parts.last.characters.take(1).toString())
      .toUpperCase();
}
