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
        automaticallyImplyLeading: false,
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
                  // small hint about submission count

                  Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.dividerColor.withAlpha(60),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(gap * 1.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // label
                          Text(
                            'URL File đề cương',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: gap),

                          // input
                          TextFormField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.dividerColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.dividerColor.withAlpha(90)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
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

                          // submit button
                          Center(
                            child: SizedBox(
                              width: 220,
                              child: FilledButton(
                                onPressed: (viewModel == null || viewModel.isLoadingLogs)
                                    ? null
                                    : () => _submit(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                                child: viewModel == null
                                    ? const Text(
                                        'Không có dữ liệu (mở từ trang Đồ án)',
                                        textAlign: TextAlign.center,
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
                          ),

                          const SizedBox(height: 14),

                          // info row
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Chấp nhận link PDF. Sau khi nộp, trạng thái sẽ là "Chờ duyệt".',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                  ),
                                ),
                              ],
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
