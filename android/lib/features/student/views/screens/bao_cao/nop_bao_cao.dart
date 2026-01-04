import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/core/exception/error_code.dart';

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
    try {
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
          _pickedPath = f.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn file: $e')));
      }
    }
  }

  Future<void> _submit() async {
    final name = _fileCtrl.text.trim();

    // Validate file name
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

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.help_outline,
          size: 40,
          color: Color(0xFF2563EB),
        ),
        title: const Text('Xác nhận nộp báo cáo'),
        content: Text('Gửi tệp "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Submit
    setState(() => _sending = true);

    final vm = context.read<BaoCaoViewModel>();

    // Calculate next version
    final maxVersion = vm.items.isEmpty
        ? 0
        : vm.items.map((r) => r.version).reduce(math.max);
    final newVersion = maxVersion + 1;

    try {
      await vm
          .submitReport(
            version: newVersion,
            filePath: _pickedPath,
            fileName: name,
          )
          .timeout(
            const Duration(seconds: 40),
            onTimeout: () {
              throw TimeoutException('Yêu cầu nộp báo cáo quá thời gian chờ.');
            },
          );

      if (!mounted) return;

      // Check for errors
      if (vm.hasError) {
        _handleError(vm);
        return;
      }

      // Success
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Handle timeout
      if (e is TimeoutException) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kết nối hết thời gian chờ. Vui lòng thử lại.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _handleError(BaoCaoViewModel vm) {
    String message = vm.error ?? '';

    // If backend returned a generic system error, map it to the business error
    // ErrorCode.deCuongNotApproved (code 4009) so the user sees the correct message.
    if (vm.errorCode == ErrorCode.internalServerError || message.contains('Lỗi hệ thống') || message.toLowerCase().contains('lỗi hệ thống')) {
      message = ErrorCode.deCuongNotApproved.message; // 'Đề cương chưa được phê duyệt.'
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    // Handle specific errors
    if (vm.errorCode == ErrorCode.unauthenticated) {
      message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
    } else if (vm.errorCode == ErrorCode.timeout) {
      message = 'Kết nối hết thời gian chờ. Vui lòng thử lại.';
    } else if (vm.errorCode == ErrorCode.uploadFileFailed) {
      message = 'Không thể tải file lên. Vui lòng thử lại.';
    } else if (vm.errorCode == ErrorCode.fileEmpty) {
      message = 'File không hợp lệ hoặc rỗng.';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    return Consumer<BaoCaoViewModel>(
      builder: (context, vm, _) {
        final uploading = _sending || vm.bytesTotal > 0;
        final progress = vm.progress;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // remove default back button
            backgroundColor: const Color(0xFF2563EB),
            title: const Text(
              'Nộp báo cáo',
              style: TextStyle(color: Colors.white),
            ),
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
                    // Upload progress
                    if (uploading) ...[
                      LinearProgressIndicator(
                        value: vm.bytesTotal > 0 ? progress : null,
                      ),
                      const SizedBox(height: 8),
                      if (vm.bytesTotal > 0)
                        Text(
                          'Đang tải lên: ${(progress * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),
                    ],

                    // Form card
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
                                  : () {
                                      if (uploading) return;
                                      setState(() {
                                        _fileCtrl.clear();
                                        _pickedPath = null;
                                      });
                                    },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: (uploading || _sending)
                                    ? null
                                    : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: _sending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Nộp báo cáo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info card
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
                                'Chấp nhận tệp PDF hoặc DOCX. Sau khi nộp, '
                                'trạng thái sẽ là "Chờ duyệt".',
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
      },
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
    final displayText = hasFile ? fileName! : 'Chưa chọn tệp (PDF/DOCX)…';

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
            child: Text(
              displayText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (hasFile && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Xóa',
            ),
          FilledButton.tonal(
            onPressed: onPick,
            child: Text(hasFile ? 'Sửa' : 'Chọn tệp'),
          ),
        ],
      ),
    );
  }
}
