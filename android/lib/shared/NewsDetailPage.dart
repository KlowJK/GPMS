import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Để mở liên kết PDF
import 'models/thong_bao_va_tin_tuc.dart';

class NewsDetailPage extends StatelessWidget {
  final ThongBaoVaTinTuc notification;

  const NewsDetailPage({super.key, required this.notification});

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Không thể mở liên kết $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yy').format(notification.ngayDang);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết tin tức',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              Text(
                notification.tieuDe,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Ngày đăng (nhỏ bên dưới tiêu đề)
              Text(
                'Ngày đăng: $formattedDate',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Nội dung
              Text(
                notification.noiDung,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Liên kết PDF (chỉ hiển thị nếu không null/rỗng, ẩn đường link)
              if (notification.duongDanFile?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: GestureDetector(
                    onTap: () => _launchURL(notification.duongDanFile!),
                    child: Text(
                      'Xem tài liệu đính kèm',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
