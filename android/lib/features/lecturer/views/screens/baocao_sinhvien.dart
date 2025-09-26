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

/// Màn hình chính: AppBar + TabBar (Sinh viên / Duyệt đề tài) + BottomNavigationBar.
/// Không dùng Positioned/width/height cố định; mọi thứ responsive theo màn hình.
class ProjectHome extends StatefulWidget {
  const ProjectHome({super.key});

  @override
  State<ProjectHome> createState() => _ProjectHomeState();
}

class _ProjectHomeState extends State<ProjectHome> {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text('Đồ án'),
          backgroundColor: const Color(0xFF2F7CD3),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Sinh viên', icon: Icon(Icons.school)),
              Tab(text: 'Duyệt đề tài', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: SafeArea(
          minimum: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + padding.bottom / 2,
            top: 8,
          ),
          child: const TabBarView(children: [_StudentsTab(), _ApprovalTab()]),
        ),
      ),
    );
  }
}

/// TAB 1: Danh sách sinh viên.
/// - Responsive: mobile dùng List, màn hình rộng dùng Grid.
/// - Nếu chưa có sinh viên: hiện Empty State rõ ràng.
class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  // Demo dữ liệu mẫu (có thể thay bằng fetch API/Provider/Bloc).
  List<Map<String, String>> get _students => [
    {
      'name': 'Nguyễn Văn A',
      'topic': 'Hệ thống quản lý đề tài',
      'status': 'Đang chờ duyệt',
    },
    {
      'name': 'Trần Thị B',
      'topic': 'App theo dõi tiến độ',
      'status': 'Đang thực hiện',
    },
    {
      'name': 'Lê Văn C',
      'topic': 'Web quản lý báo cáo',
      'status': 'Hoàn thành',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final data = _students; // thay bằng dữ liệu thật
    if (data.isEmpty) {
      return _EmptyState(
        icon: Icons.info_outline,
        title: 'Chưa có sinh viên hướng dẫn',
        message:
            'Bạn chưa hướng dẫn sinh viên nào.\nVui lòng duyệt đăng ký đề tài để bắt đầu.',
        actionLabel: 'Duyệt đăng ký',
        onAction: () {
          DefaultTabController.of(context).animateTo(1);
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Chọn số cột dựa theo độ rộng
        final isWide = constraints.maxWidth >= 900;
        final isMedium =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final crossAxisCount = isWide
            ? 3
            : (isMedium ? 2 : 1); // mobile 1 cột, tablet 2, desktop 3

        if (crossAxisCount == 1) {
          // Dạng danh sách cho màn hình hẹp
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = data[index];
              return _StudentCard(item: item);
            },
          );
        } else {
          // Dạng lưới cho màn hình rộng
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _StudentCard(item: item);
            },
          );
        }
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
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showEditStudentModal(context, item);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(radius: 26, child: Icon(Icons.person)),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  runSpacing: 4,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      item['topic'] ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Chip(
                      label: Text(item['status'] ?? ''),
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
                onPressed: () => _showEditStudentModal(context, item),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// TAB 2: Duyệt đề tài (demo danh sách yêu cầu duyệt).
class _ApprovalTab extends StatelessWidget {
  const _ApprovalTab();

  // Demo dữ liệu
  List<Map<String, String>> get _requests => [
    {
      'name': 'Phạm Thị D',
      'proposed': 'AI phân loại tài liệu',
      'note': 'Ưu tiên xét duyệt sớm',
    },
    {
      'name': 'Đỗ Văn E',
      'proposed': 'IoT giám sát nông nghiệp',
      'note': 'Có mentor phụ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final data = _requests; // thay bằng dữ liệu thật
    if (data.isEmpty) {
      return const _EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Không có yêu cầu duyệt',
        message: 'Khi sinh viên gửi đề tài, yêu cầu sẽ hiện ở đây.',
      );
    }

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['name'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Đề tài: ${item['proposed'] ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if ((item['note'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ghi chú: ${item['note']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showApproveModal(context, item),
                        icon: const Icon(Icons.check),
                        label: const Text('Duyệt'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectModal(context, item),
                        icon: const Icon(Icons.close),
                        label: const Text('Từ chối'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Empty state dùng chung.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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
              Icon(
                icon,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal: Sửa thông tin sinh viên (demo form).
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
            Text(
              'Sửa thông tin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Đề tài',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (context, value, _) {
                return DropdownButtonFormField<String>(
                  value: value,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
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
                  onChanged: (v) => status.value = v ?? value,
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
                      // TODO: Lưu dữ liệu (call API / setState / Provider)
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật sinh viên')),
                      );
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

/// Modal: Duyệt đề tài
void _showApproveModal(BuildContext context, Map<String, String> item) {
  final noteController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Duyệt đề tài'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Xác nhận duyệt đề tài cho ${item['name']}?'),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            // TODO: Gọi API duyệt
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã duyệt đề tài')));
          },
          child: const Text('Duyệt'),
        ),
      ],
    ),
  );
}

/// Modal: Từ chối đề tài
void _showRejectModal(BuildContext context, Map<String, String> item) {
  final reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Từ chối đề tài'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Vui lòng nhập lý do từ chối đề tài của ${item['name']}:'),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Lý do',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            // TODO: Gọi API từ chối
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã từ chối đề tài')));
          },
          child: const Text('Gửi'),
        ),
      ],
    ),
  );
}
