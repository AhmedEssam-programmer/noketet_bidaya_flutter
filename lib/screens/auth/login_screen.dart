import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routeName = 'Login';
  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  static const _lang = 'ar';
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ref
          .read(authControllerProvider.notifier)
          .login(_email.text.trim().toLowerCase(), _password.text);

      if (!mounted) return;
      if (res.success) {
        context.go(HomeScreen.routePath);
      } else {
        _alert(
          _lang == 'ar' ? 'خطأ' : 'Error',
          res.error ?? (_lang == 'ar' ? 'فشل تسجيل الدخول' : 'Login failed'),
        );
      }
    } catch (_) {
      if (!mounted) return;
      _alert(
        _lang == 'ar' ? 'خطأ' : 'Error',
        _lang == 'ar' ? 'حدث خطأ غير متوقع' : 'Unexpected error',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _alert(String title, String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    _lang == 'ar' ? 'تسجيل الدخول' : 'Login',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lang == 'ar'
                        ? 'قم بتسجيل الدخول لحفظ تقدمك'
                        : 'Login to save your progress',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _Input(
                    controller: _email,
                    hint: _lang == 'ar' ? 'البريد الإلكتروني' : 'Email',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_loading,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      final email = (value ?? '').trim();
                      if (email.isEmpty) {
                        return _lang == 'ar'
                            ? 'البريد مطلوب'
                            : 'Email required';
                      }
                      if (!_emailPattern.hasMatch(email)) {
                        return _lang == 'ar'
                            ? 'بريد إلكتروني غير صحيح'
                            : 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  _Input(
                    controller: _password,
                    hint: _lang == 'ar' ? 'كلمة المرور' : 'Password',
                    obscureText: true,
                    enabled: !_loading,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return _lang == 'ar'
                            ? 'كلمة المرور مطلوبة'
                            : 'Password required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              _lang == 'ar' ? 'تسجيل الدخول' : 'Login',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => context.push(RegisterScreen.routePath),
                    child: Text(
                      _lang == 'ar'
                          ? 'ليس لديك حساب؟ سجل الآن'
                          : "Don't have an account? Register",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => context.go(HomeScreen.routePath),
                    child: Text(
                      _lang == 'ar' ? 'تخطي' : 'Skip',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
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

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofillHints: autofillHints,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightGray),
          ),
        ),
      ),
    );
  }
}
