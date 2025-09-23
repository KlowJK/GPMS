import 'package:flutter/material.dart';

void main() => runApp(const FigmaToCodeApp());

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiến độ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const ProgressScreen(),
    );
  }
}

/// -------------------- MÀN TIẾN ĐỘ (RESPONSIVE) --------------------
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final weeks = List.generate(15, (i) => 'Tuần ${i + 1}');
  String selectedWeek = 'Tuần 2';

  @override
  Widget build(BuildContext context) {
    final entries = <StudentProgress>[
      StudentProgress(
        name: 'Hà Văn Thắng',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: SubmitStatus.submitted,
      ),
      StudentProgress(
        name: 'Lê Đức Anh',
        studentId: '2251172490',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: SubmitStatus.missing,
      ),
      StudentProgress(
        name: 'Nguyễn Văn A',
        studentId: '2251172001',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: SubmitStatus.submitted,
      ),
      StudentProgress(
        name: 'Trần Thị B',
        studentId: '2251172333',
        className: '64KTPM4',
        topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
        status: SubmitStatus.missing,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Tiến độ'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Phần thời gian + ghi chú tuần
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _WeekHeader(
                  from: DateTime(2025, 9, 15, 10, 0, 0),
                  to: DateTime(2025, 9, 21, 23, 59, 33),
                  note: 'Thời hạn nộp nhật ký $selectedWeek :',
                ),
              ),
            ),

            // Tiêu đề + Dropdown tuần ở BÊN PHẢI
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Danh sách sinh viên:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    _WeekDropdown(
                      value: selectedWeek,
                      items: weeks,
                      onChanged: (v) => setState(() => selectedWeek = v!),
                    ),
                  ],
                ),
              ),
            ),

            // Danh sách thẻ sinh viên
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: entries.length,
                itemBuilder: (_, i) => _StudentCard(info: entries[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),

      // Thanh điều hướng dưới (placeholder)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Đồ án'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Tiến độ'),
          NavigationDestination(icon: Icon(Icons.summarize_outlined), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

/// -------------------- DROPDOWN TUẦN (list box) --------------------
class _WeekDropdown extends StatelessWidget {
  const _WeekDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Tạo “list box” viền mảnh giống hình
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          onChanged: onChanged,
          items: items
              .map((w) => DropdownMenuItem(
            value: w,
            child: Text(w, style: Theme.of(context).textTheme.bodyMedium),
          ))
              .toList(),
        ),
      ),
    );
  }
}

/// -------------------- HEADER THỜI GIAN --------------------
class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.from,
    required this.to,
    required this.note,
  });

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

/// -------------------- THẺ SINH VIÊN --------------------
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info});
  final StudentProgress info;

  @override
  Widget build(BuildContext context) {
    Color statusColor(SubmitStatus s) {
      switch (s) {
        case SubmitStatus.submitted:
          return const Color(0xFF00C409);
        case SubmitStatus.missing:
          return const Color(0xFFFFDD00);
      }
    }

    String statusText(SubmitStatus s) {
      switch (s) {
        case SubmitStatus.submitted:
          return 'Đã nộp';
        case SubmitStatus.missing:
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
                        info.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info.studentId,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(info.className,
                        style: Theme.of(context).textTheme.bodyMedium),
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
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Đề tài: ${info.topic}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- MODELS --------------------
enum SubmitStatus { submitted, missing }

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
