import 'dart:async';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/services/de_tai_service.dart';

class DuyetDeTai extends StatefulWidget {
  const DuyetDeTai({super.key, this.onChanged});
  /// Gọi để parent (tab Sinh viên) reload sau khi duyệt/từ chối
  final VoidCallback? onChanged;

  @override
  State<DuyetDeTai> createState() => DuyetDeTaiState();
}

class DuyetDeTaiState extends State<DuyetDeTai> {
  final List<TopicApprovalItem> _items = [];
  final _scroll = ScrollController();

  bool _loading = false;
  String? _error;

  /// Phân trang “ảo”: mỗi lần load sẽ gọi 3 trạng thái theo cùng page
  int _page = 0;
  final int _size = 10;
  bool _lastPage = false;

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
      // Gọi 3 trạng thái và gộp
      final results = await Future.wait([
        DeTaiService.fetchPage(trangThai: 'CHO_DUYET', page: _page, size: _size),
        DeTaiService.fetchPage(trangThai: 'DA_DUYET', page: _page, size: _size),
        DeTaiService.fetchPage(trangThai: 'TU_CHOI', page: _page, size: _size),
      ]);

      final merged = <TopicApprovalItem>[];
      var allLast = true;

      for (final data in results) {
        final page = data['result'] as Map<String, dynamic>;
        final content = (page['content'] as List? ?? []);
        final isLast = (page['last'] as bool?) ?? true;
        allLast = allLast && isLast;

        merged.addAll(content.map((e) =>
            TopicApprovalItem.fromDeTaiResponse(Map<String, dynamic>.from(e as Map))));
      }

      // Ưu tiên CHỜ DUYỆT -> ĐÃ DUYỆT -> TỪ CHỐI
      int weight(TopicStatus s) => s == TopicStatus.pending
          ? 0
          : (s == TopicStatus.approved ? 1 : 2);
      merged.sort((a, b) => weight(a.status).compareTo(weight(b.status)));

      setState(() {
        _items.addAll(merged);
        _lastPage = allLast;
        _page++;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveOrReject({
    required int id,
    required bool approve,
    required int index,
  }) async {
    final note = await showCommentSheet(context);
    if (note == null || (!approve && note.trim().isEmpty)) return;

    try {
      final res = await DeTaiService.approveDeTai(
        deTaiId: id,
        approved: approve,
        nhanXet: note.trim(),
      );
      final result = res['result'] as Map<String, dynamic>;
      final updated = TopicApprovalItem.fromDeTaiResponse(result);

      setState(() => _items[index] = updated);

      // Báo cho parent reload tab Sinh viên
      widget.onChanged?.call();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Đã duyệt đề tài' : 'Đã từ chối đề tài')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh tiêu đề phụ + nút refresh
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Danh sách đề tài',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: () => _load(reset: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        Expanded(
          child: _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : RefreshIndicator(
            onRefresh: () => _load(reset: true),
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                return _TopicCard(
                  item: it,
                  onApprove: it.status == TopicStatus.pending
                      ? () => _approveOrReject(
                      id: it.id, approve: true, index: i)
                      : null,
                  onReject: it.status == TopicStatus.pending
                      ? () => _approveOrReject(
                      id: it.id, approve: false, index: i)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

enum TopicStatus { pending, approved, rejected }
TopicStatus mapTrangThai(String s) {
  switch (s) {
    case 'DA_DUYET':
      return TopicStatus.approved;
    case 'TU_CHOI':
      return TopicStatus.rejected;
    case 'CHO_DUYET':
    default:
      return TopicStatus.pending;
  }
}

class TopicApprovalItem {
  final int id;
  final String? studentName; // hiện backend chưa trả -> null
  final String? studentId;
  final String title;
  final String? overviewFileName;
  final TopicStatus status;
  final String? comment;

  TopicApprovalItem({
    required this.id,
    required this.title,
    required this.status,
    this.studentName,
    this.studentId,
    this.overviewFileName,
    this.comment,
  });

  factory TopicApprovalItem.fromDeTaiResponse(Map<String, dynamic> json) {
    return TopicApprovalItem(
      id: (json['id'] as num).toInt(),
      title: (json['tenDeTai'] ?? '') as String,
      status: mapTrangThai((json['trangThai'] ?? 'CHO_DUYET') as String),
      comment: json['nhanXet'] as String?,
      studentId: (json['sinhVienId']?.toString()),
      studentName: null,
      overviewFileName: json['tongQuanFilename'] as String?,
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.item,
    this.onApprove,
    this.onReject,
  });

  final TopicApprovalItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  Color _statusColor(TopicStatus s) {
    switch (s) {
      case TopicStatus.pending:
        return const Color(0xFFC9B325);
      case TopicStatus.approved:
        return const Color(0xFF16A34A);
      case TopicStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }

  String _statusText(TopicStatus s) {
    switch (s) {
      case TopicStatus.pending:
        return 'Đang chờ duyệt';
      case TopicStatus.approved:
        return 'Đã duyệt';
      case TopicStatus.rejected:
        return 'Từ chối';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('Sinh viên', style: Theme.of(context).textTheme.titleMedium),
                      if (item.studentId != null)
                        Text(
                          item.studentId!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Đề tài: ${item.title}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Tổng quan đề tài: ',
                    style: Theme.of(context).textTheme.bodyMedium),
                Flexible(
                  child: Text(
                    item.overviewFileName ?? '—',
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
                Text('Trạng thái: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  _statusText(item.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _statusColor(item.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if ((item.comment ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Nhận xét: ${item.comment}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            if (item.status == TopicStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
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
                        backgroundColor: const Color(0xFF1D4ED8),
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

/// BottomSheet nhập nhận xét (giữ nguyên bản bạn đang dùng)
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
      final bottom = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nhận xét', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Đưa ra nhận xét ...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final t = controller.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(context, t);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    },
  );
}
