import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ án',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const ProjectHome(),
    );
  }
}

class ProjectHome extends StatefulWidget {
  const ProjectHome({super.key});

  @override
  State<ProjectHome> createState() => _ProjectHomeState();
}

class _ProjectHomeState extends State<ProjectHome> with TickerProviderStateMixin {
  int _bottomIndex = 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F7CD3),
          foregroundColor: Colors.white,
          title: const Text('Đồ án'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.people_alt), text: 'Sinh viên'),
              Tab(icon: Icon(Icons.fact_check), text: 'Duyệt đề tài'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              _StudentsTab(),         // tab danh sách SV (demo)
              _TopicsApprovalTab(),   // tab duyệt đề tài (theo UI bạn gửi)
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _bottomIndex,
          onDestinationSelected: (i) => setState(() => _bottomIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Đồ án',
            ),
            NavigationDestination(
              icon: Icon(Icons.timeline_outlined),
              selectedIcon: Icon(Icons.timeline),
              label: 'Tiến độ',
            ),
            NavigationDestination(
              icon: Icon(Icons.summarize_outlined),
              selectedIcon: Icon(Icons.summarize),
              label: 'Báo cáo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- TAB 1: SINH VIÊN (demo) ----------------
class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  final List<Map<String, String>> _students = const [
    {'name': 'Nguyễn Văn A', 'topic': 'Hệ thống quản lý đề tài', 'status': 'Đang chờ duyệt'},
    {'name': 'Trần Thị B', 'topic': 'App theo dõi tiến độ', 'status': 'Đang thực hiện'},
    {'name': 'Lê Văn C', 'topic': 'Web quản lý báo cáo', 'status': 'Hoàn thành'},
  ];

  @override
  Widget build(BuildContext context) {
    if (_students.isEmpty) {
      return const _EmptyState(
        icon: Icons.info_outline,
        title: 'Chưa có sinh viên hướng dẫn',
        message: 'Vui lòng duyệt đăng ký đề tài để bắt đầu.',
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final medium = c.maxWidth >= 600 && c.maxWidth < 900;
        final cross = wide ? 3 : (medium ? 2 : 1);

        if (cross == 1) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _StudentCard(item: _students[i]),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisExtent: 150,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _students.length,
          itemBuilder: (context, i) => _StudentCard(item: _students[i]),
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item});
  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    item['topic'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(item['status'] ?? ''),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sửa',
              onPressed: () => _showEditStudentModal(context, item),
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- TAB 2: DUYỆT ĐỀ TÀI (theo UI của bạn) ----------------
class _TopicsApprovalTab extends StatefulWidget {
  const _TopicsApprovalTab();

  @override
  State<_TopicsApprovalTab> createState() => _TopicsApprovalTabState();
}

class _TopicsApprovalTabState extends State<_TopicsApprovalTab> {
  // Demo data tương đương 3 thẻ bạn đưa (đang chờ, từ chối, đã duyệt)
  final List<TopicApprovalItem> _items = [
    TopicApprovalItem(
      studentName: 'Hà Văn Thắng',
      studentId: '2251172490',
      title: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      overviewFileName: 'tongquan.word',
      status: TopicStatus.pending,
      comment: '',
    ),
    TopicApprovalItem(
      studentName: 'Hà Văn Thắng',
      studentId: '2251172490',
      title: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      overviewFileName: 'tongquan.word',
      status: TopicStatus.rejected,
      comment: 'Đề tài không thiết thực',
    ),
    TopicApprovalItem(
      studentName: 'Hà Văn Thắng',
      studentId: '2251172490',
      title: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      overviewFileName: 'tongquan.word',
      status: TopicStatus.approved,
      comment: 'Đề tài thiết thực',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const _EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Không có yêu cầu duyệt',
        message: 'Khi sinh viên gửi đề tài, yêu cầu sẽ hiển thị tại đây.',
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 1000;
        final isMedium = c.maxWidth >= 700 && c.maxWidth < 1000;
        final cross = isWide ? 3 : (isMedium ? 2 : 1);

        if (cross == 1) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _TopicCard(
              item: _items[i],
              onApprove: () => _onApprove(i),
              onReject: () => _onReject(i),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisExtent: 180,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _items.length,
          itemBuilder: (context, i) => _TopicCard(
            item: _items[i],
            onApprove: () => _onApprove(i),
            onReject: () => _onReject(i),
          ),
        );
      },
    );
  }

  void _onApprove(int index) async {
    final note = await _showApproveDialog(context, _items[index].studentName);
    if (note == null) return;
    setState(() => _items[index] = _items[index].copyWith(
      status: TopicStatus.approved,
      comment: note.isEmpty ? _items[index].comment : note,
    ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt đề tài')));
  }

  void _onReject(int index) async {
    final reason = await _showRejectDialog(context, _items[index].studentName);
    if (reason == null) return;
    setState(() => _items[index] = _items[index].copyWith(
      status: TopicStatus.rejected,
      comment: reason,
    ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối đề tài')));
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
    final cs = Theme.of(context).colorScheme;

    Color statusColor(TopicStatus s) {
      switch (s) {
        case TopicStatus.pending:
          return const Color(0xFFC9B325); // vàng
        case TopicStatus.rejected:
          return const Color(0xFFDC2626); // đỏ
        case TopicStatus.approved:
          return const Color(0xFF16A34A); // xanh
      }
    }

    String statusText(TopicStatus s) {
      switch (s) {
        case TopicStatus.pending:
          return 'Đang chờ duyệt';
        case TopicStatus.rejected:
          return 'Từ chối';
        case TopicStatus.approved:
          return 'Đã duyệt';
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFE4F6FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + tên + mssv
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Icon(Icons.person, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(item.studentName, style: Theme.of(context).textTheme.titleMedium),
                      Text(item.studentId, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tiêu đề đề tài
            Text(
              'Đề tài: ${item.title}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Tổng quan (file)
            Row(
              children: [
                Text('Tổng quan đề tài: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  item.overviewFileName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Trạng thái
            Row(
              children: [
                Text('Trạng thái: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  statusText(item.status),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: statusColor(item.status), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (item.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Nhận xét: ${item.comment}', style: Theme.of(context).textTheme.bodyMedium),
            ],
            const Spacer(),
            // Nút hành động
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
}

/// ----------------- MODELS & DIALOGS -----------------
enum TopicStatus { pending, approved, rejected }

class TopicApprovalItem {
  final String studentName;
  final String studentId;
  final String title;
  final String overviewFileName;
  final TopicStatus status;
  final String comment;

  TopicApprovalItem({
    required this.studentName,
    required this.studentId,
    required this.title,
    required this.overviewFileName,
    required this.status,
    required this.comment,
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

Future<String?> _showApproveDialog(BuildContext context, String name) async {
  final note = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Duyệt đề tài'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Xác nhận duyệt đề tài cho $name?'),
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

Future<String?> _showRejectDialog(BuildContext context, String name) async {
  final reason = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Từ chối đề tài'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nhập lý do từ chối đề tài của $name:'),
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

/// ----------------- FORM SỬA SINH VIÊN (demo) -----------------
void _showEditStudentModal(BuildContext context, Map<String, String> item) {
  final nameController = TextEditingController(text: item['name']);
  final topicController = TextEditingController(text: item['topic']);
  final status = ValueNotifier<String>(item['status'] ?? 'Đang chờ duyệt');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Text('Sửa thông tin', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Đề tài', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (context, value, _) {
                return DropdownButtonFormField<String>(
                  value: value,
                  decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Đang chờ duyệt', child: Text('Đang chờ duyệt')),
                    DropdownMenuItem(value: 'Đang thực hiện', child: Text('Đang thực hiện')),
                    DropdownMenuItem(value: 'Hoàn thành', child: Text('Hoàn thành')),
                  ],
                  onChanged: (v) => status.value = v ?? value,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy'))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // TODO: Lưu dữ liệu (API/Provider/Bloc)
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật sinh viên')));
                    },
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// ----------------- EMPTY STATE DÙNG CHUNG -----------------
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
