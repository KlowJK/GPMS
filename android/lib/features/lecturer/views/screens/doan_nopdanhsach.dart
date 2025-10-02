import 'package:flutter/material.dart';

void main() => runApp(const ProjectApp());

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ án',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const StudentTabsScreen(),
    );
  }
}

/* ============================================================================
 *  MÀN HÌNH CHÍNH: Tab Sinh viên / Duyệt đề tài + BottomNavigationBar
 * ==========================================================================*/
class StudentTabsScreen extends StatefulWidget {
  const StudentTabsScreen({super.key});

  @override
  State<StudentTabsScreen> createState() => _StudentTabsScreenState();
}

class _StudentTabsScreenState extends State<StudentTabsScreen> {
  int bottomIndex = 1;

  // Demo danh sách sinh viên
  final List<StudentItem> _items = List.generate(
    8,
    (i) => StudentItem(
      name: 'Hà Văn Thắng',
      className: '64KTPM4',
      studentId: '22511724${90 + i}',
      topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      cvFile: 'thang_$i.cv',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2F7CD3);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Đồ án'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: primary,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color: Color(0xFF2F7CD3)),
                  insets: EdgeInsets.symmetric(horizontal: 24),
                ),
                tabs: const [
                  Tab(text: 'Sinh viên'),
                  Tab(text: 'Duyệt Đề tài'),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            // ---------------- Tab "Sinh viên"
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Danh sách sinh viên (${_items.length}):',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _GreenPillButton(
                        icon: Icons.upload_file,
                        label: 'Nộp danh sách',
                        onPressed: () => _showSubmitConfirmDialog(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 1000;
                      final isMedium = c.maxWidth >= 700 && c.maxWidth < 1000;
                      final cross = isWide ? 3 : (isMedium ? 2 : 1);

                      if (cross == 1) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _StudentCard(
                            item: _items[i],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TopicDetailScreen(
                                    student: StudentInfo(
                                      name: _items[i].name,
                                      email: 'havanthang@e.tlu.vn',
                                      dob: DateTime(2003, 9, 24),
                                      phone: '0123456789',
                                      gender: 'Nữ',
                                      studentId: _items[i].studentId,
                                      major: 'Kỹ thuật phần mềm',
                                    ),
                                    topicTitle: _items[i].topic,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cross,
                          mainAxisExtent: 110,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _StudentCard(
                          item: _items[i],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TopicDetailScreen(
                                  student: StudentInfo(
                                    name: _items[i].name,
                                    email: 'havanthang@e.tlu.vn',
                                    dob: DateTime(2003, 9, 24),
                                    phone: '0123456789',
                                    gender: 'Nữ',
                                    studentId: _items[i].studentId,
                                    major: 'Kỹ thuật phần mềm',
                                  ),
                                  topicTitle: _items[i].topic,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ---------------- Tab "Duyệt đề tài"
            const TopicsApprovalTab(),
          ],
        ),
      ),
    );
  }
}

/* ============================================================================
 *  WIDGET PHỤ
 * ==========================================================================*/
class _GreenPillButton extends StatelessWidget {
  const _GreenPillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item, required this.onTap});

  final StudentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFDBEAFE),
                child: Icon(Icons.person, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  runSpacing: 2,
                  spacing: 8,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      item.studentId,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.className,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CV: ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            item.cvFile,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Đề tài: ${item.topic}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentItem {
  final String name;
  final String className;
  final String studentId;
  final String topic;
  final String cvFile;

  StudentItem({
    required this.name,
    required this.className,
    required this.studentId,
    required this.topic,
    required this.cvFile,
  });
}

/* ============================================================================
 *  TAB DUYỆT ĐỀ TÀI
 * ==========================================================================*/
enum TopicStatus { pending, approved, rejected }

class TopicApprovalItem {
  final String studentName;
  final String studentId;
  final String title;
  final String overviewFileName;
  final TopicStatus status;
  final String? comment;

  TopicApprovalItem({
    required this.studentName,
    required this.studentId,
    required this.title,
    required this.overviewFileName,
    required this.status,
    this.comment,
  });

  TopicApprovalItem copyWith({
    String? studentName,
    String? studentId,
    String? title,
    String? overviewFileName,
    TopicStatus? status,
    String? comment,
  }) {
    return TopicApprovalItem(
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      overviewFileName: overviewFileName ?? this.overviewFileName,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}

class TopicsApprovalTab extends StatefulWidget {
  const TopicsApprovalTab({super.key});

  @override
  State<TopicsApprovalTab> createState() => _TopicsApprovalTabState();
}

class _TopicsApprovalTabState extends State<TopicsApprovalTab> {
  final List<TopicApprovalItem> items = [
    TopicApprovalItem(
      studentName: 'Hà Văn Thắng',
      studentId: '2251172490',
      title: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      overviewFileName: 'tongquan.docx',
      status: TopicStatus.pending,
    ),
    TopicApprovalItem(
      studentName: 'Nguyễn Văn A',
      studentId: '2251172001',
      title: 'Hệ thống quản lý đề tài',
      overviewFileName: 'overview.pdf',
      status: TopicStatus.rejected,
      comment: 'Đề tài không thiết thực',
    ),
    TopicApprovalItem(
      studentName: 'Trần Thị B',
      studentId: '2251172333',
      title: 'App theo dõi tiến độ',
      overviewFileName: 'summary.pdf',
      status: TopicStatus.approved,
      comment: 'Đề tài thiết thực',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final it = items[i];
        return _TopicCard(
          item: it,
          onApprove: () async {
            final note = await showCommentSheet(context);
            if (note == null) return;
            setState(
              () => items[i] = it.copyWith(
                status: TopicStatus.approved,
                comment: note,
              ),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã duyệt đề tài')));
          },
          onReject: () async {
            final note = await showCommentSheet(context);
            if (note == null || note.trim().isEmpty) return;
            setState(
              () => items[i] = it.copyWith(
                status: TopicStatus.rejected,
                comment: note.trim(),
              ),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã từ chối đề tài')));
          },
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
  });

  final TopicApprovalItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    Color statusColor(TopicStatus s) {
      switch (s) {
        case TopicStatus.pending:
          return const Color(0xFFC9B325);
        case TopicStatus.approved:
          return const Color(0xFF16A34A);
        case TopicStatus.rejected:
          return const Color(0xFFDC2626);
      }
    }

    String statusText(TopicStatus s) {
      switch (s) {
        case TopicStatus.pending:
          return 'Đang chờ duyệt';
        case TopicStatus.approved:
          return 'Đã duyệt';
        case TopicStatus.rejected:
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        item.studentName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        item.studentId,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Đề tài: ${item.title}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Tổng quan đề tài: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Flexible(
                  child: Text(
                    item.overviewFileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Trạng thái: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  statusText(item.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor(item.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if ((item.comment ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Nhận xét: ${item.comment}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            if (item.status == TopicStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626), // đỏ
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8), // xanh dương
                        foregroundColor: Colors.white,
                      ),
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
}

/* ============================================================================
 *  MÀN HÌNH CHI TIẾT ĐỀ TÀI (bấm 1 SV)
 * ==========================================================================*/
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

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.student,
    required this.topicTitle,
  });

  final StudentInfo student;
  final String topicTitle;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late List<SubmissionInfo> submissions = <SubmissionInfo>[
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
      note: 'Nộp tốt',
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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _TopicHeader(title: widget.topicTitle),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _StudentSection(
                  student: widget.student,
                  twoColumns: MediaQuery.of(context).size.width >= 900,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Đề cương:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: submissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _SubmissionCard(
                  info: submissions[i],
                  onApprove: () async {
                    final note = await showCommentSheet(context);
                    if (note == null) return;
                    setState(() {
                      submissions[i] = submissions[i].copyWith(
                        status: SubmissionStatus.approved,
                        note: note,
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã duyệt đề cương')),
                    );
                  },
                  onReject: () async {
                    final note = await showCommentSheet(context);
                    if (note == null || note.trim().isEmpty) return;
                    setState(() {
                      submissions[i] = submissions[i].copyWith(
                        status: SubmissionStatus.rejected,
                        note: note.trim(),
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã từ chối đề cương')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Đồ án'),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

/* ----- Header đề tài ----- */
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

/* ----- Khối thông tin sinh viên ----- */
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
                      Divider(
                        height: 16,
                        color: Theme.of(context).dividerColor,
                      ),
                  ],
                ],
              ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _KV {
  final String key;
  final String value;
  final IconData icon;
  _KV(this.key, this.value, this.icon);
}

/* ----- Thẻ mỗi lần nộp ----- */
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
    Color statusColor(SubmissionStatus s) {
      switch (s) {
        case SubmissionStatus.pending:
          return const Color(0xFFC9B325);
        case SubmissionStatus.approved:
          return const Color(0xFF16A34A);
        case SubmissionStatus.rejected:
          return const Color(0xFFDC2626);
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
            Row(
              children: [
                Text(
                  'Số lần nộp: ${info.attempt}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('Ngày nộp: ${_fmtDate(info.date)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('File: ', style: Theme.of(context).textTheme.bodyMedium),
                Flexible(
                  child: Text(
                    info.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  statusText(info.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor(info.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if ((info.note ?? '').isNotEmpty)
                  Flexible(
                    child: Text(
                      'Ghi chú: ${info.note!}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (info.status == SubmissionStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626), // đỏ
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8), // xanh dương
                        foregroundColor: Colors.white,
                      ),
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/* ============================================================================
 *  HỘP THOẠI NHẬN XÉT (đơn giản như ảnh)
 * ==========================================================================*/
Future<String?> showCommentSheet(BuildContext context) async {
  final controller = TextEditingController();

  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nhận xét',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  minLines: 6,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Đưa ra nhận xét ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7CD3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      final t = controller.text.trim();
                      if (t.isEmpty) return;
                      Navigator.pop(context, t);
                    },
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/* ============================================================================
 *  DIALOG NỘP DANH SÁCH
 * ==========================================================================*/
Future<void> _showSubmitConfirmDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF2F7CD3).withOpacity(0.12),
              child: const Icon(Icons.help_outline, color: Color(0xFF2F7CD3)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bạn có chắc chắn muốn gửi danh sách đề tài hướng dẫn không?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7CD3),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã nộp danh sách')),
                      );
                    },
                    child: const Text('Xác nhận'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
