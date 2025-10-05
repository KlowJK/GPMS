import 'package:flutter/material.dart';

class DuyetDeTai extends StatefulWidget {
  const DuyetDeTai({super.key});

  @override
  State<DuyetDeTai> createState() => DuyetDeTaiState();
}

class DuyetDeTaiState extends State<DuyetDeTai> {
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
