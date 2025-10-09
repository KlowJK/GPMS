import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../auth/services/auth_service.dart';
import '../../../services/hoan_do_an_service.dart';
import '../../../viewmodels/hoan_do_an_viewmodel.dart';

class HoanDoAn extends StatelessWidget {
  const HoanDoAn({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HoanDoAnViewModel(
        service: HoanDoAnService(baseUrl: AuthService.baseUrl),
      ),
      child: const _HoanDoAnView(),
    );
  }
}

class _HoanDoAnView extends StatefulWidget {
  const _HoanDoAnView();
  @override
  State<_HoanDoAnView> createState() => _HoanDoAnViewState();
}

class _HoanDoAnViewState extends State<_HoanDoAnView> {
  final _formKey = GlobalKey<FormState>();
  final _lyDoCtrl = TextEditingController();
  final _focusLyDo = FocusNode();

  // New state variables for the file picker
  String? _selectedFileName;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;

  @override
  void dispose() {
    _lyDoCtrl.dispose();
    _focusLyDo.dispose();
    super.dispose();
  }

  // New file picking logic from dang_ky_de_tai.dart
  Future<void> _pickFileName() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
        withData: kIsWeb, // Fetch bytes on web
        withReadStream: !kIsWeb, // Use stream on mobile
      );
      if (result != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          if (kIsWeb) {
            _selectedFileBytes = result.files.single.bytes;
          } else {
            _selectedFilePath = result.files.single.path;
          }
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _confirmAndSend() async {
    if (!_formKey.currentState!.validate()) {
      _focusLyDo.requestFocus();
      return;
    }

    final ok = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: CircleAvatar(radius: 22, backgroundColor: const Color(0xFF2F7CD3), child: const Icon(Icons.help_outline, color: Colors.white)),
            title: const Text('Bạn có chắc chắn muốn gửi đề nghị hoãn đồ án không?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Quay lại')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận')),
            ],
          ),
        ) ??
        false;

    if (ok) {
      await _guiDeNghi();
    }
  }

  Future<void> _guiDeNghi() async {
    final viewModel = context.read<HoanDoAnViewModel>();
    final lyDo = _lyDoCtrl.text.trim();

    // Pass new file data to the view model
    // Note: The ViewModel and Service must be updated to handle these parameters
    await viewModel.guiDeNghiHoan(
      lyDo: lyDo,
      filePath: _selectedFilePath,
      fileBytes: _selectedFileBytes,
      fileName: _selectedFileName,
    );

    if (!mounted) return;

    if (viewModel.isSuccess) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Đã gửi đề nghị hoãn. Vui lòng chờ duyệt!')),
        );
      Navigator.pop(context, true); // Pop and return success
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text('Lỗi: ${viewModel.error}')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxContentWidth = w >= 1200 ? 1000 : (w >= 900 ? 840 : (w >= 600 ? 560 : w));
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );
    
    final isLoading = context.watch<HoanDoAnViewModel>().isLoading;

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
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Lý do hoãn:'),
                          TextFormField(
                            controller: _lyDoCtrl,
                            focusNode: _focusLyDo,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Nhập lý do hoãn…',
                              border: border,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Hãy nhập lý do hoãn' : null,
                          ),
                          SizedBox(height: gap),

                          // New File Picker Widget
                          const _FieldLabel('File minh chứng (tùy chọn):'),
                          FormField<String>(
                            builder: (state) {
                              final cs = Theme.of(context).colorScheme;
                              final divider = Theme.of(context).dividerColor.withOpacity(.6);

                              if (_selectedFileName == null) {
                                // Drop-zone state
                                return InkWell(
                                  onTap: _pickFileName,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 88,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: cs.surfaceVariant.withOpacity(.35),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: divider),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.cloud_upload_outlined, size: 28),
                                          SizedBox(height: 6),
                                          Text('Chọn tệp tại đây'),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                              // Selected file state
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: divider),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.description_outlined, color: Colors.blue, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _selectedFileName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: cs.primary, decoration: TextDecoration.underline),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Xóa tệp',
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              _selectedFileName = null;
                                              _selectedFilePath = null;
                                              _selectedFileBytes = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: gap),
                          const Divider(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : _confirmAndSend,
                              icon: isLoading
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.send),
                              label: const Text('Gửi đề nghị'),
                            ),
                          ),
                        ],
                      ),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
