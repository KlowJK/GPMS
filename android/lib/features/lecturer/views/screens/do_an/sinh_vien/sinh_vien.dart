import 'package:flutter/material.dart';
import '../../../../services/sinh_vien_service.dart';

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => _SinhVienTabState();
}

class _SinhVienTabState extends State<SinhVienTab>
    with AutomaticKeepAliveClientMixin {
  final List<_StudentItem> _items = [];
  bool _loading = false;
  String? _error;

  int _page = 0;
  final int _size = 10;
  bool _lastPage = false;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(_onScrollBottom);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScrollBottom() {
    if (_loading || _lastPage) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 160) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 0;
        _lastPage = false;
        _items.clear();
      }
    });

    try {
      final data = await SinhVienService.fetchPage(page: _page, size: _size);
      final page = data['result'] as Map<String, dynamic>;
      final content = (page['content'] as List? ?? []);
      final isLast = (page['last'] as bool?) ?? true;

      final mapped = content.map<_StudentItem>((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return _StudentItem(
          name: (m['hoTen'] ?? m['ten'] ?? '—') as String,
          className: (m['tenLop'] ?? m['lop'] ?? '—') as String,
          studentId: (m['maSV'] ?? m['msv'] ?? '') as String,
          topic: (m['tenDeTai'] ?? m['topic'] ?? '—') as String,
          cvFile: (m['cvUrl'] ?? '') as String,
        );
      }).toList();

      setState(() {
        _items.addAll(mapped);
        _lastPage = isLast;
        _page++;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openDetail(_StudentItem it) async {
    // gọi API chi tiết
    try {
      final detail = await SinhVienService.fetchInfo(it.studentId);
      final r = Map<String, dynamic>.from(detail['result'] as Map);
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _TopicDetailScreen(
            student: _StudentInfo(
              name: (r['hoTen'] ?? it.name) as String,
              email: (r['email'] ?? '—') as String,
              phone: (r['soDienThoai'] ?? '—') as String,
              gender: '—',
              studentId: (r['maSV'] ?? it.studentId) as String,
              major: (r['tenNganh'] ?? '—') as String,
              className: (r['tenLop'] ?? it.className) as String,
            ),
            topicTitle: it.topic,
            cvUrl: r['cvUrl'] as String?,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được chi tiết: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Hàng nút: số lượng + Nộp danh sách + Refresh
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Danh sách sinh viên (${_items.length}+):',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã nộp danh sách')),
                  );
                },
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Nộp danh sách'),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: () => _load(reset: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        // Nội dung
        Expanded(
          child: _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : RefreshIndicator(
            onRefresh: () => _load(reset: true),
            child: _items.isEmpty && !_loading
                ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Chưa có sinh viên nào.')),
              ],
            )
                : ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (_loading && i == _items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final it = _items[i];
                return _StudentCard(
                  item: it,
                  onTap: () => _openDetail(it),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// --------- models + UI nhỏ gọn cho tab

class _StudentItem {
  final String name;
  final String className;
  final String studentId;
  final String topic;
  final String cvFile;

  _StudentItem({
    required this.name,
    required this.className,
    required this.studentId,
    required this.topic,
    required this.cvFile,
  });
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.item, required this.onTap});

  final _StudentItem item;
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
                    Text(item.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      item.studentId,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(item.className,
                        style: Theme.of(context).textTheme.bodySmall),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('CV: ',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Flexible(
                          child: Text(
                            item.cvFile.isEmpty ? '—' : item.cvFile,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
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

/// ----------------- màn chi tiết (tận dụng UI cũ)

class _StudentInfo {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String studentId;
  final String major;
  final String className;

  _StudentInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.studentId,
    required this.major,
    required this.className,
  });
}

class _TopicDetailScreen extends StatelessWidget {
  const _TopicDetailScreen({
    required this.student,
    required this.topicTitle,
    this.cvUrl,
  });

  final _StudentInfo student;
  final String topicTitle;
  final String? cvUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        title: const Text('Thông tin chi tiết đề tài'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.topic, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đề tài: $topicTitle',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _kv(context, 'Họ tên', student.name, Icons.person),
                  const Divider(height: 16),
                  _kv(context, 'Email', student.email, Icons.email),
                  const Divider(height: 16),
                  _kv(context, 'SĐT', student.phone, Icons.phone),
                  const Divider(height: 16),
                  _kv(context, 'Mã SV', student.studentId, Icons.badge),
                  const Divider(height: 16),
                  _kv(context, 'Lớp', student.className, Icons.class_),
                  const Divider(height: 16),
                  _kv(context, 'Ngành', student.major, Icons.school),
                  if ((cvUrl ?? '').isNotEmpty) ...[
                    const Divider(height: 16),
                    _kv(context, 'CV', cvUrl!, Icons.description_outlined),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v, IconData i) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(i, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(k, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                v,
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
