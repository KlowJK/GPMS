import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thông tin chi tiết đề tài',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const TopicDetailScreen(),
    );
  }
}

/// -------------------- MÀN HÌNH CHI TIẾT ĐỀ TÀI (RESPONSIVE) --------------------
class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({super.key});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  // Demo dữ liệu
  final student = StudentInfo(
    name: 'Hà Văn Thắng',
    email: 'havanthang@e.tlu.vn',
    dob: DateTime(2003, 09, 24),
    phone: '0123456789',
    gender: 'Nữ',
    studentId: '2251172362',
    major: 'Kỹ thuật phần mềm',
  );

  final topicTitle = 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp';

  final submissions = <SubmissionInfo>[
    SubmissionInfo(
      attempt: 1,
      date: DateTime(2025, 9, 13),
      fileName: '225117362_DuongVanHung_1.pdf',
      status: SubmissionStatus.pending,
    ),
    SubmissionInfo(
      attempt: 2,
      date: DateTime(2025, 9, 19),
      fileName: '225117362_DuongVanHung_2.pdf',
      status: SubmissionStatus.approved,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Thông tin chi tiết đề tài'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 900; // tablet/desktop
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _TopicHeader(title: topicTitle),
                  ),
                ),

                // Khối thông tin sinh viên: responsive 1 cột (mobile) / 2 cột (rộng)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _StudentSection(student: student, twoColumns: isWide),
                  ),
                ),

                // Danh sách các lần nộp
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: Text('Đề cương:', style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: submissions.length,
                    itemBuilder: (context, i) => _SubmissionCard(
                      info: submissions[i],
                      onApprove: () => _onApprove(i),
                      onReject: () => _onReject(i),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // Bottom Navigation theo UI gốc (placeholder điều hướng)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Đồ án'),
          NavigationDestination(icon: Icon(Icons.timeline_outlined), label: 'Tiến độ'),
          NavigationDestination(icon: Icon(Icons.summarize_outlined), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
        onDestinationSelected: (i) {
          // TODO: Điều hướng thực tế theo app của bạn
        },
      ),
    );
  }

  Future<void> _onApprove(int index) async {
    final note = await _showApproveDialog(context, submissions[index].fileName);
    if (note == null) return;
    setState(() {
      submissions[index] = submissions[index].copyWith(
        status: SubmissionStatus.approved,
        note: note.isEmpty ? null : note,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt đề cương')));
  }

  Future<void> _onReject(int index) async {
    final reason = await _showRejectDialog(context, submissions[index].fileName);
    if (reason == null || reason.trim().isEmpty) return;
    setState(() {
      submissions[index] = submissions[index].copyWith(
        status: SubmissionStatus.rejected,
        note: reason.trim(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối đề cương')));
  }
}

/// -------------------- HEADER ĐỀ TÀI --------------------
class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                'Đề tài: $title',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- KHỐI THÔNG TIN SINH VIÊN --------------------
class _StudentSection extends StatelessWidget {
  const _StudentSection({required this.student, required this.twoColumns});
  final StudentInfo student;
  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tiles = <_KV>[
      _KV('Họ tên', student.name, Icons.person),
      _KV('Email', student.email, Icons.email),
      _KV('Ngày sinh', _fmtDate(student.dob), Icons.cake),
      _KV('Số điện thoại', student.phone, Icons.phone),
      _KV('Giới tính', student.gender, Icons.transgender),
      _KV('Mã sinh viên', student.studentId, Icons.badge),
      _KV('Ngành', student.major, Icons.school),
    ];

    Widget item(_KV kv) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(kv.icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(kv.key, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                kv.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF393938),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: twoColumns
            ? GridView.builder(
          itemCount: tiles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 44,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, i) => item(tiles[i]),
        )
            : Column(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              item(tiles[i]),
              if (i != tiles.length - 1)
                Divider(height: 16, color: Theme.of(context).dividerColor),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _KV {
  final String key;
  final String value;
  final IconData icon;
  _KV(this.key, this.value, this.icon);
}

/// -------------------- CARD MỖI LẦN NỘP --------------------
class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.info,
    required this.onApprove,
    required this.onReject,
  });

  final SubmissionInfo info;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color statusColor(SubmissionStatus s) {
      switch (s) {
        case SubmissionStatus.pending:
          return const Color(0xFFC9B325); // vàng
        case SubmissionStatus.approved:
          return const Color(0xFF16A34A); // xanh
        case SubmissionStatus.rejected:
          return const Color(0xFFDC2626); // đỏ
      }
    }

    String statusText(SubmissionStatus s) {
      switch (s) {
        case SubmissionStatus.pending:
          return 'Đang chờ duyệt';
        case SubmissionStatus.approved:
          return 'Đã duyệt';
        case SubmissionStatus.rejected:
          return 'Từ chối';
      }
    }

    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dòng 1: Số lần nộp + Ngày nộp
            Row(
              children: [
                Text('Số lần nộp: ${info.attempt}',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  'Ngày nộp: ${_fmtDate(info.date)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dòng 2: File
            Row(
              children: [
                Text('File: ', style: Theme.of(context).textTheme.bodyMedium),
                Flexible(
                  child: InkWell(
                    onTap: () {
                      // TODO: mở/tải file
                    },
                    child: Text(
                      info.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dòng 3: Trạng thái + ghi chú
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trạng thái: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  statusText(info.status),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: statusColor(info.status), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (info.note != null && info.note!.isNotEmpty)
                  Flexible(
                    child: Text('Ghi chú: ${info.note!}',
                        textAlign: TextAlign.end,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Nút hành động (ẩn khi đã duyệt/từ chối)
            if (info.status == SubmissionStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Duyệt'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// -------------------- MODELS --------------------
enum SubmissionStatus { pending, approved, rejected }

class SubmissionInfo {
  final int attempt;
  final DateTime date;
  final String fileName;
  final SubmissionStatus status;
  final String? note;

  SubmissionInfo({
    required this.attempt,
    required this.date,
    required this.fileName,
    required this.status,
    this.note,
  });

  SubmissionInfo copyWith({
    int? attempt,
    DateTime? date,
    String? fileName,
    SubmissionStatus? status,
    String? note,
  }) {
    return SubmissionInfo(
      attempt: attempt ?? this.attempt,
      date: date ?? this.date,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}

class StudentInfo {
  final String name;
  final String email;
  final DateTime dob;
  final String phone;
  final String gender;
  final String studentId;
  final String major;

  StudentInfo({
    required this.name,
    required this.email,
    required this.dob,
    required this.phone,
    required this.gender,
    required this.studentId,
    required this.major,
  });
}

/// -------------------- DIALOGS --------------------
Future<String?> _showApproveDialog(BuildContext context, String fileName) async {
  final note = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Duyệt đề cương'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Xác nhận duyệt file:\n$fileName'),
          const SizedBox(height: 12),
          TextField(
            controller: note,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (không bắt buộc)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(context, note.text.trim()), child: const Text('Duyệt')),
      ],
    ),
  );
}

Future<String?> _showRejectDialog(BuildContext context, String fileName) async {
  final reason = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Từ chối đề cương'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nhập lý do từ chối file:\n$fileName'),
          const SizedBox(height: 12),
          TextField(
            controller: reason,
            decoration: const InputDecoration(
              labelText: 'Lý do',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(context, reason.text.trim()), child: const Text('Gửi')),
      ],
    ),
  );
}
