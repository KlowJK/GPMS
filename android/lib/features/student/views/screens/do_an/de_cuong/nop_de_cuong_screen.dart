import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/student/viewmodels/do_an_viewmodel.dart';

class NopDeCuongScreen extends StatelessWidget {
  const NopDeCuongScreen({super.key, required this.submissionCount});

  final int submissionCount;

  @override
  Widget build(BuildContext context) {
    return _NopDeCuongView(submissionCount: submissionCount);
  }
}

class _NopDeCuongView extends StatefulWidget {
  const _NopDeCuongView({required this.submissionCount});

  final int submissionCount;

  @override
  State<_NopDeCuongView> createState() => _NopDeCuongViewState();
}

class _NopDeCuongViewState extends State<_NopDeCuongView> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Try to obtain the DoAnViewModel; if not available, show a friendly message
    DoAnViewModel? viewModel;
    try {
      viewModel = Provider.of<DoAnViewModel>(context, listen: false);
    } catch (e) {
      // Provider not found in this BuildContext
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Không tìm thấy dữ liệu. Vui lòng mở màn này từ trang Đồ án.',
            ),
          ),
        );
      return;
    }

    final success = await viewModel.nopDeCuong(fileUrl: _urlController.text);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nộp đề cương thành công!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(viewModel.logsError ?? 'Nộp đề cương thất bại.'),
            ),
          );
      }
    }
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
    // Try to obtain DoAnViewModel; if not found, we'll show a helpful message
    DoAnViewModel? viewModel;
    try {
      viewModel = context.watch<DoAnViewModel>();
    } catch (_) {
      viewModel = null;
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          'Nộp đề cương',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(pad, gap, pad, pad + 8),
                children: [
                  Card(
                    elevation: 1,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(gap * 1.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: gap * 1.5),
                          const Text('URL File đề cương:'),
                          SizedBox(height: gap),
                          TextFormField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'https://example.com/file.pdf',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập URL file đề cương.';
                              }
                              final uri = Uri.tryParse(value);
                              if (uri == null || !uri.isAbsolute) {
                                return 'URL không hợp lệ.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: gap * 2),
                          Center(
                            child: FilledButton(
                              onPressed:
                                  (viewModel == null || viewModel.isLoadingLogs)
                                  ? null
                                  : () => _submit(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 14,
                                ),
                              ),
                              child: viewModel == null
                                  ? const Text(
                                      'Không có dữ liệu (mở từ trang Đồ án)',
                                    )
                                  : (viewModel.isLoadingLogs
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Nộp đề cương')),
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
