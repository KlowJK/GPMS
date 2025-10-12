import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dữ liệu truyền vào màn chi tiết (6 trường theo yêu cầu)
class ChiTietDeTaiArgs {
  final String maSV;
  final String hoTen;
  final String tenLop;
  final String soDienThoai;
  final String tenDeTai;
  final String cvUrl;

  const ChiTietDeTaiArgs({
    required this.maSV,
    required this.hoTen,
    required this.tenLop,
    required this.soDienThoai,
    required this.tenDeTai,
    required this.cvUrl,
  });
}

/// Màn hình chỉ hiển thị 6 trường ở trên
class ChiTietDeTai extends StatelessWidget {
  const ChiTietDeTai({super.key, required this.data});
  final ChiTietDeTaiArgs data;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2F7CD3);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Thông tin chi tiết đề tài'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Đề tài
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.topic, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Đề tài: ${data.tenDeTai.isEmpty ? "—" : data.tenDeTai}',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'Thông tin sinh viên thực hiện:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Thông tin SV
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(context, 'Họ tên', data.hoTen),
                    _divider(context),
                    _infoRow(context, 'Mã sinh viên', data.maSV),
                    _divider(context),
                    _infoRow(context, 'Lớp', data.tenLop),
                    _divider(context),
                    _infoRow(context, 'Số điện thoại', data.soDienThoai),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // CV
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('CV: ', style: Theme.of(context).textTheme.bodyMedium),
                    Flexible(
                      child: InkWell(
                        onTap: data.cvUrl.isEmpty ? null : () => _openUrl(data.cvUrl),
                        child: Text(
                          data.cvUrl.isEmpty ? '—' : data.cvUrl.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: data.cvUrl.isEmpty ? null : cs.primary,
                            fontWeight: FontWeight.w600,
                            decoration: data.cvUrl.isEmpty ? TextDecoration.none : TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF393938),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 16, color: Theme.of(context).dividerColor);

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
