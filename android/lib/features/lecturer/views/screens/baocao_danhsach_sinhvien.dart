import 'package:flutter/material.dart';

void main() => runApp(const FigmaToCodeApp());

// App
class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Báo cáo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const ReportScreen(),
    );
  }
}

/// -------------------- MÀN HÌNH BÁO CÁO (RESPONSIVE) --------------------
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <StudentReport>[
      StudentReport(
        name: 'Hà Văn Thắng',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: ReportStatus.submitted,
      ),
      StudentReport(
        name: 'Lê Đức Anh',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: ReportStatus.notSubmitted,
      ),
      StudentReport(
        name: 'Hà Văn Thắng',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: ReportStatus.submitted,
      ),
      StudentReport(
        name: 'Hà Văn Thắng',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: ReportStatus.submitted,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Báo cáo'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Khối thời gian
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _HeaderBlock(
                  from: DateTime(2025, 12, 15, 10, 0, 0),
                  to: DateTime(2025, 12, 17, 23, 59, 33),
                  title: 'Thời hạn nộp báo cáo',
                ),
              ),
            ),

            // Tiêu đề danh sách
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Danh sách sinh viên:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            // Danh sách thẻ
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: items.length,
                itemBuilder: (_, i) => _StudentReportCard(info: items[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),

      // Thanh điều hướng dưới (placeholder)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3, // Báo cáo
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Đồ án'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Tiến độ'),
          NavigationDestination(icon: Icon(Icons.summarize), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

/// -------------------- HEADER THỜI HẠN --------------------
class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.from,
    required this.to,
    required this.title,
  });

  final DateTime from;
  final DateTime to;
  final String title;

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
            const _ThreeBullets(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ngày bắt đầu : ${_fmtDateTime(from)}\n'
                    'Ngày kết thúc : ${_fmtDateTime(to)}\n'
                    '$title :',
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

class _ThreeBullets extends StatelessWidget {
  const _ThreeBullets();

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

/// -------------------- THẺ BÁO CÁO SINH VIÊN --------------------
class _StudentReportCard extends StatelessWidget {
  const _StudentReportCard({required this.info});
  final StudentReport info;

  @override
  Widget build(BuildContext context) {
    Color statusColor(ReportStatus s) {
      switch (s) {
        case ReportStatus.submitted:
          return const Color(0xFF00C409);
        case ReportStatus.notSubmitted:
          return const Color(0xFFFFDD00);
      }
    }

    String statusText(ReportStatus s) {
      switch (s) {
        case ReportStatus.submitted:
          return 'Đã nộp';
        case ReportStatus.notSubmitted:
          return 'Chưa nộp';
      }
    }

    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(info.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(info.studentId,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(info.className, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'Trạng thái: '),
                          TextSpan(
                            text: statusText(info.status),
                            style: TextStyle(
                              color: statusColor(info.status),
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
            const SizedBox(height: 8),
            Text('Đề tài: ${info.topic}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// -------------------- MODELS --------------------
enum ReportStatus { submitted, notSubmitted }

class StudentReport {
  final String name;
  final String studentId;
  final String className;
  final String topic;
  final ReportStatus status;

  StudentReport({
    required this.name,
    required this.studentId,
    required this.className,
    required this.topic,
    required this.status,
  });
}
