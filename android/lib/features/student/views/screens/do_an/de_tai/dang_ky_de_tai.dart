import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../models/giang_vien_huong_dan.dart';
import '../../../../viewmodels/do_an_viewmodel.dart';

class RegisterResult {
  final String title;
  final int advisorId;
  final String advisorName;
  final String? overviewFile;

  RegisterResult({
    required this.title,
    required this.advisorId,
    required this.advisorName,
    this.overviewFile,
  });
}

class DangKyDeTai extends StatefulWidget {
  const DangKyDeTai({super.key});
  @override
  State<DangKyDeTai> createState() => DangKyDeTaiState();
}

class DangKyDeTaiState extends State<DangKyDeTai> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _fileCtrl = TextEditingController();

  final _focusTitle = FocusNode();
  final _focusDesc = FocusNode();

  bool _sending = false;
  String? _advisor;

  // bỏ String? _advisor;
  GiangVienHuongDan? _selectedAdvisor; // {'id': int, 'hoTen': String}

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _fileCtrl.dispose();
    _focusTitle.dispose();
    _focusDesc.dispose();
    super.dispose();
  }

  Future<void> _pickFileName() async {
    final txt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đính kèm tổng quan (tùy chọn)'),
        content: TextField(
          controller: _fileCtrl,
          decoration: const InputDecoration(
            hintText: 'Nhập tên tệp hoặc đường dẫn (PDF/DOCX)…',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(ctx, _fileCtrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _fileCtrl.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (txt != null) setState(() {});
  }

  Future<void> _confirmAndSubmit() async {
    // Validate trước khi hỏi xác nhận
    if (!_formKey.currentState!.validate()) {
      if (_advisor == null) {
        FocusScope.of(context).unfocus();
      } else if (_titleCtrl.text.trim().isEmpty) {
        _focusTitle.requestFocus();
      }
      return;
    }

    final ok =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF2F7CD3),
              child: const Icon(Icons.help_outline, color: Colors.white),
            ),
            title: const Text(
              'Bạn có chắc chắn muốn gửi đăng ký đề tài không?',
            ),
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
        ) ??
        false;

    if (!ok) return;

    await _submit();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);

    // TODO: gọi API thực tế tại đây
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _sending = false);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Đã gửi đăng ký đề tài. Đang chờ duyệt!')),
      );

    Navigator.pop(
      context,
      RegisterResult(
        title: _titleCtrl.text.trim(),
        advisorId: _selectedAdvisor!.id,
        advisorName: _selectedAdvisor!.hoTen,
        overviewFile: _fileCtrl.text.trim().isEmpty
            ? null
            : _fileCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Breakpoint + content width (responsive)
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
      borderRadius: BorderRadius.circular(0),
    );

    final viewmodels = Provider.of<DoAnViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          'Đăng ký đề tài',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '   ',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: StadiumBorder(),
                                ),
                                child: Text(
                                  'Đợt 10/2025',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gap),

                          // GVHD
                          if (viewmodels.isLoadingAdvisors) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ] else if (viewmodels.advisorError != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                viewmodels.advisorError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ] else ...[
                            DropdownSearch<GiangVienHuongDan>(
                              items: viewmodels.advisors,
                              itemAsString: (gv) => gv.hoTen,
                              selectedItem: _selectedAdvisor,
                              onChanged: (v) =>
                                  setState(() => _selectedAdvisor = v),
                              compareFn: (a, b) => a.id == b.id,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Giảng viên hướng dẫn',
                                  hintText: 'Vui lòng chọn giảng viên',
                                  border: border,
                                  enabledBorder: border,
                                  focusedBorder: border.copyWith(
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  isDense: true,
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: const InputDecoration(
                                    hintText: 'Tìm kiếm giảng viên...',
                                  ),
                                ),
                              ),
                              validator: (v) => v == null
                                  ? 'Hãy chọn giảng viên hướng dẫn'
                                  : null,
                            ),
                          ],

                          SizedBox(height: gap),

                          // Tên đề tài
                          TextFormField(
                            controller: _titleCtrl,
                            focusNode: _focusTitle,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _focusDesc.requestFocus(),
                            decoration: InputDecoration(
                              labelText: 'Tên đề tài',
                              hintText:
                                  'Ví dụ: Hệ thống quản lý đồ án tốt nghiệp',
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Hãy nhập tên đề tài'
                                : null,
                          ),

                          SizedBox(height: gap),

                          // Đính kèm tổng quan
                          _AttachFileTile(
                            fileName: _fileCtrl.text.trim().isEmpty
                                ? null
                                : _fileCtrl.text.trim(),
                            onPick: _pickFileName,
                            onClear: _fileCtrl.text.trim().isEmpty
                                ? null
                                : () => setState(_fileCtrl.clear),
                          ),

                          SizedBox(height: gap),

                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _sending ? null : _confirmAndSubmit,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: const Text('Gửi đăng ký'),
                            ),
                          ),
                        ],
                      ),
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
    final fileText = hasFile ? fileName! : 'Chưa có tệp đính kèm (PDF/DOCX)…';

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
