import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/models/student_supervised.dart';
import 'package:GPMS/features/lecturer/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/screens/bao_cao/report_detail_screen.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

class BaoCaoSinhVienTab extends StatefulWidget {
  const BaoCaoSinhVienTab({super.key});

  @override
  State<BaoCaoSinhVienTab> createState() => _BaoCaoSinhVienTabState();
}

class _BaoCaoSinhVienTabState extends State<BaoCaoSinhVienTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(BaoCaoViewModel vm) async {
    try {
      await vm.fetchSupervisedStudents();
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

    return Consumer<BaoCaoViewModel>(
      builder: (context, vm, _) {
        return RefreshIndicator(
          onRefresh: () => _handleRefresh(vm),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Search box
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Tìm kiếm sinh viên...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      ),
                    ),
                  ),
                ),

                // Title with count
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Danh sách sinh viên (${_getFilteredStudents(vm).length}):',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Body
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildBody(vm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BaoCaoViewModel vm) {
    // Error state
    if (vm.hasStudentsError && vm.supervisedStudents.isEmpty) {
      return SliverToBoxAdapter(
        child: _ErrorView(
          message: vm.studentsError!,
          errorCode: vm.studentsErrorCode,
          onRetry: () => vm.fetchSupervisedStudents(),
        ),
      );
    }

    // Loading state
    if (vm.isLoadingStudents && vm.supervisedStudents.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Filter students
    final filtered = _getFilteredStudents(vm);

    // Empty state
    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyView(
          text: _query.isNotEmpty
              ? 'Không tìm thấy sinh viên phù hợp'
              : 'Không có sinh viên',
        ),
      );
    }

    // List
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        final student = filtered[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _StudentCard(
            student: student,
            onTap: () => _navigateToDetail(context, vm, student),
          ),
        );
      }, childCount: filtered.length),
    );
  }

  List<StudentSupervised> _getFilteredStudents(BaoCaoViewModel vm) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return vm.supervisedStudents;

    return vm.supervisedStudents.where((s) {
      final target = '${s.hoTen ?? ''} ${s.maSV ?? ''}'.toLowerCase();
      return target.contains(q);
    }).toList();
  }

  void _navigateToDetail(
    BuildContext context,
    BaoCaoViewModel vm,
    StudentSupervised student,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: ReportDetailScreen(student: student),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, this.onTap});

  final StudentSupervised student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusKey = student.trangThaiBaoCao;
    String statusLabel;
    Color statusColor;

    switch (statusKey) {
      case 'CHO_DUYET':
        statusLabel = 'Chờ duyệt';
        statusColor = Colors.amber;
        break;
      case 'DA_DUYET':
        statusLabel = 'Đã duyệt';
        statusColor = const Color(0xFF16A34A);
        break;
      case 'TU_CHOI':
        statusLabel = 'Từ chối';
        statusColor = const Color(0xFFDC2626);
        break;
      case 'CHUA_NOP_BAO_CAO':
        statusLabel = 'Chưa nộp';
        statusColor = Colors.grey;
        break;
      default:
        statusLabel = statusKey ?? '-';
        statusColor = Colors.grey;
    }

    return Card(
      color: const Color(0xFFF9FAFB),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFDBEAFE),
          child: Icon(Icons.person),
        ),
        title: Text(
          student.hoTen ?? '-',
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (student.tenLop != null || student.maSV != null)
              Text(
                '${student.tenLop ?? ''} . ${student.maSV ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 2),
            Text(
              'Đề tài: ${student.tenDeTai ?? '-'}',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          statusLabel,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w900),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
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
    );
  }
}
