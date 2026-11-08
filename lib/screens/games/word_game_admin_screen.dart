import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/word_game_levels.dart';
import '../../models/word_game.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';

class WordGameAdminScreen extends ConsumerWidget {
  const WordGameAdminScreen({super.key});

  static const routeName = 'WordGameAdmin';
  static const routePath = '/games/admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final isAr = user.settings.language.name == 'ar';
    final progress = user.progress;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'لوحة تحكم الألعاب' : 'Game Admin Dashboard',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr
                          ? 'إدارة المستويات والمكافآت ومتابعة تقدم المستخدمين'
                          : 'Manage levels, rewards, hints, and learning analytics',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: isAr ? 'مراحل مكتملة' : 'Completed',
                            value:
                                '${progress.wordGameCompleted.length}/${wordGameLevels.length}',
                            icon: Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            label: isAr ? 'تلميحات مستخدمة' : 'Hints Used',
                            value: '${progress.wordGameHintsUsed}',
                            icon: Icons.lightbulb,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: isAr ? 'العملات' : 'Coins',
                            value: '${progress.wordGameCoins}',
                            icon: Icons.monetization_on,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            label: isAr ? 'السلسلة' : 'Streak',
                            value: '${progress.wordGameStreak}',
                            icon: Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _AdminActionPanel(isAr: isAr),
                    const SizedBox(height: 20),
                    Text(
                      isAr ? 'المستويات' : 'Levels',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final level in wordGameLevels) ...[
                      _AdminLevelCard(
                        level: level,
                        isAr: isAr,
                        completed: progress.wordGameCompleted.contains(
                          level.id,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SizedBox(
                  height: 54,
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
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
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

class _AdminActionPanel extends StatelessWidget {
  const _AdminActionPanel({required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'أدوات الإدارة' : 'Admin Tools',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(
                icon: Icons.add,
                label: isAr ? 'إضافة مستوى' : 'Add Level',
              ),
              _ActionChip(
                icon: Icons.category,
                label: isAr ? 'الكلمات والفئات' : 'Words & Categories',
              ),
              _ActionChip(
                icon: Icons.image,
                label: isAr ? 'رفع الصور' : 'Upload Images',
              ),
              _ActionChip(
                icon: Icons.tune,
                label: isAr ? 'المكافآت والتلميحات' : 'Rewards & Hints',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isAr
                ? 'هذه اللوحة تقرأ بيانات المستويات الحالية. ربطها بجدول Supabase أو Firebase يحول الأزرار إلى عمليات حفظ وتعديل مباشرة.'
                : 'This dashboard reads the current local level model. Connecting it to Supabase or Firebase turns these controls into live create, edit, upload, and analytics workflows.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      backgroundColor: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _AdminLevelCard extends StatelessWidget {
  const _AdminLevelCard({
    required this.level,
    required this.isAr,
    required this.completed,
  });

  final WordGameLevel level;
  final bool isAr;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  level.localizedTitle(isAr),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Icon(
                completed ? Icons.verified : Icons.pending_actions,
                color: completed ? AppColors.success : AppColors.gray,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${level.mode.label(isAr)} • ${level.difficulty.label(isAr)} • ${level.category}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SmallBadge(
                icon: Icons.monetization_on,
                label: '+${level.rewardCoins}',
              ),
              const SizedBox(width: 8),
              _SmallBadge(icon: Icons.lightbulb, label: '${level.hintCost}'),
              const SizedBox(width: 8),
              _SmallBadge(icon: Icons.translate, label: level.languageCode),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
