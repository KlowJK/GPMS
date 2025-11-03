import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:GPMS/features/auth/views/widgets/header_hero.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await context.read<AuthViewModel>().resetPassword(
        token: _tokenCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.'),
          backgroundColor: Colors.green,
        ),
      );

      // Quay về trang đăng nhập
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/login');
    } on CustomException catch (e) {
      setState(() {
        _serverError = e.errorCode.message;
      });
      _formKey.currentState?.validate();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
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
                      HeaderHero(),
                      const SizedBox(height: 16),
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
                                  'Đặt lại mật khẩu',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nhập mã từ email và mật khẩu mới.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 24),

                                // Token field
                                Text(
                                  'Mã',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _tokenCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Dán mã từ email',
                                    prefixIcon: const Icon(
                                      Icons.vpn_key_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Vui lòng nhập mã token';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Mật khẩu mới
                                Text(
                                  'Mật khẩu mới',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    hintText: 'Ít nhất 6 ký tự',
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
                                    if (v.length < 6)
                                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                                    if (_serverError != null)
                                      return _serverError;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Xác nhận
                                Text(
                                  'Xác nhận mật khẩu',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmCtrl,
                                  obscureText: _obscureConfirm,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập lại mật khẩu',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v != _passwordCtrl.text)
                                      return 'Mật khẩu không khớp';
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _onReset(),
                                ),
                                const SizedBox(height: 24),

                                // Nút gửi
                                FilledButton(
                                  onPressed: _loading ? null : _onReset,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
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
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Đặt lại mật khẩu',
                                          style: TextStyle(fontSize: 16),
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
            );
          },
        ),
      ),
    );
  }
}
