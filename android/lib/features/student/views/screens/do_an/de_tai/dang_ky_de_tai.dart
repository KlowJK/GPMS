import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:GPMS/features/student/models/giang_vien_huong_dan.dart';
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';

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
  String? _selectedFilePath;

  final _focusTitle = FocusNode();
  final _focusDesc = FocusNode();

  bool _sending = false;
  bool _showValidation = false;

  // Đổi sang model thay vì String
  GiangVienHuongDan? _selectedAdvisor;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: kIsWeb, // Lấy bytes trên web
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _fileCtrl.text = file.name;
        _selectedFileName = file.name;
        if (kIsWeb) {
          _selectedFileBytes = file.bytes;
          _selectedFilePath = null;
        } else {
          _selectedFilePath = file.path;
          _selectedFileBytes = null;
        }
      });
    }
  }

  Future<void> _confirmAndSubmit() async {
    setState(() => _showValidation = true);
    // Validate trước
    if (!_formKey.currentState!.validate()) {
      if (_titleCtrl.text.trim().isEmpty) {
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
    final vm = Provider.of<DoAnViewModel>(context, listen: false);
    if (_selectedAdvisor == null) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn giảng viên hướng dẫn.')),
        );
      return;
    }
    if (kDebugMode) {
      print(
        '➡️ DangKyDeTai: gvhdId=${_selectedAdvisor!.id}, tenDeTai="${_titleCtrl.text.trim()}", fileName=${_selectedFileName}, filePath=${_selectedFilePath ?? 'null'}, bytes=${_selectedFileBytes?.lengthInBytes ?? 0}',
      );
    }
    final ok = await vm.dangKyDeTai(
      gvhdId: _selectedAdvisor!.id,
      tenDeTai: _titleCtrl.text.trim(),
      filePath: _selectedFilePath ?? '',
      fileBytes: _selectedFileBytes,
      fileName: _selectedFileName,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
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
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(vm.deTaiError ?? 'Đăng ký đề tài thất bại.')),
        );
    }
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

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Viền mềm + radius nhẹ, màu dịu để hòa nền
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: theme.dividerColor.withOpacity(.5)),
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
                  elevation: 0, // không đổ bóng để hòa nền
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    // Bỏ viền của form: không set side
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _showValidation
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: gap),

                          // ========== GVHD ==========
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
                            const _FieldLabel('Giảng viên hướng dẫn:'),
                            FormField<GiangVienHuongDan>(
                              validator: (v) => _selectedAdvisor == null
                                  ? 'Vui lòng chọn giảng viên hướng dẫn'
                                  : null,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              builder: (state) {
                                return Autocomplete<GiangVienHuongDan>(
                                  displayStringForOption: (gv) => gv.hoTen,
                                  optionsBuilder: (TextEditingValue text) {
                                    final q = text.text.trim().toLowerCase();
                                    if (q.isEmpty) return viewmodels.advisors;
                                    return viewmodels.advisors.where(
                                      (gv) =>
                                          gv.hoTen.toLowerCase().contains(q),
                                    );
                                  },
                                  onSelected: (gv) {
                                    setState(() => _selectedAdvisor = gv);
                                    state.didChange(gv);
                                  },
                                  fieldViewBuilder:
                                      (
                                        context,
                                        controller,
                                        focusNode,
                                        onFieldSubmitted,
                                      ) {
                                        if (_selectedAdvisor != null &&
                                            controller.text.isEmpty) {
                                          controller.text =
                                              _selectedAdvisor!.hoTen;
                                        }
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Chọn giảng viên hướng dẫn',
                                            filled: true,
                                            fillColor: cs.surfaceVariant
                                                .withOpacity(.35),
                                            border: border,
                                            enabledBorder: border,
                                            focusedBorder: border.copyWith(
                                              borderSide: BorderSide(
                                                color: cs.primary,
                                              ),
                                            ),
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                            errorText: state.errorText,
                                          ),
                                          onChanged: (_) {
                                            if (_selectedAdvisor != null) {
                                              setState(
                                                () => _selectedAdvisor = null,
                                              );
                                              state.didChange(null);
                                            }
                                          },
                                        );
                                      },
                                  optionsViewBuilder:
                                      (context, onSelected, options) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            elevation: 4,

                                            color: const Color(
                                              0xFFDCDEE4,
                                            ), // chỉnh màu nền background
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxHeight: 320,
                                                minWidth: 260,
                                              ),
                                              child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                itemCount: options.length,
                                                itemBuilder: (_, index) {
                                                  final gv = options.elementAt(
                                                    index,
                                                  );
                                                  return ListTile(
                                                    dense: true,
                                                    title: Text(gv.hoTen),
                                                    onTap: () => onSelected(gv),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                );
                              },
                            ),
                          ],

                          SizedBox(height: gap),

                          // ========== Tên đề tài ==========
                          const _FieldLabel('Tên đề tài:'),
                          TextFormField(
                            controller: _titleCtrl,
                            focusNode: _focusTitle,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => _focusDesc.requestFocus(),
                            decoration: InputDecoration(
                              hintText: 'Vui lòng nhập tên đề tài',
                              filled: true,
                              fillColor: cs.surfaceVariant.withOpacity(.35),
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: BorderSide(color: cs.primary),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Hãy nhập tên đề tài'
                                : null,
                          ),

                          SizedBox(height: gap),

                          const _FieldLabel('File tổng quan:'),
                          FormField<String>(
                            autovalidateMode: AutovalidateMode.disabled,
                            validator: (_) =>
                                (_selectedFileName == null ||
                                    _selectedFileName!.isEmpty)
                                ? 'Hãy đính kèm file tổng quan'
                                : null,
                            builder: (state) {
                              final cs = Theme.of(context).colorScheme;
                              final divider = Theme.of(
                                context,
                              ).dividerColor.withOpacity(.6);

                              // Chỉ coi là lỗi sau khi người dùng bấm "Gửi đăng ký"
                              final bool isError =
                                  _showValidation &&
                                  (_selectedFileName == null ||
                                      _selectedFileName!.isEmpty);

                              // ===== Trạng thái CHƯA CHỌN FILE: drop-zone =====
                              if (_selectedFileName == null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await _pickFileName();
                                        state.didChange(
                                          _selectedFileName ?? '',
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 88,
                                        decoration: BoxDecoration(
                                          color: cs.surfaceVariant.withOpacity(
                                            .35,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isError ? cs.error : divider,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 28,
                                                color: isError
                                                    ? cs.error
                                                    : null,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Chọn tệp tại đây',
                                                style: TextStyle(
                                                  color: isError
                                                      ? cs.error
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          'Hãy đính kèm file tổng quan',
                                          style: TextStyle(color: cs.error),
                                        ),
                                      ),
                                  ],
                                );
                              }

                              // ===== Trạng thái ĐÃ CHỌN FILE: hiển thị link + nút xóa =====
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            // tuỳ bạn: mở preview nếu muốn
                                          },
                                          child: Text(
                                            _selectedFileName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: cs.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Xóa tệp',
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            _fileCtrl.clear();
                                            _selectedFileName = null;
                                            _selectedFilePath = null;
                                            _selectedFileBytes = null;
                                          });
                                          state.didChange(
                                            '',
                                          ); // quay về trạng thái chưa chọn
                                        },
                                      ),
                                    ],
                                  ),
                                  // đã có file thì không hiển thị lỗi
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // dart
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 180),
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _sending ? null : _confirmAndSubmit,
                                child: _sending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Gửi đăng ký'),
                              ),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
