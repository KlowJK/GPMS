import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';
import 'package:GPMS/features/student/models/de_cuong_log.dart';
import 'package:GPMS/features/student/models/nhan_xet.dart';

class DeCuong extends StatefulWidget {
  const DeCuong({super.key, required this.gap, required this.onCreate});

  final double gap;
  final VoidCallback onCreate;

  @override
  State<DeCuong> createState() => _DeCuongState();
}

class _DeCuongState extends State<DeCuong> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Giữ state khi chuyển tab

  @override
  void initState() {
    super.initState();

    // Tự động load dữ liệu khi mở tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DoAnViewModel>();
      if (vm.deCuongLogs.isEmpty && !vm.isLoadingLogs && vm.logsError == null) {
        vm.fetchDeCuongLogs();
      }
    });
  }

  Future<void> _onRefresh() async {
    final vm = context.read<DoAnViewModel>();
    await vm.fetchDeCuongLogs();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Yêu cầu cho KeepAlive

    return Consumer<DoAnViewModel>(
      builder: (context, viewModel, child) {
        // Xác định nội dung
        Widget body;

        if (viewModel.isLoadingLogs && viewModel.deCuongLogs.isEmpty) {
          body = _buildSkeleton();
        } else if (viewModel.logsError != null) {
          body = _buildErrorView(viewModel);
        } else if (viewModel.deCuongLogs.isEmpty) {
          body = _buildEmptyState();
        } else {
          body = _buildLogList(context, viewModel.deCuongLogs);
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Stack(
              children: [
                body,
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'fab-decuong',
                    onPressed: widget.onCreate,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // === SKELETON LOADING ===
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(widget.gap),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: widget.gap / 2),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 200, color: Colors.grey[300]),
                SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                SizedBox(height: 8),
                Container(height: 14, width: 150, color: Colors.grey[200]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === ERROR VIEW ===
  Widget _buildErrorView(DoAnViewModel vm) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(widget.gap),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              vm.logsError ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  // === EMPTY STATE ===
  Widget _buildEmptyState() {
    return ListView(
      padding: EdgeInsets.all(widget.gap),
      children: [
        const SizedBox(height: 20),
        _EmptyState(
          icon: Icons.assignment,
          title: 'Bạn chưa có đề cương trong hệ thống',
        ),
      ],
    );
  }

  // === LOG LIST ===
  Widget _buildLogList(BuildContext context, List<DeCuongLog> logs) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.gap,
              widget.gap,
              widget.gap,
              widget.gap / 2,
            ),
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
            itemBuilder: (context, index) =>
                _buildLogItem(context, logs[index]),
          ),
        ],
      ),
    );
  }

  // === LOG ITEM (giữ nguyên logic cũ) ===
  Widget _buildLogItem(BuildContext context, DeCuongLog log) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: widget.gap / 2,
        horizontal: widget.gap,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: Colors.lightBlue.shade50.withAlpha((0.5 * 255).round()),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if ((log.tenDeTai ?? '').isNotEmpty)
                  Expanded(
                    child: Text(
                      log.tenDeTai!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                _statusChip(log.trangThai),
              ],
            ),
            const SizedBox(height: 8),

            _buildInfoRow(
              context,
              'Phiên bản: ',
              text: log.phienBan?.toString(),
            ),
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
        color: c.withAlpha((0.12 * 255).round()),
        border: Border.all(color: c.withAlpha((0.5 * 255).round())),
      ),
      child: Text(
        t,
        style: TextStyle(color: c, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(
          uri,
          mode: launcher.LaunchMode.platformDefault,
        );
      } else {
        _showSnackBar(context, 'Không thể mở URL');
      }
    } catch (e) {
      _showSnackBar(context, 'Lỗi: $e');
    }
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _reviewerText(DeCuongLog log, NhanXet nx) {
    final name = nx.nguoiNhanXet ?? '';
    if (_sameName(name, log.hoTenGiangVienHuongDan)) return 'GVHD';
    if (_sameName(name, log.hoTenGiangVienPhanBien)) return 'GVPB';
    if (_sameName(name, log.hoTenTruongBoMon)) return 'TBM';
    return name.isEmpty ? 'Giảng viên' : name;
  }

  bool _sameName(String? a, String? b) =>
      (a ?? '').trim().toLowerCase() == (b ?? '').trim().toLowerCase();
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
        ],
      ),
    );
  }
}
