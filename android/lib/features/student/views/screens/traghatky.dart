import 'package:flutter/material.dart';

/* ===================== MODEL ===================== */

enum DiaryStatus { pending, approved, rejected }

class DiaryEntry {
  final int week;
  final String timeRange;          // ví dụ: 15/09/2025 – 21/09/2025
  final String content;            // nội dung công việc đã thực hiện
  final String? resultFileName;    // tên file kết quả (mock)
  final DiaryStatus status;
  final String? teacherNote;

  const DiaryEntry({
    required this.week,
    required this.timeRange,
    required this.content,
    this.resultFileName,
    this.status = DiaryStatus.pending,
    this.teacherNote,
  });
}

/* ================== DANH SÁCH NHẬT KÝ ================== */

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  final List<DiaryEntry> _items = []; // bắt đầu rỗng

  // Thông tin kỳ/đợt hiển thị phía trên (mock)
  final String _startAt = '15-09-2025 10:00:00';
  final String _endAt   = '29-09-2025 23:59:33';
  final String _deadlineWeek1 = 'Tuần 1';

  Future<void> _goSubmit() async {
    final nextWeek = _items.isEmpty ? 1 : (_items.first.week + 1);
    final result = await Navigator.push<DiaryEntry>(
      context,
      MaterialPageRoute(builder: (_) => SubmitDiaryPage(defaultWeek: nextWeek)),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _items.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã nộp nhật ký thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200 ? 1000 : w >= 900 ? 840 : w >= 600 ? 560 : w;
    final double pad  = w >= 900 ? 24 : 16;
    final double gap  = w >= 900 ? 16 : 12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Nhật ký', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
              children: [
                // Thông tin chung
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dotText('Ngày bắt đầu: $_startAt', const Color(0xFFFFDD00)),
                        const SizedBox(height: 4),
                        _dotText('Ngày kết thúc: $_endAt', const Color(0xFFFFDD00)),
                        const SizedBox(height: 4),
                        _dotText('Thời hạn nộp nhật ký: $_deadlineWeek1', const Color(0xFFFFDD00)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                if (_items.isEmpty)
                  const _EmptyState(
                    icon: Icons.edit_note,
                    title: 'Bạn chưa có nhật ký trong hệ thống.',
                    subtitle: 'Nhấn nút “+” để nộp nhật ký tuần.',
                  )
                else
                  ...[
                    // danh sách nhật ký
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _DiaryCard(item: _items[i]),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goSubmit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _dotText(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

/* ================== CARD NHẬT KÝ ================== */

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.item});
  final DiaryEntry item;

  (Color bg, Color fg, String label) get _badge => switch (item.status) {
    DiaryStatus.approved => (const Color(0xFFDCFCE7), const Color(0xFF166534), 'GVHD đã xác nhận'),
    DiaryStatus.rejected => (const Color(0xFFFEE2E2), const Color(0xFF991B1B), 'Từ chối'),
    _ => (const Color(0xFFFFF7ED), const Color(0xFF9A3412), 'Chờ duyệt'),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg, label) = _badge;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tuần + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tuần ${item.week}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _Badge(text: label, bg: bg, fg: fg),
              ],
            ),
            const SizedBox(height: 6),
            _meta('Thời gian', item.timeRange),
            _meta('Nội dung công việc đã thực hiện', item.content),
            if (item.resultFileName != null) ...[
              _meta('Kết quả đạt được',
                  'File: ',
                  trailing: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mở tệp: ${item.resultFileName} (demo)')),
                    ),
                    child: Text(
                      item.resultFileName!,
                      style: TextStyle(color: cs.primary, decoration: TextDecoration.underline),
                    ),
                  )),
            ],
            if (item.teacherNote != null && item.teacherNote!.isNotEmpty)
              _meta('Nhận xét GVHD', item.teacherNote!),
          ],
        ),
      ),
    );
  }

  Widget _meta(String k, String v, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(k, style: const TextStyle(color: Colors.black54))),
        const SizedBox(width: 8),
        Expanded(
          child: trailing == null
              ? Text(v)
              : Row(children: [Text(v), const SizedBox(width: 4), Flexible(child: trailing)]),
        ),
      ],
    ),
  );
}

/* ================== NỘP NHẬT KÝ ================== */

class SubmitDiaryPage extends StatefulWidget {
  const SubmitDiaryPage({super.key, required this.defaultWeek});
  final int defaultWeek;

