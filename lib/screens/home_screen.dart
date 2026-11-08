import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/lessons.dart';
import '../data/word_game_levels.dart';
import '../services/speech_service.dart';
import '../state/auth_controller.dart';
import '../state/user_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/guide_video_dialog.dart';
import 'auth/login_screen.dart';
import 'games/word_game_play_screen.dart';
import 'learning/level_screen.dart';
import 'settings/settings_screen.dart';
import 'shopping/cart_screen.dart';
import 'shopping/shopping_screen.dart';
import 'shopping/chat_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'Home';
  static const routePath = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), () {
      _speakMenu();
    });
  }

  Future<void> _speakMenu() async {
    final userState = ref.read(userControllerProvider);
    if (!userState.settings.voiceEnabled) return;

    final lang = userState.settings.language.name;
    final text = lang == 'ar'
        ? 'اختر مما يلي: تعلم أو تسوق'
        : 'Choose: Learn or Shop';

    await speechService.speak(text);
  }

  Future<void> _handleButtonPress(VoidCallback callback, String text) async {
    await speechService.stop();
    final settings = ref.read(userControllerProvider).settings;
    if (settings.voiceEnabled) {
      unawaited(speechService.speak(text));
    }
    callback();
  }

  void _openWordGames(UserState user) {
    final level = firstPlayableWordGameLevel(
      languageCode: user.settings.language.name,
      completedLevelIds: user.progress.wordGameCompleted,
    );
    context.push(WordGamePlayScreen.path(levelId: level.id));
  }

  Future<void> _confirmLogout(String lang) async {
    final isAr = lang == 'ar';
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تسجيل الخروج' : 'Logout'),
        content: Text(
          isAr ? 'هل تريد تسجيل الخروج؟' : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isAr ? 'نعم' : 'Yes'),
          ),
        ],
      ),
    );

    if (res != true) return;

    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr ? 'تم تسجيل الخروج بنجاح' : 'Logged out successfully',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final auth = ref.watch(authControllerProvider);

    final lang = user.settings.language.name;
    final isAr = lang == 'ar';

    final totalCompleted =
        user.progress.soundsCompleted.length +
        user.progress.lettersCompleted.length +
        user.progress.wordsCompleted.length +
        user.progress.sentencesCompleted.length;
    final totalLessons =
        soundsLessons.length +
        letterWritingLessons.length +
        wordsLessons.length +
        sentencesLessons.length;
    final progressPercent = totalLessons > 0
        ? ((totalCompleted / totalLessons) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  Column(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/Transparent Logo.png'),
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      if (auth.isAuthenticated && auth.user != null) ...[
                        Text(
                          auth.user!.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (user.isSyncing)
                          Text(
                            isAr ? 'جار المزامنة...' : 'Syncing...',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onPressed: () => _confirmLogout(lang),
                            child: Text(
                              isAr ? 'خروج' : 'Logout',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        InkWell(
                          onTap: () => context.push(LoginScreen.routePath),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAr
                                  ? 'سجل الدخول لحفظ تقدمك'
                                  : 'Login to save your progress',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'تقدمك' : 'Your Progress',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '$progressPercent%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 12,
                            color: const Color(0xFFE0E0E0),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (progressPercent / 100).clamp(0, 1),
                              child: Container(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalCompleted / $totalLessons ${isAr ? 'درس مكتمل' : 'lessons completed'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () => _handleButtonPress(
                      () => _openWordGames(user),
                      isAr ? 'ألعاب الكلمات' : 'Word Games',
                    ),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.extension,
                              color: AppColors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'ألعاب الكلمات' : 'Word Games',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr
                                      ? 'قراءة، كتابة، إملاء، ومكافآت'
                                      : 'Reading, spelling, focus, and rewards',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xDDFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _handleButtonPress(
                            () => context.push(LevelScreen.routePath),
                            isAr ? 'تعلم' : 'Learn',
                          ),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.menu_book,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isAr ? 'تعلم' : 'Learn',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr
                                      ? 'الأصوات، الحروف، الكلمات'
                                      : 'Sounds, Letters, Words',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xCCFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _handleButtonPress(
                            () => context.push(ShoppingScreen.routePath),
                            isAr ? 'تسوق' : 'Shop',
                          ),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.shopping_cart,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isAr ? 'تسوق' : 'Shop',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr
                                      ? 'تسوق مع التعلم'
                                      : 'Shop while learning',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xCCFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '${user.progress.totalStars}',
                          label: isAr ? 'نجمة' : 'Stars',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          value: '${user.progress.soundsCompleted.length}',
                          label: isAr ? 'أصوات' : 'Sounds',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          value: '${user.progress.wordsCompleted.length}',
                          label: isAr ? 'كلمات' : 'Words',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              child: GuideVideoButton(
                isAr: isAr,
                onTap: () => GuideVideoDialog.show(context, isAr: isAr),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomButton(
                      icon: Icons.shopping_cart,
                      label: isAr ? 'السلة' : 'Cart',
                      badge: user.cart.isNotEmpty
                          ? '${user.cart.length}'
                          : null,
                      onTap: () => context.push(CartScreen.routePath),
                    ),
                    _BottomButton(
                      icon: Icons.chat_bubble_outline,
                      label: isAr ? 'المساعد' : 'Chat',
                      onTap: () => context.push(ChatPage.routePath),
                    ),
                    _BottomButton(
                      icon: Icons.settings,
                      label: isAr ? 'إعدادات' : 'Settings',
                      onTap: () => context.push(SettingsScreen.routePath),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: 20,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
