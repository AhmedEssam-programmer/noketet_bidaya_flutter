import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/speech_service.dart';
import '../state/user_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/voice_button.dart';
import 'home_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  static const routeName = 'Welcome';
  static const routePath = '/welcome';

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const _welcomeText =
      'مرحباً بك في نقطة البداية! هنا ستتعلم القراءة والكتابة وتسوق بسهولة.';

  bool _isSpeaking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), () {
      _handleWelcome();
    });
  }

  Future<void> _handleWelcome() async {
    final settings = ref.read(userControllerProvider).settings;
    if (!settings.voiceEnabled) return;
    setState(() => _isSpeaking = true);
    await speechService.speak(
      _welcomeText,
      onDone: () {
        if (mounted) setState(() => _isSpeaking = false);
      },
    );
  }

  Future<void> _handleContinue() async {
    await speechService.stop();
    if (!mounted) return;
    context.go(HomeScreen.routePath);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final voiceEnabled = user.settings.voiceEnabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.waving_hand,
                  color: AppColors.secondary,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'مرحباً بك!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'هنا ستتعلم\nالقراءة والكتابة\nوتسوق بسهولة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.text,
                    height: 40 / 24,
                  ),
                ),
                const SizedBox(height: 40),
                LargeVoiceButton(
                  onPressed: _handleContinue,
                  icon: Icons.arrow_forward,
                  label: 'ابدأ',
                ),
                if (voiceEnabled) ...[
                  const SizedBox(height: 30),
                  Text(
                    _isSpeaking ? '...' : 'استمع ثم اضغط continue',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
