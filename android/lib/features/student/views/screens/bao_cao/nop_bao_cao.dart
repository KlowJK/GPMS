import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/bao_cao_viewmodel.dart';

class SubmitReportPage extends StatefulWidget {
  const SubmitReportPage({super.key});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  final TextEditingController _fileCtrl = TextEditingController();

  String? _pickedPath;
  bool _sending = false;

  @override
  void dispose() {
    _fileCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFileName() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      allowMultiple: false,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.first;
      setState(() {
        _fileCtrl.text = f.name;
        _pickedPath = f.path; // on Android/iOS path is available
      });
    }
  }

  Future<void> _submit() async {
    final name = _fileCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn/nhập tệp báo cáo')),
      );
      return;
    }
    if (!name.toLowerCase().endsWith('.pdf') &&
        !name.toLowerCase().endsWith('.docx')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ chấp nhận tệp .pdf hoặc .docx')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.help_outline,
          size: 40,
          color: Color(0xFF2563EB),
        ),
        title: const Text('Xác nhận nộp báo cáo'),
        content: Text('Gửi tệp “$name”?'),
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
    );
    if (ok != true) return;

    setState(() => _sending = true);

    final vm = context.read<BaoCaoViewModel>();
    final maxVersion = vm.items.isEmpty ? 0 : vm.items.map((r) => r.version).reduce(math.max);
    final newVersion = maxVersion + 1;

    try {
      print(
          '[SubmitReportPage] Starting submitReport, version: $newVersion, filePath: $_pickedPath, fileName: $name');
      await vm
          .submitReport(version: newVersion, filePath: _pickedPath, fileName: name)
          .timeout(const Duration(seconds: 40), onTimeout: () {
        print('[SubmitReportPage] submitReport timed out');
        throw TimeoutException('Yêu cầu nộp báo cáo quá thời gian chờ.');
      });
      print('[SubmitReportPage] submitReport completed');

      if (vm.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi nộp báo cáo: ${vm.error}')),
        );
        setState(() => _sending = false);
        return;
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      print('[SubmitReportPage] submitReport threw: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nộp báo cáo: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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

    // Observe ViewModel to display upload progress
    final vm = context.watch<BaoCaoViewModel>();
    final uploading = _sending || vm.bytesTotal > 0;
    final progress = vm.progress; // 0.0..1.0

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Nộp báo cáo', style: TextStyle(color: Colors.white)),
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
                if (uploading) ...[
                  LinearProgressIndicator(
                      value: vm.bytesTotal > 0 ? progress : null),
                  const SizedBox(height: 8),
                  if (vm.bytesTotal > 0)
                    Text('Đang tải lên: ${(progress * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 12),
                ],
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
                        _AttachFileTile(
                          fileName: _fileCtrl.text.trim().isEmpty
                              ? null
                              : _fileCtrl.text.trim(),
                          onPick: uploading ? () {} : _pickFileName,
                          onClear: _fileCtrl.text.trim().isEmpty
                              ? null
                              : () => setState(() {
                                    if (uploading) return;
                                    _fileCtrl.clear();
                                    _pickedPath = null;
                                  }),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: (uploading || _sending) ? null : _submit,
                            child: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Nộp báo cáo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Chấp nhận tệp PDF. Sau khi nộp, trạng thái là “Chờ duyệt”. '
                            ,
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
          Expanded(
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          if (has && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Xóa',
            ),
          FilledButton.tonal(
            onPressed: onPick,
            child: Text(has ? 'Sửa' : 'Chọn tệp'),
          ),
        ],
      ),
    );
  }
}
