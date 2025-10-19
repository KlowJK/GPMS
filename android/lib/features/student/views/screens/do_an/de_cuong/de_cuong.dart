import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/nhan_xet.dart';

class DeCuong extends StatelessWidget {
  const DeCuong({super.key, required this.gap, required this.onCreate});

  final double gap;
  final VoidCallback onCreate;

  String _safeFileName(String? url) {
    if (url == null || url.isEmpty) return 'N/A';
    try {
      final u = Uri.parse(url);

      // a) có path: dùng segment cuối
      if (u.pathSegments.isNotEmpty && u.pathSegments.last.isNotEmpty) {
        return u.pathSegments.last;
      }

      // b) nhiều dịch vụ để ?filename=...
      final q = u.queryParameters['filename'];
      if (q != null && q.isNotEmpty) return q;

      // c) nếu host trông như "ten.xyz" ⇒ coi là tên file
      if ((u.host).contains('.')) return u.host;

      // d) fallback chia chuỗi
      final parts = url.split('/').where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.last.split('?').first;
    } catch (_) {}
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoAnViewModel>(
      builder: (context, viewModel, child) {
        Widget bodyContent;
        if (viewModel.isLoadingLogs && viewModel.deCuongLogs.isEmpty) {
          bodyContent = const Center(child: CircularProgressIndicator());
        } else if (viewModel.deCuongLogs.isEmpty) {
          bodyContent = ListView(
            padding: EdgeInsets.all(gap),
            children: [
              const SizedBox(height: 20),
              _EmptyState(
                icon: Icons.assignment,
                title: 'Bạn chưa có đề cương trong hệ thống',
              ),
            ],
          );
        } else {
          bodyContent = _buildLogList(context, viewModel.deCuongLogs);
        }

        return Stack(
          children: [
            bodyContent,
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: onCreate,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 66, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa có đề cương trong hệ thống.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList(BuildContext context, List<DeCuongLog> logs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 80,
      ), // Padding to avoid FAB overlap
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gap, gap, gap, gap / 2),
            child: Text(
              'Danh sách đề cương',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogItem(context, log);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, DeCuongLog log) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.symmetric(vertical: gap / 2, horizontal: gap),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      // avoid deprecated withOpacity: use withAlpha for same visual effect
      color: Colors.lightBlue.shade50.withAlpha((0.5 * 255).round()),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              runSpacing: 6,
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Đặt đầu và cuối
                  crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa dọc
                  children: [
                    if ((log.tenDeTai ?? '').isNotEmpty)
                      Expanded(
                        // Cho Text chiếm không gian đầu, tránh overflow
                        child: Text(
                          log.tenDeTai!,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    _statusChip(log.trangThai), // Chip ở cuối
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thông tin chung
            _buildInfoRow(
              context,
              'Phiên bản: ',
              text: log.phienBan?.toString(),
            ),

            // File + ngày nộp
            _buildInfoRow(
              context,
              'File: ',
              child: (log.deCuongUrl == null || log.deCuongUrl!.isEmpty)
                  ? Text('N/A', style: textTheme.bodyMedium)
                  : InkWell(
                      onTap: () => _openUrl(context, log.deCuongUrl!),
                      child: Text(
                        "Xem chi tiết",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade700,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
            _buildInfoRow(context, 'Ngày nộp: ', text: _fmtDate(log.createdAt)),
            const SizedBox(height: 8),

            // Danh sách nhận xét (nếu có)
            if (log.nhanXets.isNotEmpty) ...[
              Text(
                'Nhận xét',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...log.nhanXets.map((nx) {
                final who = _reviewerText(log, nx);
                final when = _fmtDate(nx.thoiGian);
                final content = (nx.noiDung ?? '').isEmpty ? '—' : nx.noiDung!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: who,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: ' $content'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label, {
    String? text,
    Widget? child,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: child ?? Text(text ?? 'N/A', style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return 'N/A';
    }
  }

  Widget _statusChip(String? status) {
    Color c;
    String t;
    switch (status) {
      case 'CHO_DUYET':
        c = Colors.orange.shade700;
        t = 'Chờ duyệt';
        break;
      case 'DA_DUYET':
        c = Colors.green.shade700;
        t = 'Đã duyệt';
        break;
      case 'TU_CHOI':
        c = Colors.red.shade700;
        t = 'Từ chối';
        break;
      default:
        c = Colors.grey.shade700;
        t = status ?? 'N/A';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        // replace withOpacity to avoid deprecation
        color: c.withAlpha((0.12 * 255).round()),
        border: Border.all(color: c.withAlpha((0.5 * 255).round())),
      ),
      child: Text(
        t,
        style: TextStyle(color: c, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Mở URL (API mới của url_launcher)
  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launcher.canLaunchUrl(uri);
      if (!ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể mở URL: $url')));
        return;
      }
      await launcher.launchUrl(uri, mode: launcher.LaunchMode.platformDefault);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
    }
  }

  bool _sameName(String? a, String? b) =>
      (a ?? '').trim().toLowerCase() == (b ?? '').trim().toLowerCase();

  String _reviewerLabel(DeCuongLog log, NhanXet nx) {
    final name = nx.nguoiNhanXet ?? '';
    if (_sameName(name, log.hoTenGiangVienHuongDan)) return 'GVHD';
    if (_sameName(name, log.hoTenGiangVienPhanBien)) return 'GVPB';
    if (_sameName(name, log.hoTenTruongBoMon)) return 'TBM';
    return name.isEmpty ? 'Giảng viên' : name; // fallback
  }

  /// Nếu là vai trò (GVHD/GVPB/TBM) thì thêm tên gốc vào sau
  String _reviewerText(DeCuongLog log, NhanXet nx) {
    final label = _reviewerLabel(log, nx);
    if (label == 'GVHD' || label == 'GVPB' || label == 'TBM') {
      final name = (nx.nguoiNhanXet ?? '').trim();
      return name.isEmpty ? label : '$label:';
    }
    return label;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 174, horizontal: 36),
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
        ],
      ),
    );
  }
}
