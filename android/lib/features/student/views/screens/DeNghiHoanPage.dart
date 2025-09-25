import 'package:flutter/material.dart';

void main() => runApp(const DeNghiHoanApp());

class DeNghiHoanApp extends StatelessWidget {
  const DeNghiHoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F7CD3);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đề nghị hoãn đồ án',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const DeNghiHoanPage(),
    );
  }
}

class DeNghiHoanPage extends StatefulWidget {
  const DeNghiHoanPage({super.key});
  @override
  State<DeNghiHoanPage> createState() => _DeNghiHoanPageState();
}

class _DeNghiHoanPageState extends State<DeNghiHoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _lyDoCtrl = TextEditingController();
  final _fileCtrl = TextEditingController();
  final _focusLyDo = FocusNode();

  bool _sending = false;

  @override
  void dispose() {
    _lyDoCtrl.dispose();
    _fileCtrl.dispose();
    _focusLyDo.dispose();
    super.dispose();
  }

  Future<void> _chonFileMinhChung() async {
    final txt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File minh chứng (tùy chọn)'),
        content: TextField(
          controller: _fileCtrl,
          decoration: const InputDecoration(
            hintText: 'Nhập tên tệp hoặc đường dẫn (PDF/DOCX)…',
          ),
          textInputAction: TextInputAction.done,
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
    if (txt != null) setState(() {}); // _fileCtrl đã giữ giá trị mới
  }

  Future<void> _confirmAndSend() async {
    // Validate trước khi hỏi xác nhận
    if (!_formKey.currentState!.validate()) {
      _focusLyDo.requestFocus();
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2F7CD3),
          child: const Icon(Icons.help_outline, color: Colors.white),
        ),
        title: const Text('Bạn có chắc chắn muốn gửi đề nghị hoãn đồ án không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    ) ?? false;

    if (!ok) return;

    await _guiDeNghi();
  }

  Future<void> _guiDeNghi() async {
    setState(() => _sending = true);

    // TODO: gọi API thực tế tại đây
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _sending = false);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Đã gửi đề nghị hoãn. Vui lòng chờ duyệt!')),
      );

    // Nếu trang này được mở bằng Navigator.push, có thể pop và trả kết quả:
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Breakpoints + bề rộng nội dung tối đa (responsive)
    final double maxContentWidth = w >= 1200
        ? 1000
        : w >= 900
        ? 840
        : w >= 600
        ? 560
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
        title: const Text('Đề nghị hoãn đồ án', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
              children: [
                // ===== FORM =====
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin đề nghị',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: gap),

                          // Lý do hoãn
                          TextFormField(
                            controller: _lyDoCtrl,
                            focusNode: _focusLyDo,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Lý do hoãn',
                              hintText: 'Nhập lý do hoãn…',
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Hãy nhập lý do hoãn' : null,
                          ),
                          SizedBox(height: gap),

                          // File minh chứng (tùy chọn)
                          _AttachFileTile(
                            fileName: _fileCtrl.text.trim().isEmpty ? null : _fileCtrl.text.trim(),
                            onPick: _chonFileMinhChung,
                            onClear: _fileCtrl.text.trim().isEmpty
                                ? null
                                : () => setState(_fileCtrl.clear),
                          ),

                          SizedBox(height: gap),

                          // Khu xem nhanh/ghi chú
                          _PreviewOrNote(gap: gap),

                          const Divider(height: 24),

                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _sending ? null : _confirmAndSend,
                              icon: _sending
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Icon(Icons.send),
                              label: const Text('Gửi đề nghị'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: gap),

                // ===== LƯU Ý =====
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
                        Expanded(
                          child: Text(
                            'Hồ sơ sẽ ở trạng thái “Chờ duyệt”. Sau khi được phê duyệt, '
                                'Khoa sẽ thông báo lịch/đợt kế tiếp phù hợp.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    final hasFile = (fileName != null && fileName!.isNotEmpty);
    final fileText = hasFile ? fileName! : 'Chưa có file minh chứng (PDF/DOCX)…';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file),
          const SizedBox(width: 12),
          Expanded(
            child: Text(fileText, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          if (hasFile && onClear != null)
            IconButton(
              tooltip: 'Xóa tệp',
              onPressed: onClear,
              icon: const Icon(Icons.close),
            ),
          FilledButton.tonal(
            onPressed: onPick,
            child: Text(hasFile ? 'Sửa' : 'Đính kèm'),
          ),
        ],
      ),
    );
  }
}

class _PreviewOrNote extends StatelessWidget {
  const _PreviewOrNote({required this.gap});
  final double gap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(gap),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.picture_as_pdf_outlined, size: 42),
                ),
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            flex: 4,
            child: Text(
              'Nếu có file minh chứng, phần này có thể hiển thị thumbnail hoặc thông tin nhanh của tệp.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
