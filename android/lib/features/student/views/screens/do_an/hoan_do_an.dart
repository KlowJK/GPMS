import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../auth/services/auth_service.dart';
import '../../../models/de_nghi_hoan_model.dart';
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

  String? _selectedFileName;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;

  @override
  void dispose() {
    _lyDoCtrl.dispose();
    _focusLyDo.dispose();
    super.dispose();
  }

  Future<void> _pickFileName() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: kIsWeb,
        withReadStream: !kIsWeb,
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

    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận gửi'),
            content: const Text('Bạn có chắc chắn muốn gửi đề nghị này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Gửi'),
              ),
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
    await viewModel.guiDeNghiHoan(
      lyDo: _lyDoCtrl.text.trim(),
      filePath: _selectedFilePath,
      fileBytes: _selectedFileBytes,
      fileName: _selectedFileName,
    );

    if (!mounted) return;

    if (viewModel.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đề nghị thành công.')),
      );
      _lyDoCtrl.clear();
      setState(() {
        _selectedFileName = null;
        _selectedFilePath = null;
        _selectedFileBytes = null;
      });
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${viewModel.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double maxContentWidth = w >= 1200
        ? 1000
        : (w >= 900 ? 840 : (w >= 600 ? 560 : w));
    final double pad = w >= 900 ? 24 : 16;
    final double gap = w >= 900 ? 16 : 12;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    final viewModel = context.watch<HoanDoAnViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          'Đề nghị hoãn đồ án',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Lý do hoãn:'),
                          TextFormField(
                            controller: _lyDoCtrl,
                            focusNode: _focusLyDo,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Trình bày lý do của bạn…',
                              border: border,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập lý do'
                                : null,
                          ),
                          SizedBox(height: gap),
                          const _FieldLabel('File minh chứng (tùy chọn):'),
                          _FilePickerWidget(
                            fileName: _selectedFileName,
                            onPick: _pickFileName,
                            onClear: () {
                              setState(() {
                                _selectedFileName = null;
                                _selectedFilePath = null;
                                _selectedFileBytes = null;
                              });
                            },
                          ),
                          SizedBox(height: gap * 1.5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: viewModel.isLoading
                                  ? null
                                  : _confirmAndSend,
                              icon: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_outlined),
                              label: const Text('Gửi đề nghị'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: gap * 2),
                const Text(
                  'Lịch sử đề nghị',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: gap),
                _buildHistoryList(viewModel, gap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(HoanDoAnViewModel vm, double gap) {
    if (vm.isFetchingList && vm.deNghiList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.fetchListError != null && vm.deNghiList.isEmpty) {
      return Center(child: Text('Lỗi tải lịch sử: ${vm.fetchListError}'));
    }

    if (vm.deNghiList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text('Chưa có đề nghị nào được gửi.'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.deNghiList.length,
      separatorBuilder: (_, __) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        final deNghi = vm.deNghiList[index];
        return _DeNghiHistoryCard(deNghi: deNghi);
      },
    );
  }
}

class _FilePickerWidget extends StatelessWidget {
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _FilePickerWidget({
    this.fileName,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor.withOpacity(.6);

    if (fileName == null) {
      return InkWell(
        onTap: onPick,
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

    return Container(
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
              fileName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Xóa tệp',
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ],
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
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DeNghiHistoryCard extends StatelessWidget {
  final DeNghiHoanModel deNghi;

  const _DeNghiHistoryCard({required this.deNghi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Color getStatusColor(TrangThaiDeNghi status) {
      switch (status) {
        case TrangThaiDeNghi.DA_DUYET:
          return Colors.green;
        case TrangThaiDeNghi.TU_CHOI:
          return Colors.red;
        case TrangThaiDeNghi.CHO_DUYET:
        default:
          return Colors.orange;
      }
    }

    String getStatusText(TrangThaiDeNghi status) {
      switch (status) {
        case TrangThaiDeNghi.CHO_DUYET:
          return 'Chờ duyệt';
        case TrangThaiDeNghi.DA_DUYET:
          return 'Đã duyệt';
        case TrangThaiDeNghi.TU_CHOI:
          return 'Từ chối';
        default:
          return 'Không rõ';
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày gửi: ${DateFormat('dd/MM/yyyy').format(deNghi.requestedAt)}',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(deNghi.trangThai).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getStatusText(deNghi.trangThai),
                    style: textTheme.labelSmall?.copyWith(
                      color: getStatusColor(deNghi.trangThai),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _InfoRow(label: 'Lý do:', value: deNghi.lyDo),
            if (deNghi.ghiChuQuyetDinh != null &&
                deNghi.ghiChuQuyetDinh!.isNotEmpty)
              _InfoRow(label: 'Phản hồi:', value: deNghi.ghiChuQuyetDinh!),
            if (deNghi.minhChungUrl != null && deNghi.minhChungUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () async {
                    final uri = Uri.tryParse(deNghi.minhChungUrl!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.link, color: Colors.blue, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Xem file minh chứng',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
