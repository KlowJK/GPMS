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
      home: const StudentListScreen(),
    );
  }
}

/// -------------------- MÀN HÌNH DANH SÁCH SINH VIÊN --------------------
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Demo dữ liệu (thay bằng API/Provider khi cần)
  final List<StudentItem> _items = List.generate(
    10,
        (i) => StudentItem(
      name: 'Hà Văn Thắng',
      className: '64KTPM4',
      studentId: '2251172490',
      topic: 'Xây dựng ứng dụng quản lý đồ án tốt nghiệp',
      cvFile: 'thang.cv',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Đồ án'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tiêu đề + nút nộp
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách sinh viên (${_items.length}):',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _onSubmitList,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Nộp danh sách'),
                  ),
                ],
              ),
            ),

            // Tabs “Sinh viên / Duyệt đề tài” theo UI gốc (không fixed size)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Sinh viên'), icon: Icon(Icons.people_alt)),
                  ButtonSegment(value: 1, label: Text('Duyệt đề tài'), icon: Icon(Icons.fact_check)),
                ],
                selected: const {0}, // mặc định ở "Sinh viên" cho màn hình này
                onSelectionChanged: (s) {
                  if (s.contains(1)) {
                    // Chuyển sang màn hình duyệt đề tài (nếu có)
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TopicsApprovalScreen(),
                    ));
                  }
                },
              ),
            ),

            const SizedBox(height: 8),

            // Danh sách responsive
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 1000;
                  final isMedium = c.maxWidth >= 700 && c.maxWidth < 1000;
                  final cross = isWide ? 3 : (isMedium ? 2 : 1);

                  if (cross == 1) {
                    // List cho mobile
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _StudentCard(item: _items[i]),
                    );
                  }

                  // Grid cho tablet/desktop
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      mainAxisExtent: 110,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _StudentCard(item: _items[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation tương ứng UI gốc
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Đồ án'),
          NavigationDestination(icon: Icon(Icons.timeline_outlined), label: 'Tiến độ'),
          NavigationDestination(icon: Icon(Icons.summarize_outlined), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
        selectedIndex: 1,
        onDestinationSelected: (i) {
          // TODO: Điều hướng thật sự theo app của bạn
        },
      ),
    );
  }

  void _onSubmitList() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nộp danh sách'),
        content: const Text('Xác nhận nộp danh sách sinh viên hiện tại?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã nộp danh sách')),
              );
              // TODO: gọi API nộp danh sách
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

/// -------------------- CARD SINH VIÊN --------------------
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item});

  final StudentItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(item.studentId, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  const SizedBox(width: 8),
                  Text(item.className, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('CV: ', style: Theme.of(context).textTheme.bodyMedium),
                      InkWell(
                        onTap: () {
                          // TODO: mở/tải file CV
                        },
                        child: Text(
                          item.cvFile,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Đề tài: ${item.topic}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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

/// -------------------- MODEL --------------------
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

  StudentItem copyWith({
    String? name,
    String? className,
    String? studentId,
    String? topic,
    String? cvFile,
  }) {
    return StudentItem(
      name: name ?? this.name,
      className: className ?? this.className,
      studentId: studentId ?? this.studentId,
      topic: topic ?? this.topic,
      cvFile: cvFile ?? this.cvFile,
    );
  }
}

/// -------------------- FORM SỬA SINH VIÊN (bottom sheet) --------------------
void _showEditStudentModal(BuildContext context, StudentItem item) {
  final name = TextEditingController(text: item.name);
  final className = TextEditingController(text: item.className);
  final studentId = TextEditingController(text: item.studentId);
  final topic = TextEditingController(text: item.topic);
  final cv = TextEditingController(text: item.cvFile);

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
        child: SingleChildScrollView(
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
              _field('Họ tên', name),
              const SizedBox(height: 12),
              _field('Lớp', className),
              const SizedBox(height: 12),
              _field('MSSV', studentId),
              const SizedBox(height: 12),
              _field('Đề tài', topic, maxLines: 2),
              const SizedBox(height: 12),
              _field('CV', cv),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // TODO: lưu dữ liệu (API/Provider/Bloc)
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
            ],
          ),
        ),
      );
    },
  );
}

Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

/// -------------------- MÀN HÌNH DUYỆT ĐỀ TÀI (place-holder điều hướng) --------------------
class TopicsApprovalScreen extends StatelessWidget {
  const TopicsApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Duyệt đề tài'),
      ),
      body: const Center(
        child: Text('Màn hình Duyệt đề tài (sẽ gắn code sau)'),
      ),
    );
  }
}
