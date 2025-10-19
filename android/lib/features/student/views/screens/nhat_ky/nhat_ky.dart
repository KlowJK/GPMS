import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:GPMS/features/student/viewmodels/nhat_ky_viewmodel.dart';
import 'package:GPMS/features/student/models/nhat_ki_tuan.dart';
import 'package:GPMS/features/student/models/danh_sach_nhat_ky.dart';
import 'package:GPMS/features/student/models/nop_nhat_ki.dart';
import 'package:GPMS/features/student/views/screens/nhat_ky/nop_nhat_ky.dart';

class NhatKy extends StatefulWidget {
  const NhatKy({super.key});

  @override
  State<NhatKy> createState() => _NhatKyState();
}

class _NhatKyState extends State<NhatKy> {
  final List<DiaryEntry> _items = [];

  // New helper: open submit page with optional defaultWeek
  Future<void> _openSubmitPage({
    int? defaultWeek,
    int? deTaiId,
    int? idNhatKy,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
  }) async {
    final week = defaultWeek ?? (_items.isEmpty ? 1 : (_items.first.week + 1));
    final result = await Navigator.of(context).push<DiaryEntry?>(
      MaterialPageRoute(
        builder: (_) => SubmitDiaryPage(
          defaultWeek: week,
          deTaiId: deTaiId,
          idNhatKy: idNhatKy,
          ngayBatDau: ngayBatDau,
          ngayKetThuc: ngayKetThuc,
        ),
      ),
    );
    if (!mounted) return;
    // If this page was opened for an existing server diary (deTaiId or idNhatKy provided),
    // refresh server data regardless of whether the page returned a DiaryEntry (we pop null for server-backed submits).
    if (deTaiId != null || idNhatKy != null) {
      final vm = context.read<NhatKyViewModel>();
      await vm.fetchTuans(includeAll: false);
      await vm.fetchDiaries(includeAll: false);
      // Remove any local placeholder that has the same week to avoid duplicate entries
      setState(() {
        _items.removeWhere((it) => it.week == week);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã nộp nhật ký thành công')),
      );
      return;
    }

    // For local submissions (page opened without deTaiId/idNhatKy), insert the returned DiaryEntry if present
    if (result != null) {
      setState(() => _items.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã nộp nhật ký thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return ChangeNotifierProvider<NhatKyViewModel>(
      // gọi cả 2 API khi tạo ViewModel
      create: (_) => NhatKyViewModel()
        ..fetchTuans(includeAll: false)
        ..fetchDiaries(includeAll: false),
      child: Consumer<NhatKyViewModel>(
        builder: (context, vm, _) {
          if (vm.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (vm.error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(vm.error!)));
                vm.clearError();
              }
            });
          }

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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                        ),
                        Text(
                          'THUY LOI UNIVERSITY',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: const Icon(Icons.person, size: 18),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
                    children: [
                      // If the server indicates the student has no topic, show only a single friendly message and hide other lists
                      if (vm.noDeTai) ...[
                        const SizedBox(height: 12),
                        const _EmptyState(
                          icon: Icons.edit_note,
                          title: 'Bạn chưa có đề tài',
                          subtitle: 'Vui lòng đăng ký đề tài',
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        if (!vm.noDeTai)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(gap),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  if (vm.loading)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  else if (vm.tuans.isEmpty)
                                    const Text('Chưa có tuần nào từ server.')
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: vm.tuans.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (_, i) {
                                        final TuanItem t = vm.tuans[i];
                                        String fmt(DateTime? d) {
                                          if (d == null) return '-';
                                          String two(int v) =>
                                              v.toString().padLeft(2, '0');
                                          return '${two(d.day)}/${two(d.month)}/${d.year}';
                                        }

                                        final range =
                                            '${fmt(t.ngayBatDau)} – ${fmt(t.ngayKetThuc)}';
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          title: Text('Tuần ${t.tuan}'),
                                          subtitle: Text(range),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Show empty state only when both local items and server diaries are empty
                        if (_items.isEmpty && vm.diaries.isEmpty)
                          const _EmptyState(
                            icon: Icons.edit_note,
                            title: 'Bạn chưa có nhật ký trong hệ thống.',
                            subtitle: 'Nhấn nút “+” để nộp nhật ký tuần.',
                          )
                        else
                        // local diary list (if any)
                        if (_items.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _DiaryCard(
                              item: _items[i],
                              onSubmit: () =>
                                  _openSubmitPage(defaultWeek: _items[i].week),
                            ),
                          ),

                        // Hiển thị danh sách nhật ký từ backend
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(gap),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nhật ký ',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                if (vm.loadingDiaries)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else if (vm.diaries.isEmpty)
                                  const Text('Chưa có nhật ký từ server.')
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: vm.diaries.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
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
                        ),
                      ], // <- added closing bracket for the `else ...[` spread
                    ],
                  ),
                ),
              ),
            ),
            // floatingActionButton removed per user request
          );
        },
      ),
    );
  }
}

