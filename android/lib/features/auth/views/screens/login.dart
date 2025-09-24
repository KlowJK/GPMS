import 'package:GPMS/features/lecturer/views/screens/home_giangvien.dart';
import 'package:GPMS/features/student/views/screens/home_sinhvien.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);
    try {
      await context.read<AuthViewModel>().login(
        _accountCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (!mounted) return;

      // Ví dụ: điều hướng theo vai trò
      final vm = context.read<AuthViewModel>();
      final role = vm.user?.role ?? '';
      if (role.contains('GIANG') || role.contains('TEACHER')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeGiangvien()),
        );
      } else if (role.contains('SINH') || role.contains('STUDENT')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeSinhvien()),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;

    // Bề rộng tối đa của card form
    final maxCardWidth = w >= 1000
        ? 520.0
        : w >= 600
        ? 460.0
        : 420.0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxCardWidth),
                  child: Column(
                    children: [
                      // Header có nền xanh + logo
                      _HeaderHero(),
                      const SizedBox(height: 16),

                      // Form Login trong Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Đăng nhập',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 20),

                                // Tài khoản
                                Text(
                                  'Tài khoản',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _accountCtrl,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Vui lòng nhập tài khoản';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Mật khẩu
                                Text(
                                  'Mật khẩu',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập mật khẩu',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Vui lòng nhập mật khẩu';
                                    if (v.length < 2)
                                      return 'Mật khẩu tối thiểu 6 ký tự';
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _onLogin(),
                                ),

                                const SizedBox(height: 12),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: điều hướng trang quên mật khẩu
                                    },
                                    child: const Text('Quên mật khẩu?'),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Nút đăng nhập full width
                                FilledButton(
                                  onPressed: _loading ? null : _onLogin,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Đăng nhập',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),

                                const SizedBox(height: 12),

                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Gợi ý hỗ trợ
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 600;

    return Container(
      // thanh hero đáp ứng, cao hơn chút ở màn hình rộng
      height: isWide ? 220 : 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 900 : 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: isWide
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: isWide ? 72 : 56,
                  height: isWide ? 72 : 56,

                  child: const Image(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: isWide
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'KHOA CÔNG NGHỆ THÔNG TIN',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
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
