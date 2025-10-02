import 'package:flutter/material.dart';

class ProjectHome extends StatefulWidget {
  const ProjectHome({super.key});

  @override
  State<ProjectHome> createState() => _ProjectHomeState();
}

class _ProjectHomeState extends State<ProjectHome> {
  int _bottomIndex = 1;

  final List<StudentItem> _students = [];

  final List<TopicApprovalItem> _approvals = [
    TopicApprovalItem(
      studentName: 'Hà Văn Thắng',
      studentId: '2251172490',
      title: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      overviewFileName: 'tongquan.docx',
      status: TopicStatus.pending,
      comment: '',
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
      title: 'Ứng dụng theo dõi tiến độ',
      overviewFileName: 'tongquan.docx',
      status: TopicStatus.approved,
      comment: 'Đề tài thiết thực',
    ),
  ];

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
        body: SafeArea(
          child: TabBarView(
            children: [
              StudentsTab(
                students: _students,
                onEdit: _openEditStudent,
                onGoApprove: () =>
                    DefaultTabController.of(context).animateTo(1),
              ),
              TopicsApprovalTab(
                items: _approvals,
                onApprove: (item) {
                  setState(() {
                    final idx = _approvals.indexOf(item);
                    _approvals[idx] = _approvals[idx].copyWith(
                      status: TopicStatus.approved,
                    );
                    _students.add(
                      StudentItem(
                        name: item.studentName,
                        studentId: item.studentId,
                        topic: item.title,
                        status: 'Đang thực hiện',
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã duyệt: ${item.studentName}')),
                  );
                  DefaultTabController.of(context).animateTo(0);
                },
                onReject: (item, reason) {
                  setState(() {
                    final idx = _approvals.indexOf(item);
                    _approvals[idx] = _approvals[idx].copyWith(
                      status: TopicStatus.rejected,
                      comment: reason,
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã từ chối đề tài')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditStudent(StudentItem s) {
    _showEditStudentModal(
      context,
      s,
      onSaved: (edited) {
        setState(() {
          final i = _students.indexOf(s);
          _students[i] = edited;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật sinh viên')));
      },
    );
  }
}

/* ======================= TAB SINH VIÊN ======================= */

class StudentsTab extends StatelessWidget {
  const StudentsTab({
    super.key,
    required this.students,
    required this.onEdit,
    required this.onGoApprove,
  });

  final List<StudentItem> students;
  final void Function(StudentItem) onEdit;
  final VoidCallback onGoApprove;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      final grey = Colors.black.withOpacity(0.45);
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 44, color: grey),
            const SizedBox(height: 12),
            Text(
              'Bạn chưa hướng dẫn sinh viên nào,',
              style: TextStyle(
                fontSize: 18,
                color: grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'vui lòng duyệt đăng ký đề tài!',
              style: TextStyle(
                fontSize: 18,
                color: grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onGoApprove,
              child: const Text('Duyệt đăng ký'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _StudentCard(item: students[i], onEdit: onEdit),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item, required this.onEdit});
  final StudentItem item;
  final void Function(StudentItem) onEdit;

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
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đề tài: ${item.topic}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(item.status),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sửa',
              onPressed: () => onEdit(item),
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}

/* ======================= TAB DUYỆT ĐỀ TÀI ======================= */

class TopicsApprovalTab extends StatelessWidget {
  const TopicsApprovalTab({
    super.key,
    required this.items,
    required this.onApprove,
    required this.onReject,
  });

  final List<TopicApprovalItem> items;
  final void Function(TopicApprovalItem) onApprove;
  final void Function(TopicApprovalItem, String reason) onReject;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Không có yêu cầu duyệt'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TopicCard(
        item: items[i],
        onApprove: () async {
          final note = await _showApproveDialog(context, items[i].studentName);
          if (note != null) onApprove(items[i]);
        },
        onReject: () async {
          final reason = await _showRejectDialog(context, items[i].studentName);
          if (reason != null && reason.trim().isNotEmpty) {
            onReject(items[i], reason.trim());
          }
        },
      ),
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

  Color _statusColor(TopicStatus s) {
    switch (s) {
      case TopicStatus.pending:
        return const Color(0xFFC9B325);
      case TopicStatus.rejected:
        return const Color(0xFFDC2626);
      case TopicStatus.approved:
        return const Color(0xFF16A34A);
    }
  }

  String _statusText(TopicStatus s) {
    switch (s) {
      case TopicStatus.pending:
        return 'Đang chờ duyệt';
      case TopicStatus.rejected:
        return 'Từ chối';
      case TopicStatus.approved:
        return 'Đã duyệt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
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
                  _statusText(item.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _statusColor(item.status),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            if (item.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Nhận xét: ${item.comment}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: 12),

            // HÀNG NÚT – kích thước giống ảnh (pill, cao ~40)
            if (item.status == TopicStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: _ActionPillButton(
                      label: 'Từ chối',
                      background: const Color(0xFFE53935), // đỏ
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionPillButton(
                      label: 'Duyệt',
                      background: const Color(0xFF2E7D32), // xanh
                      onPressed: onApprove,
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

/* ---------- NÚT PILL DÙNG CHUNG (giống ảnh) ---------- */
class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.label,
    required this.background,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40), // ~đúng chiều cao ảnh
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          minimumSize: const Size(0, 40), // đảm bảo cao 40
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/* ======================= MODELS & DIALOGS ======================= */

class StudentItem {
  final String name;
  final String studentId;
  final String topic;
  final String status;

  StudentItem({
    required this.name,
    required this.studentId,
    required this.topic,
    required this.status,
  });

  StudentItem copyWith({
    String? name,
    String? studentId,
    String? topic,
    String? status,
  }) {
    return StudentItem(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      topic: topic ?? this.topic,
      status: status ?? this.status,
    );
  }
}

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
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, note.text.trim()),
          child: const Text('Duyệt'),
        ),
      ],
    ),
  );
}

Future<String?> _showRejectDialog(BuildContext context, String name) async {
  final reason = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nhận xét'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: reason,
            decoration: const InputDecoration(
              labelText: 'Đưa ra nhận xét...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, reason.text.trim()),
          child: const Text('Gửi'),
        ),
      ],
    ),
  );
}

/* --------- BottomSheet sửa sinh viên --------- */
void _showEditStudentModal(
  BuildContext context,
  StudentItem item, {
  required void Function(StudentItem edited) onSaved,
}) {
  final name = TextEditingController(text: item.name);
  final topic = TextEditingController(text: item.topic);
  final status = ValueNotifier(item.status);

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
            Text(
              'Sửa thông tin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: topic,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Đề tài',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (context, v, _) {
                return DropdownButtonFormField<String>(
                  value: v,
                  items: const [
                    DropdownMenuItem(
                      value: 'Đang chờ duyệt',
                      child: Text('Đang chờ duyệt'),
                    ),
                    DropdownMenuItem(
                      value: 'Đang thực hiện',
                      child: Text('Đang thực hiện'),
                    ),
                    DropdownMenuItem(
                      value: 'Hoàn thành',
                      child: Text('Hoàn thành'),
                    ),
                  ],
                  onChanged: (nv) => status.value = nv ?? v,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      onSaved(
                        item.copyWith(
                          name: name.text.trim(),
                          topic: topic.text.trim(),
                          status: status.value,
                        ),
                      );
                      Navigator.pop(context);
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
