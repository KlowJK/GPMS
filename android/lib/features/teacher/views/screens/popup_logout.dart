import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xác nhận gửi danh sách đề tài',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CD3)),
        useMaterial3: true,
      ),
      home: const ConfirmSubmitPage(),
    );
  }
}

/// ---------- CÁCH A: Màn xác nhận dạng thẻ, không dùng Positioned ----------
class ConfirmSubmitPage extends StatelessWidget {
  const ConfirmSubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi danh sách đề tài'),
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => showConfirmSubmitDialog(context),
            child: const Text(
              'Mở dialog',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.help_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Bạn có chắc chắn muốn gửi danh sách đề tài hướng dẫn không?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Quay lại
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã huỷ gửi')),
                                );
                              },
                              child: const Text('Quay lại'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                // TODO: gọi API gửi danh sách tại đây
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã gửi danh sách')),
                                );
                              },
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

/// ---------- CÁCH B: Dialog chuẩn Material ----------
Future<void> showConfirmSubmitDialog(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Xác nhận'),
      content: const Text(
        'Bạn có chắc chắn muốn gửi danh sách đề tài hướng dẫn không?',
        textAlign: TextAlign.start,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Quay lại'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );

  if (ok == true) {
    // TODO: gọi API thật sự ở đây
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi danh sách')),
    );
  }
}
