// filepath: lib/features/lecturer/views/screens/tien_do/tien_do.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/tien_do_service.dart';

class TienDo extends StatefulWidget {
  const TienDo({super.key});
  @override
  State<TienDo> createState() => TienDoState();
}

class TienDoState extends State<TienDo> {
  final _svc = TienDoService();

  var _items = <ProgressStudent>[];
  bool _loading = false;
  String? _error;

  int _selectedWeek = 1; // default tuần 1

  DateTime? get _from =>
      _items.isEmpty ? null : _items.first.ngayBatDau;
  DateTime? get _to =>
      _items.isEmpty ? null : _items.first.ngayKetThuc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _svc.fetchStudents(week: _selectedWeek);
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F7CD3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: const Text('Tiến độ'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header thời gian nộp
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              sliver: SliverToBoxAdapter(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bullet('Ngày bắt đầu : ${_fmt(_from)}',
                            dotColor: const Color(0xFFFFDD00)),
                        const SizedBox(height: 4),
                        _bullet('Ngày kết thúc : ${_fmt(_to)}',
                            dotColor: const Color(0xFF00C409)),
                        const SizedBox(height: 4),
                        _bullet('Thời hạn nộp nhật ký tuần : $_selectedWeek',
                            dotColor: const Color(0xFF155EEF)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Danh sách sinh viên:',
                                style:
                                Theme.of(context).textTheme.titleMedium),
                            const SizedBox(width: 8),
                            _weekDropdown(),
                            const Spacer(),
                            IconButton(
                                tooltip: 'Tải lại',
                                onPressed: _load,
                                icon: const Icon(Icons.refresh)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Danh sách
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
              sliver: SliverToBoxAdapter(
                child: _error != null
                    ? _Error(message: _error!, onRetry: _load)
                    : _loading
                    ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator()))
                    : Column(
                  children: _items
                      .map((e) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: 12),
                    child: _StudentCard(
                      info: e,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProgressDetailScreen(
                              student: e,
                              weekNow: _selectedWeek,
                            ),
                          ),
                        );
                      },
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedWeek,
          items: List.generate(
            15,
                (i) => DropdownMenuItem(
              value: i + 1,
              child: Text('Tuần ${i + 1}'),
            ),
          ),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _selectedWeek = v);
            _load();
          },
        ),
      ),
    );
  }

  Widget _bullet(String text, {required Color dotColor}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 1.8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info, this.onTap});
  final ProgressStudent info;
  final VoidCallback? onTap;

  Color get _statusColor =>
      info.status == SubmitStatus.submitted
          ? const Color(0xFF00C409)
          : const Color(0xFFFFA000);
  String get _statusText =>
      info.status == SubmitStatus.submitted ? 'đã nộp' : 'chưa nộp';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: const Color(0xFFE4F6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFDBEAFE),
                    child: Icon(Icons.person, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info.hoTen,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(info.maSinhVien,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: const Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(info.lop,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Trạng thái: '),
                            TextSpan(
                              text: _statusText,
                              style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Đề tài: ${info.deTai}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressDetailScreen extends StatefulWidget {
  const ProgressDetailScreen({
    super.key,
    required this.student,
    required this.weekNow,
  });

  final ProgressStudent student;
  final int weekNow;

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  final _svc = TienDoService();
  var _entries = <WeeklyEntry>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _svc.fetchWeeksByTopic(widget.student.idDeTai);
      setState(() => _entries = list..sort((a, b) => b.tuan.compareTo(a.tuan)));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F7CD3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Tiến độ', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _error != null
          ? _Error(message: _error!, onRetry: _load)
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          // 3 ô thống kê tĩnh (demo)
          const Row(
            children: [
              _StatCard(value: '8', label: 'Tuần nộp đúng hạn'),
              SizedBox(width: 10),
              _StatCard(value: '1', label: 'Tuần nộp muộn'),
              SizedBox(width: 10),
              _StatCard(value: '52%', label: 'Hoàn thành'),
            ],
          ),
          const SizedBox(height: 14),
          Text('Tiến độ từng tuần:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827))),
          const SizedBox(height: 10),

          for (final e in _entries) ...[
            _WeekCard(
              entry: e,
              onReview: () => _showReviewDialog(
                context: context,
                deTaiId: widget.student.idDeTai,
                week: e.tuan,
                onSubmit: (note) async {
                  await _svc.submitReview(
                    deTaiId: widget.student.idDeTai,
                    tuan: e.tuan,
                    nhanXet: note,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi nhận xét.')),
                    );
                    _load();
                  }
                },
              ),
              openFile: () {
                final url = e.duongDanFile;
                if (url.isEmpty) return;
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              fmt: _fmt,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/* ---------- UI phụ ---------- */

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF2F6BFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF2F6BFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.entry,
    required this.onReview,
    required this.openFile,
    required this.fmt,
  });

  final WeeklyEntry entry;
  final VoidCallback onReview;
  final VoidCallback openFile;
  final String Function(DateTime?) fmt;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(2, 6, 23, .08), blurRadius: 10),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE4F6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowLabelValue('', 'Tuần : ${entry.tuan}', isTitle: true),
            const SizedBox(height: 6),
            _rowLabelValue('Thời gian:  ',
                '${fmt(entry.ngayBatDau)} - ${fmt(entry.ngayKetThuc)}'),
            const SizedBox(height: 6),
            _rowLabelValue('Nội dung công việc đã thực hiện:  ', entry.noiDung),
            const SizedBox(height: 6),
            const Text(
              'Kết quả đã thực hiện:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.57,
                letterSpacing: -0.41,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text(
                  'File:  ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.57,
                    letterSpacing: -0.41,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: openFile,
                    child: Text(
                      entry.duongDanFile.split('/').last,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0090FF),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ActionButton(label: 'Nhận xét', onTap: onReview),
              ],
            ),
            if ((entry.nhanXet ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Nhận xét: ${entry.nhanXet}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rowLabelValue(String label, String value, {bool isTitle = false}) {
    const labelStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.57,
      letterSpacing: -0.41,
    );
    final valueStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.41,
    );

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Roboto'),
        children: [
          if (label.isNotEmpty) TextSpan(text: label, style: labelStyle),
          TextSpan(text: value, style: valueStyle),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF155EEF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 24),
      Icon(Icons.error_outline,
          color: Theme.of(context).colorScheme.error, size: 32),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại')),
    ],
  );
}

/// Popup nhận xét ở GIỮA màn hình + gọi PUT sau khi xác nhận
Future<void> _showReviewDialog({
  required BuildContext context,
  required int deTaiId,
  required int week,
  required Future<void> Function(String note) onSubmit,
}) async {
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: const Center(
        child: Text('Nhận xét',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Đưa ra nhận xét ...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF94A3B8)),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 120,
              height: 34,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF155EEF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  final note = controller.text.trim();
                  if (note.isEmpty) return;
                  Navigator.of(context).pop();
                  await onSubmit(note);
                },
                child: const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  controller.dispose();
}