/* ================== DIARY CARD + SUBMIT PAGE + HELPERS ================== */

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.item, this.onSubmit});
  final DiaryEntry item;
  final VoidCallback? onSubmit;

  (Color bg, Color fg, String label) get _badge {
    switch (item.status) {
      case DiaryStatus.approved:
        return (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          'GVHD đã xác nhận',
        );
      case DiaryStatus.rejected:
        return (const Color(0xFFFEE2E2), const Color(0xFF991B1B), 'Từ chối');
      default:
        return (const Color(0xFFFFF7ED), const Color(0xFF9A3412), 'Chờ duyệt');
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
            // Nút nộp nhật ký cho từng mục (ẩn khi đã được duyệt/đã nộp)
            if (item.status != DiaryStatus.approved)
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

/* ================== DIARY ITEM CARD ================== */

// New widget to render DiaryItem from backend
class _DiaryItemCard extends StatelessWidget {
  const _DiaryItemCard({required this.item, this.onSubmit});
  final DiaryItem item;
  final VoidCallback? onSubmit;

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  // Map server status text to colored badge (yellow = chưa nộp, green = đã nộp)
  _Badge _statusBadge(String? raw) {
    final s = (raw ?? '').toLowerCase();
    if (s.contains('chưa') ||
        s.contains('chua') ||
        s.contains('chua nop') ||
        s.contains('chua nộp')) {
      return const _Badge(
        text: 'Chưa nộp',
        bg: Color(0xFFFFF4D6),
        fg: Color(0xFF7A4B00),
      );
    }
    if (s.contains('đã') ||
        s.contains('da') ||
        s.contains('đã nộp') ||
        s.contains('da nop') ||
        s.contains('nop')) {
      return const _Badge(
        text: 'Đã nộp',
        bg: Color(0xFFDFF7E7),
        fg: Color(0xFF10603A),
      );
    }
    // fallback: show original text in neutral badge
    return _Badge(
      text: raw ?? '-',
      bg: const Color(0xFFF1F5F9),
      fg: Colors.black54,
    );
  }

  // Render file meta as a shortened clickable link
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
          SizedBox(
            width: 110,
            child: const Text('File', style: TextStyle(color: Colors.black54)),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không thể mở tệp')),
                  );
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

  // Determine if the server-provided status string indicates the diary is already submitted
  bool _isSubmittedStatus() {
    final s = (item.trangThaiNhatKy ?? '').toLowerCase();
    if (s.contains('chưa') || s.contains('chua')) return false;
    // treat any form of 'đã', 'da', or 'nộp' as submitted
    if (s.contains('đã') ||
        s.contains('da') ||
        s.contains('nộp') ||
        s.contains('nop'))
      return true;
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
                // show a colored badge for status
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
            // Hide submit button when backend status indicates already submitted
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
