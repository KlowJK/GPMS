import 'package:flutter/material.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicDetailPage extends StatelessWidget {
  final DeTai deTai;
  const TopicDetailPage({super.key, required this.deTai});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(
      url.startsWith('http') ? url : 'http://your-server.com$url',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Chi tiết đề tài',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deTai.deTai, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Học kỳ: ${deTai.hocKy} - Năm học: ${deTai.namHoc}'),
            Text('Đợt bảo vệ: ${deTai.idDotBaoVe}'),
            const Divider(height: 32),

            const Text(
              'Tài liệu đề tài:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.description)),
              title: const Text('Nội dung đề tài'),
              trailing: const Icon(Icons.download),
              onTap: () => _openFile(deTai.duongDan),
            ),

            const SizedBox(height: 16),
            const Text(
              'Đề cương:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: deTai.deCuongCuaDeTai.length,
                itemBuilder: (context, i) {
                  final dc = deTai.deCuongCuaDeTai[i];
                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.description)),
                    title: Text('Phiên bản ${dc.phienBan}'),
                    trailing: const Icon(Icons.download),
                    onTap: () => _openFile(dc.duongDan),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
