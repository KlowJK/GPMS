import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:GPMS/features/student/viewmodels/nop_nhat_ky_viewmodel.dart';
import 'package:GPMS/features/student/models/nop_nhat_ki.dart';
import 'package:GPMS/core/exception/error_code.dart';

/// Màn hình nộp nhật ký
///
/// Refactored để:
/// - Consume ViewModel từ parent provider
/// - Handle errors với ErrorCode
/// - Better file picker integration
class SubmitDiaryPage extends StatefulWidget {
  const SubmitDiaryPage({
    super.key,
    required this.defaultWeek,
    this.deTaiId,
    this.idNhatKy,
    this.ngayBatDau,
    this.ngayKetThuc,
  });

  final int defaultWeek;
  final int? deTaiId;
  final int? idNhatKy;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;

  @override
  State<SubmitDiaryPage> createState() => _SubmitDiaryPageState();
}

class _SubmitDiaryPageState extends State<SubmitDiaryPage> {
  final _contentCtrl = TextEditingController();
  final _fileCtrl = TextEditingController();
  late int _week;
  late String _timeRange;
  String? _pickedFilePath;

  @override
  void initState() {
    super.initState();
    _week = widget.defaultWeek;

    // Use provided dates or compute from week
    if (widget.ngayBatDau != null && widget.ngayKetThuc != null) {
      _timeRange = _formatDateRange(widget.ngayBatDau!, widget.ngayKetThuc!);
    } else {
      _timeRange = _weekToRange(_week);
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _fileCtrl.dispose();
    super.dispose();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${fmt(start)} – ${fmt(end)}';
  }

  String _weekToRange(int w) {
    final start = DateTime(2025, 9, 15).add(Duration(days: (w - 1) * 7));
    final end = start.add(const Duration(days: 6));
    return _formatDateRange(start, end);
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        withData: false,
      );

      if (result == null) return;

      final path = result.files.single.path;
      if (path == null) return;

      setState(() {
        _pickedFilePath = path;
        _fileCtrl.text = path.split(Platform.pathSeparator).last;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn tệp: $e')));
      }
    }
  }

  Future<void> _clearFile() async {
    setState(() {
      _pickedFilePath = null;
      _fileCtrl.clear();
    });
  }

  Future<void> _submit(SubmitDiaryViewModel vm) async {
    // Validate content
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung công việc đã thực hiện'),
        ),
      );
      return;
    }

    // Validate required IDs
    if (widget.idNhatKy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có ID nhật ký. Không thể nộp.')),
      );
      return;
    }

    if (widget.deTaiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có ID đề tài. Không thể nộp.')),
      );
      return;
    }

    // Submit
    final success = await vm.submit(
      deTaiId: widget.deTaiId!,
      idNhatKy: widget.idNhatKy!,
      noiDung: _contentCtrl.text.trim(),
      filePath: _pickedFilePath,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nộp nhật ký thành công')));

      // Return result
      if (widget.deTaiId != null || widget.idNhatKy != null) {
        Navigator.pop(context, null); // Server-backed
      } else {
        // Local (shouldn't happen with new flow)
        final fileName = _pickedFilePath != null
            ? _pickedFilePath!.split(Platform.pathSeparator).last
            : null;

        Navigator.pop(
          context,
          DiaryEntry(
            week: _week,
            timeRange: _timeRange,
            content: _contentCtrl.text.trim(),
            resultFileName: fileName,
            status: DiaryStatus.DA_NOP,
            teacherNote: vm.result?.nhanXet,
          ),
        );
      }
    } else {
      _handleError(vm);
    }
  }

  void _handleError(SubmitDiaryViewModel vm) {
    String title = 'Lỗi khi nộp nhật ký';
    String message = vm.error ?? 'Không thể nộp nhật ký';

    // Handle specific errors
    if (vm.errorCode == ErrorCode.unauthenticated) {
      title = 'Phiên đăng nhập hết hạn';
      message = 'Vui lòng đăng nhập lại';
    } else if (vm.errorCode == ErrorCode.timeout) {
      title = 'Kết nối hết thời gian chờ';
      message = 'Vui lòng thử lại';
    } else if (vm.errorCode == ErrorCode.uploadFileFailed) {
      title = 'Tải file thất bại';
      message = 'Không thể tải file lên. Vui lòng thử lại.';
    } else if (vm.errorCode == ErrorCode.noiDungRequired) {
      title = 'Thiếu nội dung';
      message = 'Vui lòng nhập nội dung công việc';
    }

    // Show error dialog
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: message));
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép lỗi vào clipboard'),
                  ),
                );
              }
            },
            child: const Text('Sao chép'),
          ),
        ],
      ),
    );

    // Also show snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxW = w >= 1200
        ? 820
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

    return Consumer<SubmitDiaryViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Nộp nhật ký',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2563EB),
            centerTitle: true,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(gap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Week info
                            Row(
                              children: [
                                const Text('Tuần:'),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  child: Text(
                                    '$_week',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(
                                    _timeRange,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Content field
                            Text(
                              'Nội dung công việc đã thực hiện',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _contentCtrl,
                              minLines: 4,
                              maxLines: 8,
                              decoration: InputDecoration(
                                hintText:
                                    'Vui lòng nhập nội dung đã thực hiện…',
                                isDense: true,
                                border: border,
                                enabledBorder: border,
                                focusedBorder: border.copyWith(
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // File picker
                            Text(
                              'Kết quả đạt được:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 6),
                            _AttachFileTile(
                              fileName: _fileCtrl.text.trim().isEmpty
                                  ? null
                                  : _fileCtrl.text.trim(),
                              filePath: _pickedFilePath,
                              onPick: _pickFile,
                              onClear: _pickedFilePath == null
                                  ? null
                                  : _clearFile,
                            ),

                            // Upload progress
                            const SizedBox(height: 8),
                            if (vm.isSubmitting) _buildProgressIndicator(vm),

                            const SizedBox(height: 12),

                            // Submit button
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: vm.isSubmitting
                                    ? null
                                    : () => _submit(vm),
                                child: vm.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Nộp nhật ký'),
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
                                'Điền nội dung công việc theo tuần, đính kèm file '
                                'kết quả (nếu có). Sau khi nộp, nhật ký sẽ hiển thị '
                                'ở trang danh sách.',
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

  Widget _buildProgressIndicator(SubmitDiaryViewModel vm) {
    if (vm.bytesTotal > 0) {
      final pct = (vm.progress * 100).clamp(0, 100).toStringAsFixed(0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: vm.progress),
          const SizedBox(height: 6),
          Text(
            'Đang tải lên: $pct% (${vm.bytesSent}/${vm.bytesTotal} bytes)',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      );
    }

    return Column(
      children: const [
        LinearProgressIndicator(),
        SizedBox(height: 6),
        Text(
          'Đang gửi...',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _AttachFileTile extends StatelessWidget {
  const _AttachFileTile({
    required this.fileName,
    required this.onPick,
    this.onClear,
    this.filePath,
  });

  final String? fileName;
  final String? filePath;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null && fileName!.isNotEmpty;
    final displayText = hasFile
        ? fileName!
        : 'Kéo & thả / Chọn tệp (PDF/DOCX)…';

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
          Expanded(
            child: hasFile && filePath != null
                ? InkWell(
                    onTap: () async {
                      try {
                        await OpenFile.open(filePath);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không thể mở tệp')),
                          );
                        }
                      }
                    },
                    child: Text(
                      displayText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF2563EB)),
                    ),
                  )
                : Text(
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
