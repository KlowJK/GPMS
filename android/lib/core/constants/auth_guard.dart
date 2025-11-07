import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/screens/trang_chu/trang_chu_giang_vien.dart';
import 'package:GPMS/features/student/views/screens/trang_chu/trang_chu_sinh_vien.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key, required this.guestChild});

  /// Widget hiển thị khi chưa đăng nhập (guest)
  final Widget guestChild;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, _) {
        // Đã đăng nhập - redirect về trang tương ứng
        if (authVm.isLoggedIn && authVm.user != null && !_hasNavigated) {
          // Schedule navigation after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasNavigated) {
              _hasNavigated = true;
              _navigateToUserHome(context, authVm.user!.role);
            }
          });

          // Show loading while navigating
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Chưa đăng nhập - show guest page
        return widget.guestChild;
      },
    );
  }

  /// Navigate to appropriate home based on role
  void _navigateToUserHome(BuildContext context, String role) {
    if (!context.mounted) return;

    Widget destination;

    // Determine destination based on role
    if (_isLecturerRole(role)) {
      destination = const TrangChuGiangVien();
    } else if (_isStudentRole(role)) {
      destination = const TrangChuSinhVien();
    } else {
      // Unknown role - stay on guest page
      _hasNavigated = false; // Reset flag
      return;
    }

    // Navigate and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  /// Check if role is lecturer/teacher
  bool _isLecturerRole(String role) {
    final roleLower = role.toLowerCase();
    return roleLower.contains('giang') ||
        roleLower.contains('teacher') ||
        roleLower.contains('quan') ||
        roleLower.contains('truong');
  }

  /// Check if role is student
  bool _isStudentRole(String role) {
    final roleLower = role.toLowerCase();
    return roleLower.contains('sinh') || roleLower.contains('student');
  }
}

/// Wrapper cho LoginScreen với AuthGuard
class LoginScreenGuard extends StatelessWidget {
  const LoginScreenGuard({super.key, required this.loginScreen});

  final Widget loginScreen;

  @override
  Widget build(BuildContext context) {
    return AuthGuard(guestChild: loginScreen);
  }
}

/// Wrapper cho HomeGuest với AuthGuard
class HomeGuestGuard extends StatelessWidget {
  const HomeGuestGuard({super.key, required this.homeGuest});

  final Widget homeGuest;

  @override
  Widget build(BuildContext context) {
    return AuthGuard(guestChild: homeGuest);
  }
}
