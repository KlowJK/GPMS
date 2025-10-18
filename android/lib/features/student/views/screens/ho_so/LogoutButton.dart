import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';

import 'package:GPMS/features/auth/views/screens/login.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _confirmAndLogout(BuildContext context) async {
    // 1) Hộp xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true, // luôn root
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 2) Hiện progress chặn
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (progressContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      await context.read<AuthViewModel>().logout();
    } finally {
      // 3) Đóng progress nếu còn mở
      if (context.mounted &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return;

    // 4) Điều hướng: xóa toàn bộ stack -> /login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    // 5) (tuỳ chọn) SnackBar sau khi vào /login 1 frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFBF2D2D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => _confirmAndLogout(context),
        child: const Text('Đăng xuất', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
