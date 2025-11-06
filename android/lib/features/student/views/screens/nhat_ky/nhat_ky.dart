import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:GPMS/features/student/viewmodels/nhat_ky_viewmodel.dart';
import 'package:GPMS/features/student/models/danh_sach_nhat_ky.dart';
import 'package:GPMS/features/student/models/nop_nhat_ki.dart';
import 'package:GPMS/features/student/views/screens/nhat_ky/nop_nhat_ky.dart';
import 'package:GPMS/features/student/views/widgets/custom_app_bar.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/student/viewmodels/nop_nhat_ky_viewmodel.dart';
import 'package:GPMS/core/exception/custom_exception.dart';

/// Màn hình Nhật ký tiến trình
///
/// Refactored để:
/// - Consume ViewModel từ parent provider (không tạo mới)
/// - Handle errors với ErrorCode
/// - Better state management
class NhatKy extends StatefulWidget {
  const NhatKy({super.key});

  @override
  State<NhatKy> createState() => _NhatKyState();
}

class _NhatKyState extends State<NhatKy> with AutomaticKeepAliveClientMixin {
  final List<DiaryEntry> _localItems = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final vm = context.read<NhatKyViewModel>();
    await Future.wait([
      vm.fetchTuans(includeAll: false),
      vm.fetchDiaries(includeAll: false),
    ]);
  }

  Future<void> _handleRefresh(NhatKyViewModel vm) async {
    try {
      await Future.wait([
        vm.fetchTuans(includeAll: false),
        vm.fetchDiaries(includeAll: false),
      ]);
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
          case ErrorCode.deTaiNotFound:
            message = 'Bạn chưa đăng ký đề tài.';
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

  Future<void> _openSubmitPage({
    int? defaultWeek,
    int? deTaiId,
    int? idNhatKy,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
  }) async {
    final week =
        defaultWeek ?? (_localItems.isEmpty ? 1 : (_localItems.first.week + 1));

    // LẤY VM HIỆN CÓ từ TrangChuSinhVien
    final submitVm = context.read<SubmitDiaryViewModel>();

    final result = await Navigator.of(context).push<DiaryEntry?>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: submitVm, // 👈 truyền đúng instance hiện có
          child: SubmitDiaryPage(
            defaultWeek: week,
            deTaiId: deTaiId,
            idNhatKy: idNhatKy,
            ngayBatDau: ngayBatDau,
            ngayKetThuc: ngayKetThuc,
          ),
        ),
      ),
    );

    if (!mounted) return;

    // Server-backed submission
    if (deTaiId != null || idNhatKy != null) {
      await _fetchData();
      setState(() {
        _localItems.removeWhere((it) => it.week == week);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã nộp nhật ký thành công')),
        );
      }
      return;
    }

    // Local submission
    if (result != null) {
      setState(() => _localItems.insert(0, result));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã nộp nhật ký thành công')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 560
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    return Consumer<NhatKyViewModel>(
      builder: (context, vm, _) {
        // Handle errors
        if (vm.hasError) {
          return Scaffold(appBar: CustomAppBar(), body: _buildErrorView(vm));
        }

        return Scaffold(
          appBar: CustomAppBar(),
          body: RefreshIndicator(
            onRefresh: () => _handleRefresh(vm),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
                    children: [
                      // No topic state
                      if (vm.noDeTai) ...[
                        const SizedBox(height: 12),
                        const _EmptyState(
                          icon: Icons.edit_note,
                          title: 'Bạn chưa có đề tài',
                          subtitle:
                              'Vui lòng đăng ký đề tài để sử dụng tính năng này',
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        // Tuần list
                        _buildTuanCard(context, vm, gap),
                        const SizedBox(height: 12),

                        // Empty state
                        if (_localItems.isEmpty && vm.diaries.isEmpty)
                          const _EmptyState(
                            icon: Icons.edit_note,
                            title: 'Bạn chưa có nhật ký trong hệ thống.',
                            subtitle: 'Nhấn vào mục nhật ký để bắt đầu nộp.',
                          ),

                        // Local items
                        if (_localItems.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _localItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _DiaryCard(
                              item: _localItems[i],
                              onSubmit: () => _openSubmitPage(
                                defaultWeek: _localItems[i].week,
                              ),
                            ),
                          ),

                        // Server diaries
                        _buildDiariesCard(context, vm, gap),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(NhatKyViewModel vm) {
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
      onAction = () => _fetchData();
    } else if (vm.errorCode == ErrorCode.deTaiNotFound) {
      message = 'Bạn chưa đăng ký đề tài';
      icon = Icons.topic_outlined;
    } else {
      onAction = () => _fetchData();
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

  Widget _buildTuanCard(BuildContext context, NhatKyViewModel vm, double gap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách tuần',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (vm.loading && vm.tuans.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (vm.tuans.isEmpty)
              const Text('Chưa có tuần nào từ server.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.tuans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final t = vm.tuans[i];
                  String fmt(DateTime? d) {
                    if (d == null) return '-';
                    return '${d.day.toString().padLeft(2, '0')}/'
                        '${d.month.toString().padLeft(2, '0')}/${d.year}';
                  }

                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Tuần ${t.tuan}'),
                    subtitle: Text(
                      '${fmt(t.ngayBatDau)} – ${fmt(t.ngayKetThuc)}',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiariesCard(
    BuildContext context,
    NhatKyViewModel vm,
    double gap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhật ký',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (vm.loadingDiaries && vm.diaries.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (vm.diaries.isEmpty)
              const Text('Chưa có nhật ký từ server.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.diaries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _DiaryItemCard(
                  item: vm.diaries[i],
                  onSubmit: () => _openSubmitPage(
                    defaultWeek: vm.diaries[i].tuan,
                    deTaiId: vm.diaries[i].idDeTai,
                    idNhatKy: vm.diaries[i].id,
                    ngayBatDau: vm.diaries[i].ngayBatDau,
                    ngayKetThuc: vm.diaries[i].ngayKetThuc,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Rest of the widgets remain the same...
class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.item, this.onSubmit});
  final DiaryEntry item;
  final VoidCallback? onSubmit;

  (Color bg, Color fg, String label) get _badge {
    switch (item.status) {
      case DiaryStatus.HOAN_THANH:
        return (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          'GVHD đã xác nhận',
        );
      case DiaryStatus.CHUA_NOP:
        return (const Color(0xFFFEE2E2), const Color(0xFF991B1B), 'Chưa nộp');
      case DiaryStatus.DA_NOP:
      default:
        return (const Color(0xFFFFF7ED), const Color(0xFF9A3412), 'Đã nộp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _badge;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tuần ${item.week}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _Badge(text: label, bg: bg, fg: fg),
              ],
            ),
            const SizedBox(height: 6),
            _meta('Thời gian', item.timeRange),
            _meta('Nội dung công việc đã thực hiện', item.content),
            if (item.resultFileName != null)
              _meta('Kết quả đạt được', 'File: ${item.resultFileName}'),
            if (item.teacherNote != null)
              _meta('Nhận xét GVHD', item.teacherNote!),
            const SizedBox(height: 8),
            if (item.status == DiaryStatus.CHUA_NOP)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onSubmit,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Nộp nhật ký'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String k, String v) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(k, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

class _DiaryItemCard extends StatelessWidget {
  const _DiaryItemCard({required this.item, this.onSubmit});
  final DiaryItem item;
  final VoidCallback? onSubmit;

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  _Badge _statusBadge(String? raw) {
    final s = (raw ?? '').toLowerCase();
    if (s.contains('chưa') || s.contains('chua')) {
      return const _Badge(
        text: 'Chưa nộp',
        bg: Color(0xFFFFF4D6),
        fg: Color(0xFF7A4B00),
      );
    }
    if (s.contains('đã') || s.contains('da') || s.contains('nộp')) {
      return const _Badge(
        text: 'Đã nộp',
        bg: Color(0xFFDFF7E7),
        fg: Color(0xFF10603A),
      );
    }
    if (s.contains('hoan') || s.contains('thanh') || s.contains('hoan_thanh')) {
      return const _Badge(
        text: 'Đã hoàn thành',
        bg: Color(0xFFDFF7E7),
        fg: Color(0xFF10603A),
      );
    }
    return _Badge(
      text: raw ?? '-',
      bg: const Color(0xFFF1F5F9),
      fg: Colors.black54,
    );
  }

  Widget _fileRow(BuildContext context, String url) {
    final uri = Uri.tryParse(url);
    final short = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : url;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 110,
            child: Text('File', style: TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () async {
                try {
                  await launchUrlString(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể mở tệp')),
                    );
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      short,
                      style: const TextStyle(color: Color(0xFF2563EB)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSubmittedStatus() {
    final s = (item.trangThaiNhatKy ?? '').toLowerCase();
    if (s.contains('chưa') || s.contains('chua')) return false;
    if (s.contains('đã') || s.contains('da') || s.contains('nộp')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tuần ${item.tuan ?? '-'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(item.trangThaiNhatKy),
              ],
            ),
            const SizedBox(height: 6),
            if (item.deTai != null) _meta('Đề tài', item.deTai!),
            if (item.hoTen != null) _meta('Sinh viên', item.hoTen!),
            _meta(
              'Thời gian',
              '${_fmt(item.ngayBatDau)} – ${_fmt(item.ngayKetThuc)}',
            ),
            if (item.noiDung != null) _meta('Nội dung', item.noiDung!),
            if (item.duongDanFile != null)
              _fileRow(context, item.duongDanFile!),
            if (item.nhanXet != null) _meta('Nhận xét', item.nhanXet!),
            const SizedBox(height: 8),
            if (!_isSubmittedStatus())
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onSubmit,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Nộp nhật ký'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String k, String v) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(k, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: cs.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }
}
