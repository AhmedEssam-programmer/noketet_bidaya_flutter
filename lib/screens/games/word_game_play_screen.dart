import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/word_game_levels.dart';
import '../../models/word_game.dart';
import '../../services/speech_service.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';

class WordGamePlayScreen extends ConsumerStatefulWidget {
  const WordGamePlayScreen({super.key, required this.levelId});

  static const routeName = 'WordGamePlay';
  static const routePath = '/games/:levelId';

  static String path({required String levelId}) => '/games/$levelId';

  final String levelId;

  @override
  ConsumerState<WordGamePlayScreen> createState() => _WordGamePlayScreenState();
}

class _WordGamePlayScreenState extends ConsumerState<WordGamePlayScreen>
    with SingleTickerProviderStateMixin {
  final Set<int> _selectedIndexes = {};
  final Set<String> _foundTargets = {};
  final List<String> _selectedLetters = [];
  String? _hintText;
  bool _levelFinished = false;
  late final AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      lowerBound: 0.92,
      upperBound: 1.08,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakListeningPrompt();
    });
  }

  @override
  void didUpdateWidget(covariant WordGamePlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId == widget.levelId) return;
    _resetLevelState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakListeningPrompt();
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _resetLevelState() {
    _selectedIndexes.clear();
    _foundTargets.clear();
    _selectedLetters.clear();
    _hintText = null;
    _levelFinished = false;
    _successController.value = _successController.lowerBound;
  }

  void _speakListeningPrompt() {
    final level = findWordGameLevel(widget.levelId);
    final user = ref.read(userControllerProvider);
    if (level == null ||
        !user.settings.voiceEnabled ||
        level.mode != WordGameMode.listeningSpelling) {
      return;
    }
    unawaited(
      speechService.speak(
        level.targets.first,
        languageCode: _speechLanguage(level),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedIndexes.clear();
      _selectedLetters.clear();
    });
  }

  void _selectLetter(WordGameLevel level, int index) {
    if (index < 0 ||
        index >= level.letters.length ||
        _selectedIndexes.contains(index) ||
        _levelFinished) {
      return;
    }

    setState(() {
      _selectedIndexes.add(index);
      _selectedLetters.add(level.letters[index]);
    });
  }

  Future<void> _trySubmit(WordGameLevel level) async {
    final word = _selectedLetters.join();
    if (word.isEmpty) return;

    String? matchedTarget;
    for (final target in level.targets) {
      if (target == word) {
        matchedTarget = target;
        break;
      }
    }
    if (matchedTarget == null || _foundTargets.contains(matchedTarget)) {
      await SystemSound.play(SystemSoundType.click);
      _clearSelection();
      return;
    }
    final foundWord = matchedTarget;

    setState(() {
      _foundTargets.add(foundWord);
      _hintText = null;
      _selectedIndexes.clear();
      _selectedLetters.clear();
    });

    await SystemSound.play(SystemSoundType.alert);
    unawaited(
      _successController.forward(from: 0.92).then((_) {
        if (mounted) _successController.reverse();
      }),
    );

    final user = ref.read(userControllerProvider);
    if (user.settings.voiceEnabled) {
      unawaited(
        speechService.speak(foundWord, languageCode: _speechLanguage(level)),
      );
    }

    if (_foundTargets.length == level.targets.length) {
      await _completeLevel(level);
      if (mounted) setState(() {});
    }
  }

  Future<void> _completeLevel(WordGameLevel level) async {
    if (_levelFinished) return;
    _levelFinished = true;

    final user = ref.read(userControllerProvider);
    final progress = user.progress;
    if (progress.wordGameCompleted.contains(level.id)) return;

    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final nextStreak = progress.lastWordGameDay == today
        ? progress.wordGameStreak
        : progress.lastWordGameDay == yesterday
        ? progress.wordGameStreak + 1
        : 1;

    await ref
        .read(userControllerProvider.notifier)
        .patchProgress(
          wordGameCompleted: [...progress.wordGameCompleted, level.id],
          wordGameCoins: progress.wordGameCoins + level.rewardCoins,
          wordGameStreak: nextStreak,
          lastWordGameDay: today,
          totalStars: progress.totalStars + 1,
          currentLevel: 'games',
          lastLessonId: level.id,
        );
  }

  Future<void> _useHint(WordGameLevel level) async {
    final progress = ref.read(userControllerProvider).progress;
    if (progress.wordGameCoins < level.hintCost) return;

    final target = level.targets.firstWhere(
      (word) => !_foundTargets.contains(word),
      orElse: () => level.targets.first,
    );
    final revealCount = min(2, target.characters.length);
    final reveal = target.characters.take(revealCount).join();

    await ref
        .read(userControllerProvider.notifier)
        .patchProgress(
          wordGameCoins: progress.wordGameCoins - level.hintCost,
          wordGameHintsUsed: progress.wordGameHintsUsed + 1,
        );

    setState(() => _hintText = reveal);
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _speechLanguage(WordGameLevel level) =>
      level.languageCode == 'en' ? 'en-US' : 'ar-SA';

  void _goToNextLevel(WordGameLevel nextLevel) {
    context.pushReplacement(WordGamePlayScreen.path(levelId: nextLevel.id));
  }

  @override
  Widget build(BuildContext context) {
    final level = findWordGameLevel(widget.levelId);
    if (level == null) {
      return const Scaffold(body: Center(child: Text('Game level not found')));
    }

    final user = ref.watch(userControllerProvider);
    final isAr = user.settings.language.name == 'ar';
    final selectedWord = _selectedLetters.join();
    final alreadyCompleted = user.progress.wordGameCompleted.contains(level.id);
    final finishedNow = _foundTargets.length == level.targets.length;
    final isLevelRtl = level.languageCode == 'ar';
    final canAdvance = finishedNow || alreadyCompleted;
    final nextLevel = nextWordGameLevel(
      currentLevelId: level.id,
      languageCode: user.settings.language.name,
    );

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: isAr ? 'رجوع' : 'Back',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.localizedTitle(isAr),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            level.mode.label(isAr),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CoinPill(value: user.progress.wordGameCoins),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      _PromptCard(level: level, isAr: isAr),
                      const SizedBox(height: 14),
                      _TargetsPanel(
                        targets: level.targets,
                        foundTargets: _foundTargets,
                        isRtl: isLevelRtl,
                      ),
                      const SizedBox(height: 14),
                      ScaleTransition(
                        scale: _successController,
                        child: _SelectedWord(
                          value: selectedWord,
                          placeholder: isAr
                              ? 'اسحب على الحروف'
                              : 'Swipe letters',
                          hint: _hintText,
                          textDirection: isLevelRtl
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LetterBoard(
                        level: level,
                        selectedIndexes: _selectedIndexes,
                        isRtl: isLevelRtl,
                        onSelect: _selectLetter,
                        onSubmit: _trySubmit,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _useHint(level),
                              icon: const Icon(Icons.lightbulb),
                              label: Text(
                                isAr
                                    ? 'تلميح (${level.hintCost})'
                                    : 'Hint (${level.hintCost})',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _clearSelection,
                              icon: const Icon(Icons.refresh),
                              label: Text(isAr ? 'مسح' : 'Clear'),
                            ),
                          ),
                        ],
                      ),
                      if (finishedNow || alreadyCompleted) ...[
                        const SizedBox(height: 18),
                        _CompletionBanner(
                          alreadyCompleted: alreadyCompleted,
                          reward: level.rewardCoins,
                          isAr: isAr,
                        ),
                        const SizedBox(height: 12),
                        if (nextLevel != null)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: canAdvance
                                  ? () => _goToNextLevel(nextLevel)
                                  : null,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                isAr ? 'التالي' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          _AllDoneBanner(isAr: isAr),
                      ],
                    ],
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

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.level, required this.isAr});

  final WordGameLevel level;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          if (level.imageEmoji != null)
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                level.imageEmoji!,
                style: const TextStyle(fontSize: 70),
                textAlign: TextAlign.center,
              ),
            ),
          if (level.sentence != null || level.sentenceEn != null) ...[
            Text(
              isAr
                  ? level.sentence ?? ''
                  : level.sentenceEn ?? level.sentence ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (level.answerSlots != null) ...[
            Text(
              level.answerSlots!,
              textDirection: level.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  level.localizedInstruction(isAr),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (level.mode == WordGameMode.listeningSpelling)
                IconButton.filledTonal(
                  onPressed: () => speechService.speak(
                    level.targets.first,
                    languageCode: level.languageCode == 'en'
                        ? 'en-US'
                        : 'ar-SA',
                  ),
                  icon: const Icon(Icons.volume_up),
                  tooltip: isAr ? 'استمع' : 'Listen',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetsPanel extends StatelessWidget {
  const _TargetsPanel({
    required this.targets,
    required this.foundTargets,
    required this.isRtl,
  });

  final List<String> targets;
  final Set<String> foundTargets;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final target in targets)
          Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Chip(
              avatar: Icon(
                foundTargets.contains(target)
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: foundTargets.contains(target)
                    ? AppColors.success
                    : AppColors.gray,
                size: 18,
              ),
              label: Text(
                foundTargets.contains(target) ? target : _mask(target),
                textAlign: TextAlign.center,
              ),
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: foundTargets.contains(target)
                      ? AppColors.success
                      : AppColors.lightGray,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _mask(String value) =>
      List.filled(value.characters.length, 'ـ').join();
}

class _SelectedWord extends StatelessWidget {
  const _SelectedWord({
    required this.value,
    required this.placeholder,
    required this.hint,
    required this.textDirection,
  });

  final String value;
  final String placeholder;
  final String? hint;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      alignment: Alignment.center,
      child: Directionality(
        textDirection: textDirection,
        child: Text(
          value.isNotEmpty
              ? value
              : hint == null
              ? placeholder
              : '${hint!}...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: value.isNotEmpty ? 28 : 16,
            color: value.isNotEmpty
                ? AppColors.primaryDark
                : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LetterBoard extends StatelessWidget {
  const _LetterBoard({
    required this.level,
    required this.selectedIndexes,
    required this.isRtl,
    required this.onSelect,
    required this.onSubmit,
  });

  final WordGameLevel level;
  final Set<int> selectedIndexes;
  final bool isRtl;
  final void Function(WordGameLevel level, int index) onSelect;
  final Future<void> Function(WordGameLevel level) onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final columns = level.letters.length <= 9 ? 3 : 4;
        final rows = (level.letters.length / columns).ceil();
        final tileSize = (constraints.maxWidth - (columns - 1) * gap) / columns;
        final boardHeight = rows * tileSize + (rows - 1) * gap;

        int? indexFromPosition(Offset position) {
          final step = tileSize + gap;
          final visualCol = position.dx ~/ step;
          final row = position.dy ~/ step;
          if (visualCol < 0 || visualCol >= columns || row < 0 || row >= rows) {
            return null;
          }
          final localX = position.dx - visualCol * step;
          final localY = position.dy - row * step;
          if (localX > tileSize || localY > tileSize) return null;
          final col = isRtl ? columns - 1 - visualCol : visualCol;
          final index = row * columns + col;
          return index >= level.letters.length ? null : index;
        }

        void selectAt(Offset position) {
          final index = indexFromPosition(position);
          if (index != null) onSelect(level, index);
        }

        return GestureDetector(
          onPanStart: (details) => selectAt(details.localPosition),
          onPanUpdate: (details) => selectAt(details.localPosition),
          onPanEnd: (_) => onSubmit(level),
          child: SizedBox(
            height: boardHeight,
            child: Stack(
              children: [
                for (var i = 0; i < level.letters.length; i++)
                  Positioned(
                    left:
                        (isRtl ? columns - 1 - (i % columns) : i % columns) *
                        (tileSize + gap),
                    top: (i ~/ columns) * (tileSize + gap),
                    width: tileSize,
                    height: tileSize,
                    child: _LetterTile(
                      letter: level.letters[i],
                      selected: selectedIndexes.contains(i),
                      isRtl: isRtl,
                      onTap: () => onSelect(level, i),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.selected,
    required this.isRtl,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final bool isRtl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  letter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: selected ? AppColors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({
    required this.alreadyCompleted,
    required this.reward,
    required this.isAr,
  });

  final bool alreadyCompleted;
  final int reward;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        alreadyCompleted
            ? (isAr ? 'تم حل هذا المستوى من قبل' : 'Level already completed')
            : (isAr
                  ? 'أحسنت! ربحت $reward عملة'
                  : 'Great work! You earned $reward coins'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner({required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Text(
        isAr
            ? 'أكملت كل ألعاب الكلمات المتاحة.'
            : 'You completed all available word games.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF1565C0),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
