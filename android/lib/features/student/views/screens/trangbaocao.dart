import 'package:flutter/material.dart';

void main() => runApp(const ReportApp());

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2563EB);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Báo cáo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
      ),
      home: const ReportListPage(),
    );
  }
}

/* ===================== MODEL ===================== */

enum ReportStatus { pending, approved, rejected }

class ReportItem {
  final String fileName;
  final DateTime createdAt;
  final int version;
  final ReportStatus status;
  final String? note;

  const ReportItem({
    required this.fileName,
    required this.createdAt,
    required this.version,
    this.status = ReportStatus.pending,
    this.note,
  });
}

/* ============== DANH SÁCH BÁO CÁO (Trang chính) ============== */

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final List<ReportItem> _items = []; // ban đầu trống

  Future<void> _goSubmit() async {
    final nextVersion = _items.length + 1;
    final result = await Navigator.push<ReportItem>(
      context,
      MaterialPageRoute(
        builder: (_) => SubmitReportPage(nextVersion: nextVersion),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _items.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã nộp báo cáo thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 560
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Báo cáo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
              child: _items.isEmpty
                  ? const _EmptyState(
                icon: Icons.description_outlined,
                title: 'Bạn chưa có báo cáo trong hệ thống.',
                subtitle: 'Nhấn nút “+” để nộp báo cáo.',
              )
                  : ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ReportCard(item: _items[i]),
              ),
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
}

/* ================== CARD HIỂN THỊ BÁO CÁO ================== */

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.item});
  final ReportItem item;

  String get _statusLabel => switch (item.status) {
    ReportStatus.approved => 'Đã duyệt',
    ReportStatus.rejected => 'Từ chối',
    _ => 'Chờ duyệt',
  };

  (Color bg, Color fg) get _statusColor => switch (item.status) {
    ReportStatus.approved =>
    (const Color(0xFFDCFCE7), const Color(0xFF166534)),
    ReportStatus.rejected =>
    (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    _ => (const Color(0xFFFFF7ED), const Color(0xFF9A3412)),
  };

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year} • '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _statusColor;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tên file + trạng thái
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mở tệp: ${item.fileName} (demo)')),
                    ),
                    child: Text(
                      item.fileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _Badge(text: _statusLabel, bg: bg, fg: fg),
              ],
            ),
            const SizedBox(height: 6),
            _meta('Phiên bản', '${item.version}'),
            _meta('Ngày nộp', _fmt(item.createdAt)),
            if (item.note != null && item.note!.isNotEmpty)
              _meta('Phản hồi', item.note!),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phúc đáp (demo)')),
                ),
                child: const Text('Phúc đáp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String k, String v) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(k, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

/* ================== NỘP BÁO CÁO (Submit) ================== */

class SubmitReportPage extends StatefulWidget {
  const SubmitReportPage({super.key, required this.nextVersion});
  final int nextVersion;

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  final TextEditingController _fileCtrl = TextEditingController();
  final TextEditingController _verCtrl = TextEditingController();

  bool _mienBu = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Gán phiên bản mặc định (đã khởi tạo controller -> KHÔNG còn LateInitializationError)
    _verCtrl.text = widget.nextVersion.toString();
  }

  @override
  void dispose() {
    _fileCtrl.dispose();
    _verCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFileName() async {
    final txt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn/nhập tên tệp báo cáo'),
        content: TextField(
          controller: _fileCtrl,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: 2025_Baocao_Nhom05.pdf',
          ),
          onSubmitted: (_) => Navigator.pop(ctx, _fileCtrl.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _fileCtrl.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (txt != null) setState(() {}); // _fileCtrl giữ giá trị mới
  }

  Future<void> _submit() async {
    if (_fileCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn/nhập tệp báo cáo')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.help_outline, size: 40, color: Color(0xFF2563EB)),
        title: const Text('Xác nhận nộp báo cáo'),
        content: Text('Gửi tệp “${_fileCtrl.text.trim()}”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Quay lại')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _sending = true);
    // TODO: upload thật lên server
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => _sending = false);
    // Navigator.pop(
    //   context,
    //   ReportItem(
    //     fileName: _fileCtrl.text.trim(),
    //     createdAt: DateTime.now(),
    //     version: int.tryParse(_verCtrl.text.trim()) ?? widget.nextVersion,
    //     status: ReportStatus.pending,
    //     note: _mienBu ? 'Miễn bù đã được ghi nhận' : null,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200
        ? 800
        : w >= 900
        ? 700
        : w >= 600
        ? 540
        : w;
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;

    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Nộp báo cáo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // để nút back và actions màu trắng
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW), // maxW là double
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad),
              children: [
                // ======= FORM CARD =======
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phiên bản',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _verCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border.copyWith(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: gap),

                        SizedBox(height: gap),
                        _AttachFileTile(
                          fileName: _fileCtrl.text.trim().isEmpty
                              ? null
                              : _fileCtrl.text.trim(),
                          onPick: _pickFileName,
                          onClear: _fileCtrl.text.trim().isEmpty
                              ? null
                              : () => setState(_fileCtrl.clear),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _sending ? null : _submit,
                            child: _sending
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                              CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Text('Nộp báo cáo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ======= HƯỚNG DẪN =======
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Chấp nhận tệp PDF/DOCX. Sau khi nộp, trạng thái là “Chờ duyệt”. '
                                'Bạn có thể phúc đáp khi giảng viên phản hồi.',
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

/* ================== COMMON WIDGETS ================== */

class _AttachFileTile extends StatelessWidget {
  const _AttachFileTile({
    required this.fileName,
    required this.onPick,
    this.onClear,
  });

  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final has = (fileName != null && fileName!.isNotEmpty);
    final text = has ? fileName! : 'Chưa chọn tệp (PDF/DOCX)…';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined),
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
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const ShapeDecoration(shape: StadiumBorder(), color: Colors.transparent),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
        ),
      ),
    );
  }
}
