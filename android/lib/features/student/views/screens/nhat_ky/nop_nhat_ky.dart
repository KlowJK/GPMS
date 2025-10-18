import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';

import 'package:GPMS/features/student/viewmodels/nop_nhat_ky_viewmodel.dart';
import 'package:GPMS/features/student/models/nop_nhat_ki.dart';

/* Local diary model and submit page extracted from nhat_ky.dart */

class SubmitDiaryPage extends StatefulWidget {
  const SubmitDiaryPage({super.key, required this.defaultWeek, this.deTaiId, this.idNhatKy, this.ngayBatDau, this.ngayKetThuc});
  final int defaultWeek;
  final int? deTaiId; // optional - if you have it, pass when opening the page
  final int? idNhatKy; // optional - diary id (server idNhatKy)
  final DateTime? ngayBatDau; // optional start date for the week (from server)
  final DateTime? ngayKetThuc; // optional end date for the week (from server)

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
    // If caller provided exact start/end dates, use them; otherwise compute from week
    if (widget.ngayBatDau != null && widget.ngayKetThuc != null) {
      String fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      _timeRange = '${fmt(widget.ngayBatDau!)} – ${fmt(widget.ngayKetThuc!)}';
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

  String _weekToRange(int w) {
    final start = DateTime(2025, 9, 15).add(Duration(days: (w - 1) * 7));
    final end = start.add(const Duration(days: 6));
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${fmt(start)} – ${fmt(end)}';
  }

  Future<void> _pickFile() async {
    // Use file_picker to pick a single PDF/DOCX
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        withData: false,
      );
      if (res == null) return; // user canceled
      final path = res.files.single.path;
      if (path == null) return;
      setState(() {
        _pickedFilePath = path;
        _fileCtrl.text = path.split(Platform.pathSeparator).last;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn tệp: $e')));
    }
  }

  Future<void> _clearFile() async {
    setState(() {
      _pickedFilePath = null;
      _fileCtrl.clear();
    });
  }

  Future<void> _submit(SubmitDiaryViewModel vm) async {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung công việc đã th���c hiện')));
      return;
    }

    // Use IDs provided by the caller (widget). The UI no longer shows/edit these fields.
    if (widget.idNhatKy == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có ID nhật ký (idNhatKy). Không thể nộp.')));
      return;
    }
    if (widget.deTaiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có ID đề tài (deTaiId). Không thể nộp.')));
      return;
    }

    final idNhatKy = widget.idNhatKy!;
    final deTaiId = widget.deTaiId!;

    // Use the provided ViewModel instance passed from the button's Consumer
    final success = await vm.submit(
      deTaiId: deTaiId,
      idNhatKy: idNhatKy,
      noiDung: _contentCtrl.text.trim(),
      filePath: _pickedFilePath,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nộp nhật ký thành công')));
      // Map server response into local DiaryEntry when possible
      final fileName = _pickedFilePath != null
          ? _pickedFilePath!.split(Platform.pathSeparator).last
          : (_fileCtrl.text.trim().isEmpty ? null : _fileCtrl.text.trim());
      final teacherNote = vm.result?.nhanXet;
      // If this page was opened for an existing server diary (deTaiId or idNhatKy provided),
      // do not return a local DiaryEntry — let the parent refresh server data instead.
      if (widget.deTaiId != null || widget.idNhatKy != null) {
        Navigator.pop(context, null);
      } else {
        Navigator.pop(
          context,
          DiaryEntry(
            week: _week,
            timeRange: _timeRange,
            content: _contentCtrl.text.trim(),
            resultFileName: fileName,
            status: DiaryStatus.approved,
            teacherNote: teacherNote,
          ),
        );
      }
    } else {
      final err = vm.error ?? 'Không thể nộp nhật ký';
      // Show detailed dialog with raw error and copy button
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Lỗi khi nộp nhật ký'),
            content: SingleChildScrollView(child: Text(vm.rawError ?? err)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () async {
                  final textToCopy = vm.rawError ?? err;
                  await Clipboard.setData(ClipboardData(text: textToCopy));
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép lỗi vào clipboard'),
                      ),
                    );
                },
                child: const Text('Sao chép'),
              ),
            ],
          );
        },
      );
      // also show a small snackbar
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
    }
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

    return ChangeNotifierProvider<SubmitDiaryViewModel>(
      create: (_) => SubmitDiaryViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nộp nhật ký', style: TextStyle(color: Colors.white)),
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
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Text('Tuần:'),
                          const SizedBox(width: 8),
                          // show week as read-only text (taken from widget.defaultWeek)
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor), color: Theme.of(context).colorScheme.surface), child: Text('$_week', style: const TextStyle(fontSize: 14))),
                          const Spacer(),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: ShapeDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: const StadiumBorder()), child: Text(_timeRange, style: const TextStyle(fontSize: 12))),
                        ]),

                        const SizedBox(height: 12),

                        // Removed ID fields: idNhatKy and deTaiId are supplied by the caller (widget.idNhatKy/widget.deTaiId)

                        const SizedBox(height: 12),

                        Text('Nội dung công việc đã thực hiện', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        TextField(controller: _contentCtrl, minLines: 4, maxLines: 8, decoration: InputDecoration(hintText: 'Vui lòng nhập nội dung đã thực hiện…', isDense: true, border: border, enabledBorder: border, focusedBorder: border.copyWith(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)))),

                        const SizedBox(height: 12),

                        Text('Kết quả đạt được:', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        _AttachFileTile(fileName: _fileCtrl.text.trim().isEmpty ? null : _fileCtrl.text.trim(), filePath: _pickedFilePath, onPick: _pickFile, onClear: _pickedFilePath == null ? null : _clearFile),

                        // debug token/ping removed

                        // Show upload progress when submitting with a file
                        const SizedBox(height: 8),
                        Consumer<SubmitDiaryViewModel>(builder: (context, vm, _) {
                          if (!vm.isSubmitting) return const SizedBox.shrink();
                          if (vm.bytesTotal > 0) {
                            final pct = (vm.progress * 100).clamp(0, 100).toStringAsFixed(0);
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              LinearProgressIndicator(value: vm.progress),
                              const SizedBox(height: 6),
                              Text('Đang tải lên: $pct% (${vm.bytesSent}/${vm.bytesTotal} bytes)', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ]);
                          }
                          return Column(children: const [LinearProgressIndicator(), SizedBox(height: 6), Text('Đang gửi...', style: TextStyle(fontSize: 12, color: Colors.black54))]);
                        }),

                        const SizedBox(height: 12),
                        Align(alignment: Alignment.centerRight, child: Consumer<SubmitDiaryViewModel>(builder: (context, vm, _) {
                          return FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                            onPressed: vm.isSubmitting ? null : () => _submit(vm),
                            child: vm.isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Nộp nhật ký'),
                          );
                        })),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 12),

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
                              'Điền nội dung công việc theo tuần, đính kèm file kết quả (nếu có). Sau khi nộp, nhật ký sẽ hiển thị ở trang danh sách.',
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
      ),
    );
  }
}

class _AttachFileTile extends StatelessWidget {
  const _AttachFileTile({required this.fileName, required this.onPick, this.onClear, this.filePath});
  final String? fileName;
  final String? filePath; // local path to open
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final has = fileName != null && fileName!.isNotEmpty;
    final text = has ? fileName! : 'Kéo & thả / Chọn tệp (PDF/DOCX)…';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(children: [
        const Icon(Icons.cloud_upload_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: has && filePath != null
              ? InkWell(
                  onTap: () async {
                    try {
                      await OpenFile.open(filePath);
                    } catch (e) {
                      if (ScaffoldMessenger.maybeOf(context) != null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở tệp')));
                      }
                    }
                  },
                  child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF2563EB))),
                )
              : Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        if (has && onClear != null) IconButton(onPressed: onClear, icon: const Icon(Icons.close), tooltip: 'Xóa'),
        FilledButton.tonal(onPressed: onPick, child: Text(has ? 'Sửa' : 'Chọn tệp')),
      ]),
    );
  }
}
