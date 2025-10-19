import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:GPMS/features/lecturer/services/tien_do_service.dart';
import 'package:GPMS/features/lecturer/models/tien_do_item.dart';

class TienDo extends StatefulWidget {
  const TienDo({super.key});
  @override
  State<TienDo> createState() => _TienDoState();
}

class _TienDoState extends State<TienDo> {
  DateTime? _from, _to;
  List<int> _weeks = const [1];
  int _selectedWeek = 1;

  final _items = <ProgressStudent>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHeaderAndList();
  }

  Future<void> _loadHeaderAndList() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final info = await TienDoService.fetchWeeksByLecturer(includeAll: false);
      setState(() {
        _from = info.from;
        _to = info.to;
        _weeks = List.of(info.weeks);           // <-- danh sách tuần đầy đủ
        _selectedWeek = info.selectedWeek;      // <-- tuần đang chọn
      });

      final list = await TienDoService.listStudents(week: _selectedWeek);
      setState(() { _items..clear()..addAll(list); });
    } catch (e) {
      setState(() => _error = 'Lỗi tải dữ liệu: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadListOnly() async {
    try {
      final list = await TienDoService.listStudents(week: _selectedWeek);
      setState(() { _items..clear()..addAll(list); });
    } catch (e) {
      setState(() => _error = 'Lỗi tải danh sách: $e');
    }
  }


  String _fmtDt(DateTime? d) {
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
            // Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              sliver: SliverToBoxAdapter(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bullet('Ngày bắt đầu : ${_fmtDt(_from)}', dotColor: const Color(0xFFFFDD00)),
                        const SizedBox(height: 4),
                        _bullet('Ngày kết thúc : ${_fmtDt(_to)}', dotColor: const Color(0xFF00C409)),
                        const SizedBox(height: 4),
                        _bullet('Thời hạn nộp nhật ký tuần : $_selectedWeek', dotColor: const Color(0xFF155EEF)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Danh sách sinh viên: '),
                            const SizedBox(width: 8),
                            _weekDropdown(context),
                            const Spacer(),
                            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHeaderAndList),
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
                    ? _Error(message: _error!, onRetry: _loadHeaderAndList)
                    : _loading
                    ? const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
                    : Column(
                  children: _items.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StudentCard(
                      info: e,
                      onTap: () async {
                        final entries = await TienDoService.fetchStudentLogs(
                          maSinhVien: e.maSinhVien,
                          deTaiId: e.idDeTai,
                          week: _selectedWeek,
                        );
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProgressDetailScreen(
                              student: e,
                              entries: entries,
                            ),
                          ),
                        );
                      },
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekDropdown(BuildContext context) {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<int>(
        isDense: true,
        value: _selectedWeek,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: _weeks.map((w) => DropdownMenuItem(value: w, child: Text('Tuần $w'))).toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _selectedWeek = v);
          _loadListOnly();
        },
      ),
    );
  }

  Widget _bullet(String text, {required Color dotColor}) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: dotColor, width: 1.8)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

/* ---------------------------- phần còn lại giữ nguyên ---------------------------- */

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.info, this.onTap});
  final ProgressStudent info;
  final VoidCallback? onTap;

  Color get _statusColor =>
      info.status == SubmitStatus.submitted ? const Color(0xFF00C409) : const Color(0xFFFFA000);
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
                    radius: 20, backgroundColor: Color(0xFFDBEAFE),
                    child: Icon(Icons.person, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info.hoTen,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(info.maSinhVien,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(info.lop, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Trạng thái: '),
                            TextSpan(text: _statusText, style: TextStyle(color: _statusColor, fontWeight: FontWeight.w500)),
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
                child: Text(
                  'Đề tài: ${info.deTai.isEmpty ? "—" : info.deTai}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressDetailScreen extends StatelessWidget {
  const ProgressDetailScreen({super.key, required this.student, required this.entries});
  final ProgressStudent student;
  final List<WeeklyEntry> entries;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          for (final e in entries) ...[
            _WeekCard(
              entry: e,
              fmt: _fmt,
              onReview: () async {
                final note = await _showReviewDialog(context: context);
                if (note == null) return;
                final updated = await TienDoService.review(id: e.id, nhanXet: note);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã gửi nhận xét cho tuần ${updated.tuan}.')),
                );
              },
              openFile: () {
                final url = e.duongDanFile;
                if (url.isEmpty) return;
                final uri = Uri.tryParse(url);
                if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.entry, required this.onReview, required this.openFile, required this.fmt});
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
        boxShadow: const [BoxShadow(color: Color.fromRGBO(2, 6, 23, .08), blurRadius: 10)],
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFE4F6FF), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowLabelValue('', 'Tuần : ${entry.tuan}', isTitle: true),
            const SizedBox(height: 6),
            _rowLabelValue('Thời gian:  ', '${fmt(entry.ngayBatDau)} - ${fmt(entry.ngayKetThuc)}'),
            const SizedBox(height: 6),
            _rowLabelValue('Nội dung công việc đã thực hiện:  ', entry.noiDung),
            const SizedBox(height: 6),
            const Text('Kết quả đã thực hiện:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('File:  ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
    const labelStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600);
    final valueStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400);
    return RichText(
      text: TextSpan(style: const TextStyle(fontFamily: 'Roboto'), children: [
        if (label.isNotEmpty) TextSpan(text: label, style: labelStyle),
        TextSpan(text: value, style: valueStyle),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF155EEF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text('Nhận xét', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message; final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 24),
      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 32),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
    ],
  );
}

/* Dialog nhận xét */
Future<String?> _showReviewDialog({required BuildContext context}) async {
  final c = TextEditingController();
  final note = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: const Center(child: Text('Nhận xét', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600))),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: c, minLines: 6, maxLines: 10, decoration: const InputDecoration(hintText: 'Đưa ra nhận xét ...', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          SizedBox(width: 120, height: 34, child: FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Xác nhận'))),
        ]),
      ),
    ),
  );
  return (note != null && note.trim().isNotEmpty) ? note.trim() : null;
}
