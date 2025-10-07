import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class NopDeCuongScreen extends StatefulWidget {
  const NopDeCuongScreen({super.key, required this.submissionCount});

  final int submissionCount;

  @override
  State<NopDeCuongScreen> createState() => _NopDeCuongScreenState();
}

class _NopDeCuongScreenState extends State<NopDeCuongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fileCtrl = TextEditingController();

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedFilePath;

  bool _sending = false;

  @override
  void dispose() {
    _fileCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // Lấy bytes trên web
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
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

  Future<void> _submit() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn file đề cương PDF.')),
      );
      return;
    }

    setState(() => _sending = true);
    // TODO: Call ViewModel to submit
    await Future.delayed(const Duration(seconds: 2)); // Giả lập gọi API
    setState(() => _sending = false);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Nộp đề cương thành công.')),
      );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
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

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Nộp đề cương', style: TextStyle(color: Colors.white)),
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
                  elevation: 1,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(gap * 1.5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Lần nộp:'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 50,
                                height: 40,
                                child: TextFormField(
                                  initialValue: widget.submissionCount.toString(),
                                  enabled: false,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: theme.dividerColor.withOpacity(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor.withOpacity(0.3),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gap * 1.5),
                          const Text('File đề cương (chỉ PDF):'),
                          SizedBox(height: gap),
                          _buildFilePicker(),
                          SizedBox(height: gap * 2),
                          Center(
                            child: FilledButton(
                              onPressed: _sending ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 14,
                                ),
                              ),
                              child: _sending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Nộp đề cương'),
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

  Widget _buildFilePicker() {
    if (_selectedFileName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.shade600),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade800, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedFileName!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.green.shade900),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  _selectedFileName = null;
                  _selectedFileBytes = null;
                  _selectedFilePath = null;
                });
              },
            )
          ],
        ),
      );
    }

    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 50,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Kéo & thả tệp tại đây',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
