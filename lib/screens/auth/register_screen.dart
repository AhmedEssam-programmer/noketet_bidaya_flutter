import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = 'Register';
  static const routePath = '/register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  static const _lang = 'ar';
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ref
          .read(authControllerProvider.notifier)
          .register(_email.text.trim().toLowerCase(), _password.text);

      if (!mounted) return;
      if (res.success) {
        _alert(
          _lang == 'ar' ? 'نجاح' : 'Success',
          _lang == 'ar'
              ? 'تم إنشاء الحساب بنجاح!'
              : 'Account created successfully!',
          onOk: () => context.go(HomeScreen.routePath),
        );
      } else {
        _alert(
          _lang == 'ar' ? 'خطأ' : 'Error',
          res.error ??
              (_lang == 'ar' ? 'فشل إنشاء الحساب' : 'Registration failed'),
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

  void _alert(String title, String message, {VoidCallback? onOk}) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOk?.call();
            },
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
                    _lang == 'ar' ? 'إنشاء حساب' : 'Create Account',
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
                        ? 'سجل لحفظ تقدمك عبر الأجهزة'
                        : 'Register to save your progress across devices',
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
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) {
                      final password = value ?? '';
                      if (password.isEmpty) {
                        return _lang == 'ar'
                            ? 'كلمة المرور مطلوبة'
                            : 'Password required';
                      }
                      if (password.length < 8) {
                        return _lang == 'ar'
                            ? 'كلمة المرور 8 أحرف على الأقل'
                            : 'Use at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  _Input(
                    controller: _confirm,
                    hint: _lang == 'ar'
                        ? 'تأكيد كلمة المرور'
                        : 'Confirm Password',
                    obscureText: true,
                    enabled: !_loading,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) {
                      if ((value ?? '') != _password.text) {
                        return _lang == 'ar'
                            ? 'كلمتا المرور غير متطابقتين'
                            : 'Passwords do not match';
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
                      onPressed: _loading ? null : _register,
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
                              _lang == 'ar' ? 'إنشاء حساب' : 'Create Account',
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
                        : () => context.push(LoginScreen.routePath),
                    child: Text(
                      _lang == 'ar'
                          ? 'لديك حساب بالفعل؟ سجل الدخول'
                          : 'Already have an account? Login',
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
