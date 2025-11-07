import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_detail.dart';
import 'package:GPMS/features/lecturer/models/sinh_vien.dart';
import 'package:GPMS/features/student/viewmodels/hoi_dong_viewmodel.dart';
import 'package:GPMS/core/exception/error_code.dart';

class HoiDongDetailScreen extends StatefulWidget {
  const HoiDongDetailScreen({
    super.key,
    required this.hoiDongId,
    required this.hoiDongName,
  });

  final int hoiDongId;
  final String hoiDongName;

  @override
  State<HoiDongDetailScreen> createState() => _HoiDongDetailScreenState();
}

class _HoiDongDetailScreenState extends State<HoiDongDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HoiDongViewModel>();
      vm.fetchDetail(hoiDongId: widget.hoiDongId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HoiDongViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Chi tiết hội đồng',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.fetchDetail(hoiDongId: widget.hoiDongId),
            child: _buildBody(vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(HoiDongViewModel vm) {
    // Error state
    if (vm.hasDetailError && vm.detail == null) {
      return _ErrorView(
        message: vm.detailError!,
        errorCode: vm.detailErrorCode,
        onRetry: () => vm.retryFetchDetail(widget.hoiDongId),
      );
    }

    // Loading state
    if (vm.isLoadingDetail && vm.detail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty/null state
    if (vm.detail == null) {
      return const _EmptyView(text: 'Không tìm thấy thông tin hội đồng');
    }

    // Content
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CouncilInfoCard(detail: vm.detail!),
        const SizedBox(height: 16),
        _MembersSection(detail: vm.detail!),
        const SizedBox(height: 16),
        _StudentsSection(students: vm.detail!.sinhVienList),
      ],
    );
  }
}

/// Council basic information card
class _CouncilInfoCard extends StatelessWidget {
  const _CouncilInfoCard({required this.detail});

  final HoiDongDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment, color: Color(0xFF2563EB), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    detail.tenHoiDong,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Thời gian bắt đầu',
              value: _formatDate(detail.thoiGianBatDau),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.event,
              label: 'Thời gian kết thúc',
              value: _formatDate(detail.thoiGianKetThuc),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on,
              label: 'Địa điểm',
              value: detail.diaDiem.isEmpty ? '—' : detail.diaDiem,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

/// Council members section (chairman, secretary, reviewers)
class _MembersSection extends StatelessWidget {
  const _MembersSection({required this.detail});

  final HoiDongDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Thành viên hội đồng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _MemberRow(
              role: 'Chủ tịch',
              name: detail.chuTich.isEmpty ? '—' : detail.chuTich,
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            _MemberRow(
              role: 'Thư ký',
              name: detail.thuKy.isEmpty ? '—' : detail.thuKy,
              color: const Color(0xFF2563EB),
            ),
            if (detail.giangVienPhanBien.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Giảng viên phản biện:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              ...detail.giangVienPhanBien.map(
                (name) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MemberRow(
                    role: '•',
                    name: name,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.role,
    required this.name,
    required this.color,
  });

  final String role;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// Students list section
class _StudentsSection extends StatelessWidget {
  const _StudentsSection({required this.students});

  final List<SinhVien> students;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Danh sách sinh viên (${students.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (students.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Chưa có sinh viên nào'),
                ),
              )
            else
              ...students.asMap().entries.map((entry) {
                final index = entry.key;
                final student = entry.value;
                return Column(
                  children: [
                    if (index > 0) const Divider(height: 24),
                    _StudentCard(student: student, index: index + 1),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.index});

  final SinhVien student;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.hoTen.isEmpty ? '—' : student.hoTen,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MSSV: ${student.maSV} • ${student.lop}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Đề tài', value: student.tenDeTai),
              const SizedBox(height: 8),
              _DetailRow(label: 'GVHD', value: student.gvhd),
              const SizedBox(height: 8),
              _DetailRow(label: 'Bộ môn', value: student.boMon),
            ],
          ),
        ),
      ],
    );
  }
}

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    this.errorCode,
    required this.onRetry,
  });

  final String message;
  final ErrorCode? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Lỗi: $message',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }
}
