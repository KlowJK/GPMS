import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/models/tuan.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/chi_tiet_tien_do.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

class TienDoSinhVienTab extends StatefulWidget {
  const TienDoSinhVienTab({super.key});

  @override
  State<TienDoSinhVienTab> createState() => _TienDoSinhVienTabState();
}

class _TienDoSinhVienTabState extends State<TienDoSinhVienTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Use existing ViewModel
      final vm = context.read<TienDoViewModel>();
      _bootstrap(vm);
    });
  }

  Future<void> _bootstrap(TienDoViewModel vm) async {
    // Load tuans first
    await vm.fetchTuans(includeAll: false);

    // Then load data for first tuan
    if (vm.tuans.isNotEmpty) {
      await vm.fetchAllNhatKy(tuan: vm.tuans.first);
    }
  }

  Future<void> _handleRefresh(TienDoViewModel vm) async {
    try {
      await vm.fetchTuans(includeAll: false);
      if (vm.tuans.isNotEmpty) {
        await vm.fetchAllNhatKy(tuan: vm.tuans.first);
      }
    } catch (e) {
      if (!mounted) return;

      String message = 'Không thể làm mới dữ liệu';

      if (e is CustomException) {
        switch (e.errorCode) {
          case ErrorCode.unauthenticated:
            message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
            break;
          case ErrorCode.timeout:
            message = 'Kết nối hết thời gian chờ. Vui lòng thử lại.';
            break;
          default:
            message = e.errorCode.message;
        }
      } else {
        message = 'Lỗi kết nối: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<TienDoViewModel>(
      builder: (context, vm, _) {
        return RefreshIndicator(
          onRefresh: () => _handleRefresh(vm),
          child: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Week header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _WeekHeader(
                      tuan: vm.tuans.isNotEmpty ? vm.tuans.first : null,
                    ),
                  ),
                ),

                // Title with count
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Danh sách sinh viên (${_getUniqueStudents(vm.items).length}):',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Body
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: _buildBody(vm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(TienDoViewModel vm) {
    // Error state
    if (vm.hasError && vm.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _ErrorView(
          message: vm.error!,
          errorCode: vm.errorCode,
          onRetry: () => vm.fetchAllNhatKy(),
        ),
      );
    }

    // Loading state
    if (vm.isLoading && vm.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Get unique students
    final students = _getUniqueStudents(vm.items);

    // Empty state
    if (students.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyView(text: 'Chưa có sinh viên'),
      );
    }

    // List
    return SliverList.separated(
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _StudentCard(
        student: students[i],
        onTap: () => _navigateToDetail(context, vm, students[i]),
      ),
    );
  }

  List<TienDoSinhVien> _getUniqueStudents(List<TienDoSinhVien> items) {
    final seen = <String>{};
    final unique = <TienDoSinhVien>[];

    for (final item in items) {
      final key = '${item.maSinhVien ?? ''}|${item.idDeTai ?? ''}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(item);
      }
    }

    return unique;
  }

  void _navigateToDetail(
    BuildContext context,
    TienDoViewModel vm,
    TienDoSinhVien student,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: ProgressDetailScreen(student: student, tienDoViewModel: vm),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({this.tuan});

  final Tuan? tuan;

  @override
  Widget build(BuildContext context) {
    final from = tuan?.ngayBatDau ?? DateTime.now();
    final to = tuan?.ngayKetThuc ?? DateTime.now().add(const Duration(days: 7));
    final note = tuan != null
        ? 'Thời hạn nộp nhật ký Tuần ${tuan!.tuan}:'
        : 'Thời hạn nộp nhật ký Tuần:';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BulletList(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ngày bắt đầu : ${_fmtDateTime(from)}\n'
                'Ngày kết thúc : ${_fmtDateTime(to)}\n'
                '$note',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList();

  @override
  Widget build(BuildContext context) {
    Widget dot() => Opacity(
      opacity: 0.5,
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1.5, color: const Color(0xFFFFDD00)),
        ),
      ),
    );
    return Column(children: [dot(), dot(), dot()]);
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, this.onTap});

  final TienDoSinhVien student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = _toSubmitStatus(student.trangThaiNhatKy);
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: const Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFDBEAFE),
                child: Icon(Icons.person, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.hoTen ?? '-',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.lop ?? ''} - ${student.maSinhVien ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đề tài: ${student.deTai ?? '-'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SubmitStatus _toSubmitStatus(Object? v) {
    if (v == null) return SubmitStatus.CHUA_NOP;
    if (v is SubmitStatus) return v;
    final s = v.toString();
    final name = s.contains('.') ? s.split('.').last : s;
    switch (name.toUpperCase()) {
      case 'DA_NOP':
      case 'SUBMITTED':
        return SubmitStatus.DA_NOP;
      case 'HOAN_THANH':
      case 'COMPLETED':
        return SubmitStatus.HOAN_THANH;
      case 'CHUA_NOP':
      default:
        return SubmitStatus.CHUA_NOP;
    }
  }

  Color _getStatusColor(SubmitStatus status) {
    switch (status) {
      case SubmitStatus.DA_NOP:
        return const Color(0xFF00C409);
      case SubmitStatus.HOAN_THANH:
        return const Color(0xFF0090FF);
      case SubmitStatus.CHUA_NOP:
      default:
        return const Color(0xFFFFDD00);
    }
  }

  String _getStatusText(SubmitStatus status) {
    switch (status) {
      case SubmitStatus.DA_NOP:
        return 'Đã nộp';
      case SubmitStatus.HOAN_THANH:
        return 'Hoàn thành';
      case SubmitStatus.CHUA_NOP:
      default:
        return 'Chưa nộp';
    }
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
            size: 40,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Lỗi: $message',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

enum SubmitStatus { DA_NOP, CHUA_NOP, HOAN_THANH }
