import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../../../viewmodels/do_an_viewmodel.dart';
import '../../../../models/de_cuong_log.dart';

class DeCuong extends StatelessWidget {
  const DeCuong({super.key, required this.gap, required this.onCreate});
  final double gap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DoAnViewModel(),
      child: Consumer<DoAnViewModel>(
        builder: (context, viewModel, child) {
          Widget body;
          if (viewModel.isLoading && viewModel.deCuongLogs.isEmpty) {
            body = const Center(child: CircularProgressIndicator());
          } else if (viewModel.error != null && viewModel.deCuongLogs.isEmpty) {
            body = Center(child: Text(viewModel.error!));
          } else {
            body = SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
              child: viewModel.deCuongLogs.isEmpty
                  ? _buildEmptyState(context)
                  : _buildLogList(context, viewModel.deCuongLogs),
            );
          }

          return Stack(
            children: [
              body,
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(gap),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 66, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa có đề cương trong hệ thống.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList(BuildContext context, List<DeCuongLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gap, gap, gap, gap / 2),
          child: Text(
            'Danh sách đề cương',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildLogItem(BuildContext context, DeCuongLog log) {
    final textTheme = Theme.of(context).textTheme;
    final fileName = log.deCuongUrl != null ? Uri.parse(log.deCuongUrl!).pathSegments.last : 'N/A';
    String formattedDate = 'N/A';
    if (log.createdAt != null) {
      try {
        final date = DateTime.parse(log.createdAt!);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (_) {}
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: gap / 2, horizontal: gap),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: Colors.lightBlue.shade50.withOpacity(0.5),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              'File: ',
              child: InkWell(
                onTap: () async {
                  if (log.deCuongUrl == null || log.deCuongUrl!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không có URL để mở.')),
                    );
                    return;
                  }

                  final url = log.deCuongUrl!;
                  try {
                    // ignore: deprecated_member_use
                    if (await launcher.canLaunch(url)) {
                      // ignore: deprecated_member_use
                      await launcher.launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không thể mở URL: $url')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xảy ra lỗi: $e')),
                    );
                  }
                },
                child: Text(
                  fileName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _buildInfoRow(context, 'Ngày nộp: ', text: formattedDate),
            _buildInfoRow(context, 'Số lần nộp: ', text: log.phienBan?.toString() ?? 'N/A'),
            ...log.nhanXets
                .asMap()
                .entries
                .where((entry) => entry.value.noiDung != null && entry.value.noiDung!.isNotEmpty)
                .map((entry) {
              return _buildInfoRow(context, 'Lý do từ chối lần ${entry.key + 1}: ',
                  text: entry.value.noiDung);
            }).toList(),
            _buildInfoRow(
              context,
              'Trạng thái: ',
              child: _buildStatusChip(log.trangThai),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, {String? text, Widget? child}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: child ?? Text(text ?? 'N/A', style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'CHO_DUYET':
        color = Colors.orange.shade700;
        text = 'Chờ duyệt';
        break;
      case 'DA_DUYET':
        color = Colors.green.shade700;
        text = 'Đã duyệt';
        break;
      case 'TU_CHOI':
        color = Colors.red.shade700;
        text = 'Từ chối';
        break;
      default:
        color = Colors.grey.shade700;
        text = status ?? 'N/A';
    }
    return Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }
}
