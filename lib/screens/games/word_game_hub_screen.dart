import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/word_game_levels.dart';
import '../../models/word_game.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';
import 'word_game_admin_screen.dart';
import 'word_game_play_screen.dart';

class WordGameHubScreen extends ConsumerStatefulWidget {
  const WordGameHubScreen({super.key});

  static const routeName = 'WordGames';
  static const routePath = '/games';

  @override
  ConsumerState<WordGameHubScreen> createState() => _WordGameHubScreenState();
}

class _WordGameHubScreenState extends ConsumerState<WordGameHubScreen> {
  WordGameDifficulty? _difficulty;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final isAr = user.settings.language.name == 'ar';
    final allLevels = gameLevelsForLanguage(user.settings.language.name);
    final visibleLevels = _difficulty == null
        ? allLevels
        : allLevels
              .where((level) => level.difficulty == _difficulty)
              .toList(growable: false);
    final completed = user.progress.wordGameCompleted;
    final completedForLanguage = allLevels
        .where((level) => completed.contains(level.id))
        .length;
    final progress = allLevels.isEmpty
        ? 0.0
        : completedForLanguage / allLevels.length;

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'ألعاب الكلمات' : 'Word Games',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isAr
                                    ? 'تدريب على القراءة والكتابة والتركيز'
                                    : 'Reading, writing, spelling, and focus practice',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () =>
                              context.push(WordGameAdminScreen.routePath),
                          icon: const Icon(Icons.admin_panel_settings),
                          tooltip: isAr ? 'لوحة التحكم' : 'Admin dashboard',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ProgressPanel(
                      completed: completedForLanguage,
                      total: allLevels.length,
                      coins: user.progress.wordGameCoins,
                      streak: user.progress.wordGameStreak,
                      progress: progress,
                      isAr: isAr,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DifficultyChip(
                          label: isAr ? 'الكل' : 'All',
                          selected: _difficulty == null,
                          onTap: () => setState(() => _difficulty = null),
                        ),
                        for (final difficulty in WordGameDifficulty.values)
                          _DifficultyChip(
                            label: difficulty.label(isAr),
                            selected: _difficulty == difficulty,
                            onTap: () =>
                                setState(() => _difficulty = difficulty),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    for (final level in visibleLevels) ...[
                      _LevelCard(
                        level: level,
                        isAr: isAr,
                        completed: completed.contains(level.id),
                        onTap: () => context.push(
                          WordGamePlayScreen.path(levelId: level.id),
                        ),
                      ),
                      const SizedBox(height: 12),
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

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.completed,
    required this.total,
    required this.coins,
    required this.streak,
    required this.progress,
    required this.isAr,
  });

  final int completed;
  final int total;
  final int coins;
  final int streak;
  final double progress;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isAr ? 'تقدم الألعاب' : 'Game Progress',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: AppColors.lightGray,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.monetization_on,
                  label: isAr ? 'عملات' : 'Coins',
                  value: '$coins',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department,
                  label: isAr ? 'سلسلة' : 'Streak',
                  value: '$streak',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 22),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFFE8F5E9),
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryDark : AppColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.isAr,
    required this.completed,
    required this.onTap,
  });

  final WordGameLevel level;
  final bool isAr;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed ? AppColors.success : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                completed ? Icons.check_circle : Icons.extension,
                color: completed ? AppColors.success : AppColors.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.localizedTitle(isAr),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${level.mode.label(isAr)} • ${level.difficulty.label(isAr)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${level.rewardCoins}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.lightbulb,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${level.hintCost}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
