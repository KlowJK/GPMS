import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:GPMS/features/student/viewmodels/ho_so_viewmodel.dart';
import 'package:GPMS/features/student/models/student_profile.dart';
import 'package:GPMS/features/student/views/screens/ho_so/LogoutButton.dart';
import 'package:GPMS/features/student/views/widgets/custom_app_bar.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Màn hình Hồ sơ sinh viên
///
/// Refactored để:
/// - Consume ViewModel từ parent provider
/// - Handle errors với ErrorCode
/// - Better state management
class HoSo extends StatefulWidget {
  const HoSo({super.key});

  @override
  State<HoSo> createState() => _HoSoState();
}

class _HoSoState extends State<HoSo> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't call loadProfile() here since it's already called in TrangChuSinhVien
      // Just check if we need to reload
      final vm = context.read<HoSoViewModel>();
      if (!vm.hasProfile && !vm.isLoading) {
        vm.loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<HoSoViewModel>(
      builder: (context, vm, _) {
        return Scaffold(appBar: CustomAppBar(), body: _buildBody(vm));
      },
    );
  }

  Widget _buildBody(HoSoViewModel vm) {
    // Loading state
    if (vm.isLoading && !vm.hasProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (vm.hasError) {
      return _buildErrorView(vm);
    }

    // Empty state
    if (!vm.hasProfile) {
      return const Center(child: Text('Không có dữ liệu hồ sơ.'));
    }

    // Success state
    return RefreshIndicator(
      onRefresh: () => vm.loadProfile(),
      child: _HoSoBody(data: vm.profile!),
    );
  }

  Widget _buildErrorView(HoSoViewModel vm) {
    String message = vm.error!;
    IconData icon = Icons.error_outline;
    VoidCallback? onAction;

    // Handle specific errors
    if (vm.errorCode == ErrorCode.unauthenticated) {
      message = 'Phiên đăng nhập hết hạn';
      icon = Icons.lock_outline;
      onAction = () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      };
    } else if (vm.errorCode == ErrorCode.timeout) {
      message = 'Kết nối hết thời gian chờ';
      icon = Icons.signal_wifi_off;
      onAction = () => vm.retry();
    } else if (vm.errorCode == ErrorCode.sinhVienNotFound) {
      message = 'Không tìm thấy thông tin sinh viên';
      icon = Icons.person_off_outlined;
    } else {
      onAction = () => vm.retry();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Body của màn hình hồ sơ
class _HoSoBody extends StatelessWidget {
  const _HoSoBody({required this.data});
  final StudentProfile data;

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
                  _ProfileHeader(data: data),
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, gap, pad, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Thông tin cá nhân'),
                        _buildInfoCard(context),
                        SizedBox(height: gap * 1.5),
                        const _SectionTitle('Tài liệu'),
                        _CvCard(cvUrl: data.cvUrl),
                        SizedBox(height: gap * 2.5),
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

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Mã sinh viên',
            value: _v(data.maSV),
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Họ và tên',
            value: _v(data.hoTen),
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
            icon: Icons.calendar_month_outlined,
            label: 'Ngày sinh',
            value: _formatDateShort(data.ngaySinh),
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.home_outlined,
            label: 'Địa chỉ',
            value: _v(data.diaChi),
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Ngành',
            value: _v(data.tenNganh),
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.class_outlined,
            label: 'Lớp',
            value: _v(data.tenLop),
          ),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.apartment_outlined,
            label: 'Khoa',
            value: _v(data.tenKhoa),
          ),
        ],
      ),
    );
  }
}

/// Header với avatar và nút upload
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data});
  final StudentProfile data;

  @override
  Widget build(BuildContext context) {
    final name = data.hoTen ?? '';
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
                    onTap: () async {
                      final vm = context.read<HoSoViewModel>();
                      await vm.pickAndUploadAvatar(context);
                    },
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
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              final vm = context.read<HoSoViewModel>();
              await vm.pickAndUploadCV(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: const StadiumBorder(),
            ),
            child: const Text('Tải lên CV'),
          ),
        ],
      ),
    );
  }
}

/// CV card
class _CvCard extends StatelessWidget {
  const _CvCard({this.cvUrl});
  final String? cvUrl;

  Future<void> _open(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launcher.canLaunchUrl(uri);
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Không thể mở URL: $url')));
        }
        return;
      }
      await launcher.launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCV = (cvUrl ?? '').isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: const Text('CV'),
        subtitle: Text(hasCV ? 'Đã tải lên' : 'Chưa có'),
        trailing: hasCV
            ? TextButton(
                onPressed: () => _open(context, cvUrl!),
                child: const Text('Xem CV'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// Section title
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

/// Info row
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

// Utility functions
String _v(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    return parts.first.characters.take(1).toString().toUpperCase();
  }
  return (parts.first.characters.take(1).toString() +
          parts.last.characters.take(1).toString())
      .toUpperCase();
}

String _formatDateShort(String? s) {
  if (s == null || s.trim().isEmpty) return '—';
  final raw = s.trim();

  // Try ISO parse
  try {
    final d = DateTime.parse(raw);
    final yyyy = d.year.toString().padLeft(4, '0');
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/$yyyy';
  } catch (_) {
    // Try splitting common separators
    final parts = raw.split(RegExp(r'[/\-.]'));
    if (parts.length >= 3) {
      var day = parts[0].padLeft(2, '0');
      var month = parts[1].padLeft(2, '0');
      var year = parts[2].trim();

      // Normalize year to 4 digits
      if (year.length == 2) {
        final num = int.tryParse(year);
        if (num != null) {
          year = (2000 + num).toString();
        } else {
          year = year.padLeft(4, '0');
        }
      } else if (year.length > 4) {
        year = year.substring(year.length - 4);
      } else if (year.length == 3) {
        year = year.padLeft(4, '0');
      }

      if (int.tryParse(year) == null) return raw;
      return '$day/$month/$year';
    }
    return raw;
  }
}
