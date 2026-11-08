import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/lessons.dart';
import '../../services/speech_service.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';
import 'lesson_screen.dart';

class LevelScreen extends ConsumerStatefulWidget {
  const LevelScreen({super.key});

  static const routeName = 'Learning';
  static const routePath = '/learning';

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  static const _levels = [
    (
      id: 'sounds',
      icon: Icons.graphic_eq,
      title: 'الأصوات',
      titleEn: 'Sounds',
      desc: 'تعلم أصوات الحروف العربية',
      descEn: 'Learn Arabic letter sounds',
      bg: Color(0xFFE8F5E9),
    ),
    (
      id: 'letters',
      icon: Icons.edit,
      title: 'الحروف',
      titleEn: 'Letters',
      desc: 'تعلم قراءة وكتابة الحروف',
      descEn: 'Learn to read and write letters',
      bg: Color(0xFFE8F5E9),
    ),
    (
      id: 'words',
      icon: Icons.menu_book,
      title: 'الكلمات',
      titleEn: 'Words',
      desc: 'تعلم الكلمات الشائعة',
      descEn: 'Learn common words',
      bg: Color(0xFFE8F5E9),
    ),
    (
      id: 'sentences',
      icon: Icons.chat_bubble_outline,
      title: 'الجمل',
      titleEn: 'Sentences',
      desc: 'تعلم تكوين الجمل',
      descEn: 'Learn sentence formation',
      bg: Color(0xFFE8F5E9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(userControllerProvider).settings;
      final isAr = settings.language.name == 'ar';
      if (settings.voiceEnabled) {
        speechService.speak(
          isAr
              ? 'اختر المستوى الذي تريد تعلمه'
              : 'Choose the level you want to learn',
        );
      }
    });
  }

  int _completedForLevel(UserState user, String levelId) {
    return switch (levelId) {
      'sounds' => user.progress.soundsCompleted.length,
      'letters' => user.progress.lettersCompleted.length,
      'words' => user.progress.wordsCompleted.length,
      'sentences' => user.progress.sentencesCompleted.length,
      _ => 0,
    };
  }

  int _totalForLevel(String levelId) {
    return switch (levelId) {
      'sounds' => soundsLessons.length,
      'letters' => letterWritingLessons.length,
      'words' => wordsLessons.length,
      'sentences' => sentencesLessons.length,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final isAr = user.settings.language.name == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'اختر المستوى' : 'Choose Level',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'مستواك في التعلم',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final level in _levels) ...[
                    _LevelCard(
                      icon: level.icon,
                      title: isAr ? level.title : level.titleEn,
                      desc: isAr ? level.desc : level.descEn,
                      completed: _completedForLevel(user, level.id),
                      total: _totalForLevel(level.id),
                      onTap: () async {
                        if (user.settings.voiceEnabled) {
                          await speechService.stop();
                        }
                        if (!context.mounted) return;
                        context.push(
                          LessonScreen.path(level: level.id, lessonId: '0'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context.pop(),
                  child: Text(
                    isAr ? 'رجوع' : 'Back',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.completed,
    required this.total,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String desc;
  final int completed;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0
        ? (completed / total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 6,
                      color: const Color(0xFFE0E0E0),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: pct,
                        child: Container(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed / $total',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: const Text(
                '▶',
                style: TextStyle(color: AppColors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
