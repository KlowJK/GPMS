import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/core/exception/custom_exception.dart';
import 'package:GPMS/features/auth/viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _emailServerError;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // Trong ForgotPasswordScreen

  Future<void> _onSend() async {
    setState(() {
      _emailServerError = null;
      _sent = false;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await context.read<AuthViewModel>().forgotPassword(
        _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      setState(() => _sent = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã đặt lại mật khẩu đã được gửi đến email của bạn.'),
          backgroundColor: Colors.green,
        ),
      );
    } on CustomException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.errorCode.field == 'email') {
          _emailServerError = e.errorCode.message;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.errorCode.message)));
        }
      });
      _formKey.currentState?.validate();
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
                      _HeaderHero(),
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
                                  'Quên mật khẩu',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nhập email của bạn để nhận mã đặt lại mật khẩu.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 24),

                                // Email field
                                Text(
                                  'Email',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập email của bạn',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Vui lòng nhập email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(v.trim())) {
                                      return 'Email không hợp lệ';
                                    }
                                    if (_emailServerError != null) {
                                      return _emailServerError;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _onSend(),
                                ),

                                const SizedBox(height: 24),

                                // Send Button
                                FilledButton(
                                  onPressed: _loading || _sent ? null : _onSend,
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
                                      : _sent
                                      ? const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'Đã gửi',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Gửi yêu cầu',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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

// === REUSE _HeaderHero FROM LOGIN ===
class _HeaderHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 600;

    return Container(
      height: isWide ? 220 : 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
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
                        'THUY LOI UNIVERSITY',
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