  @override
  State<SubmitDiaryPage> createState() => _SubmitDiaryPageState();
}

class _SubmitDiaryPageState extends State<SubmitDiaryPage> {
  final _contentCtrl = TextEditingController();
  final _fileCtrl = TextEditingController();
  late int _week;                  // tuần đang chọn
  late String _timeRange;          // khoảng thời gian hiển thị
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _week = widget.defaultWeek;
    _timeRange = _weekToRange(_week);
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _fileCtrl.dispose();
    super.dispose();
  }

  String _weekToRange(int w) {
    // mock: mỗi tuần 7 ngày bắt đầu từ 15/09/2025
    final start = DateTime(2025, 9, 15).add(Duration(days: (w - 1) * 7));
    final end = start.add(const Duration(days: 6));
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${fmt(start)} – ${fmt(end)}';
  }

  Future<void> _pickFileName() async {
    final txt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập tên tệp kết quả'),
        content: TextField(
          controller: _fileCtrl,
          decoration: const InputDecoration(hintText: 'VD: 225117362_DuongVanHung_2.pdf'),
          onSubmitted: (_) => Navigator.pop(ctx, _fileCtrl.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, _fileCtrl.text.trim()), child: const Text('Lưu')),
        ],
      ),
    );
    if (!mounted) return;
    if (txt != null) setState(() {}); // đã cập nhật _fileCtrl
  }

  Future<void> _submit() async {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung công việc đã thực hiện')));
      return;
    }

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 700)); // mock upload
    if (!mounted) return;
    setState(() => _sending = false);

    Navigator.pop(
      context,
      DiaryEntry(
        week: _week,
        timeRange: _timeRange,
        content: _contentCtrl.text.trim(),
        resultFileName: _fileCtrl.text.trim().isEmpty ? null : _fileCtrl.text.trim(),
        status: DiaryStatus.approved, // mock: auto “đã xác nhận” cho giống hình 3
        teacherNote: 'GVND đã xác nhận', // mock note
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200 ? 820 : w >= 900 ? 700 : w >= 600 ? 540 : w;
    final double pad  = w >= 900 ? 24 : 16;
    final double gap  = w >= 900 ? 16 : 12;

    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Nộp nhật ký', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chọn tuần (dropdown nho nhỏ giống "Tuần 1")
                        Row(
                          children: [
                            const Text('Tuần:'),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: _week,
                              items: List.generate(12, (i) => i + 1)
                                  .map((w) => DropdownMenuItem(value: w, child: Text('$w')))
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _week = v;
                                  _timeRange = _weekToRange(_week);
                                });
                              },
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: ShapeDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                _timeRange,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: gap),

                        // Nội dung đã thực hiện
                        Text('Nội dung công việc đã thực hiện', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _contentCtrl,
                          minLines: 4,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: 'Vui lòng nhập nội dung đã thực hiện…',
                            isDense: true,
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border.copyWith(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: gap),

                        // Kết quả đạt được (attach file - mock)
                        Text('Kết quả đạt được:', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        _AttachFileTile(
                          fileName: _fileCtrl.text.trim().isEmpty ? null : _fileCtrl.text.trim(),
                          onPick: _pickFileName,
                          onClear: _fileCtrl.text.trim().isEmpty ? null : () => setState(_fileCtrl.clear),
                        ),

                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _sending ? null : _submit,
                            child: _sending
                                ? const SizedBox(
                                width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Nộp nhật ký'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hướng dẫn
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Điền nội dung công việc theo tuần, đính kèm file kết quả (nếu có). '
                                'Sau khi nộp, nhật ký sẽ hiển thị ở trang danh sách.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================== COMMON ================== */

class _AttachFileTile extends StatelessWidget {
  const _AttachFileTile({required this.fileName, required this.onPick, this.onClear});
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final has = (fileName != null && fileName!.isNotEmpty);
    final text = has ? fileName! : 'Kéo & thả / Chọn tệp (PDF/DOCX)…';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined),
          const SizedBox(width: 12),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          if (has && onClear != null)
            IconButton(onPressed: onClear, icon: const Icon(Icons.close), tooltip: 'Xóa'),
          FilledButton.tonal(onPressed: onPick, child: Text(has ? 'Sửa' : 'Chọn tệp')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: cs.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }
}
