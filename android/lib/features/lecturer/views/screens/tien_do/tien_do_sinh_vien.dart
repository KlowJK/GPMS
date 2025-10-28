import 'package:GPMS/features/lecturer/models/tuan.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/models/tien_do_sinh_vien.dart';
import 'package:GPMS/features/lecturer/viewmodels/tien_do_viewmodel.dart';
import 'package:GPMS/features/lecturer/services/tien_do_service.dart';
import 'package:GPMS/features/lecturer/views/screens/tien_do/chi_tiet_tien_do.dart';

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => TienDoSinhVienState();
}

class TienDoSinhVienState extends State<SinhVienTab> {
  final List<TienDoSinhVien> students = [];
  final List<Tuan> weeks = [];
  final Set<int> _loadingIndices = {};

  late final TienDoViewModel _vm;
  bool _initialLoad = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _vm = TienDoViewModel(service: TienDoService());
    _vm.addListener(_onVmChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _initialLoad = true);
    try {
      await _vm.loadTuans(includeAll: false);

      Tuan? tuanToUse;
      final selNum = _vm.selectedTuan;
      if (selNum != null) {
        try {
          tuanToUse = _vm.tuans.firstWhere((t) => t.tuan == selNum);
        } catch (_) {
          tuanToUse = null;
        }
      }
      tuanToUse ??= _vm.tuans.isNotEmpty ? _vm.tuans.first : null;

      await _vm.loadAll(tuan: tuanToUse);
    } finally {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  void _onVmChanged() {
    if (!mounted) return;
    setState(() {
      final dedup = <String, TienDoSinhVien>{};
      for (final e in _vm.items) {
        final key = '${e.maSinhVien ?? ''}|${e.idDeTai ?? ''}';
        dedup[key] = e;
      }
      students
        ..clear()
        ..addAll(dedup.values);
    });
  }

  Future<void> _loadVersions({
    bool refresh = false,
    Tuan? tuan,
    String? status,
    bool supervised = false,
  }) async {
    Tuan? resolveTuan(Tuan? param) {
      if (param != null) return param;
      final selNum = _vm.selectedTuan;
      if (selNum != null) {
        try {
          return _vm.tuans.firstWhere((t) => t.tuan == selNum);
        } catch (_) {
          return null;
        }
      }
      return _vm.tuans.isNotEmpty ? _vm.tuans.first : null;
    }

    if (refresh) {
      if (!mounted) return;
      setState(() => _isRefreshing = true); // only set refreshing flag
      try {
        await _vm.loadTuans(includeAll: true);
        final Tuan? tuanToUse = resolveTuan(tuan);

        if (supervised) {
          await _vm.loadMySupervised(status: status ?? _vm.statusFilter);
        } else {
          await _vm.loadAll(tuan: tuanToUse);
        }
      } finally {
        if (mounted) setState(() => _isRefreshing = false);
      }
      return;
    }

    // initial/non-refresh load: use _initialLoad
    if (!mounted) return;
    setState(() => _initialLoad = true);
    try {
      await _vm.loadTuans(includeAll: true);
      final Tuan? tuanToUse = resolveTuan(tuan);
      await _vm.loadAll(tuan: tuanToUse);
    } finally {
      if (mounted) setState(() => _initialLoad = false);
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstTuan = _vm.tuans.isNotEmpty ? _vm.tuans.first : null;
    final DateTime from = firstTuan?.ngayBatDau ?? DateTime.now();
    final DateTime to =
        firstTuan?.ngayKetThuc ?? DateTime.now().add(const Duration(days: 7));
    final String note = firstTuan != null
        ? 'Thời hạn nộp nhật ký Tuần ${firstTuan.tuan} :'
        : 'Thời hạn nộp nhật ký Tuần :';

    // 1) Loader toàn màn khi vào trang lần đầu
    if (_initialLoad && !_isRefreshing) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    // 2) Nội dung bình thường + Pull-to-refresh
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadVersions(refresh: true),
        child: SafeArea(
          child: Stack(
            children: [
              // Dùng AlwaysScrollable để vẫn kéo refresh được khi list trống
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _WeekHeader(from: from, to: to, note: note),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Danh sách sinh viên:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),

                  if (students.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Chưa có dữ liệu')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _StudentCard(
                          info: students[i],
                          isLoading: _loadingIndices.contains(i),
                          onTap: () async {
                            if (_loadingIndices.contains(i)) return;
                            setState(() => _loadingIndices.add(i));
                            try {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProgressDetailScreen(
                                    student: students[i],
                                    tienDoViewModel: _vm,
                                  ),
                                ),
                              );
                              // Nếu muốn auto refresh sau khi quay lại:
                              // await _loadVersions(refresh: true);
                            } finally {
                              if (mounted) {
                                setState(() => _loadingIndices.remove(i));
                              }
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),

              // 3) Overlay loader khi đang kéo để làm mới (refresh)
              if (_isRefreshing)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// dart
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info, this.onTap, this.isLoading = false});
  final TienDoSinhVien info;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Color statusColor(SubmitStatus s) {
      switch (s) {
        case SubmitStatus.DA_NOP:
          return const Color(0xFF00C409); // green
        case SubmitStatus.HOAN_THANH:
          return const Color(0xFF0090FF); // gray (completed)
        case SubmitStatus.CHUA_NOP:
        default:
          return const Color(0xFFFFDD00); // yellow (not submitted)
      }
    }

    String statusText(SubmitStatus s) {
      switch (s) {
        case SubmitStatus.DA_NOP:
          return 'Đã nộp';
        case SubmitStatus.HOAN_THANH:
          return 'Hoàn thành';
        case SubmitStatus.CHUA_NOP:
        default:
          return 'Chưa nộp';
      }
    }

    final name = info.hoTen ?? '';
    final studentId = info.maSinhVien ?? '';
    final className = info.lop ?? '';
    final topic = info.deTai ?? '';
    final status = _toSubmitStatus(info.trangThaiNhatKy);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: const Color(0xF9FAFBFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          className + " - " + studentId,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Đề tài: $topic',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 2),
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: statusText(status),
                                style: TextStyle(
                                  color: statusColor(status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------- WIDGET PHỤ ------------------------------- */

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.from, required this.to, required this.note});
  final DateTime from;
  final DateTime to;
  final String note;

  @override
  Widget build(BuildContext context) {
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

/* --------------------------------- MODELS --------------------------------- */

enum SubmitStatus { DA_NOP, CHUA_NOP, HOAN_THANH }

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

class StudentProgress {
  final String name;
  final String studentId;
  final String className;
  final String topic;
  final SubmitStatus status;

  StudentProgress({
    required this.name,
    required this.studentId,
    required this.className,
    required this.topic,
    required this.status,
  });
}
