import 'package:flutter/material.dart';

void main() => runApp(const FigmaToCodeApp());

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhận xét',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const CommentPage(),
    );
  }
}

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nhận xét')),
      );
      return;
    }
    // TODO: gọi API lưu nhận xét ở đây
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi nhận xét')),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận xét'),
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Đưa ra nhận xét...',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).hintColor.withOpacity(0.9)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Nhập nội dung nhận xét',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: _submit,
                              child: const Text('Xác nhận'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
