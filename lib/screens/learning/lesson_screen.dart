import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/lessons.dart';
import '../../services/speech_service.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.level, required this.lessonId});

  static const routeName = 'LearningLesson';
  static const routePath = '/learning/:level/:lessonId';

  static String path({required String level, required String lessonId}) =>
      '/learning/$level/$lessonId';

  final String level;
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late int _currentIndex;
  bool _navigationBusy = false;
  bool _completeBusy = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = int.tryParse(widget.lessonId) ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_autoSpeak());
    });
  }

  String _title(bool isAr) {
    return switch (widget.level) {
      'sounds' => isAr ? 'الأصوات' : 'Sounds',
      'letters' => isAr ? 'الحروف' : 'Letters',
      'words' => isAr ? 'الكلمات' : 'Words',
      'sentences' => isAr ? 'الجمل' : 'Sentences',
      _ => '',
    };
  }

  List<dynamic> _lessons() {
    return switch (widget.level) {
      'sounds' => soundsLessons,
      'letters' => letterWritingLessons,
      'words' => wordsLessons,
      'sentences' => sentencesLessons,
      _ => soundsLessons,
    };
  }

  List<String> _completedList(UserState user) {
    return switch (widget.level) {
      'sounds' => user.progress.soundsCompleted,
      'letters' => user.progress.lettersCompleted,
      'words' => user.progress.wordsCompleted,
      'sentences' => user.progress.sentencesCompleted,
      _ => const [],
    };
  }

  Future<void> _autoSpeak() async {
    final user = ref.read(userControllerProvider);
    if (!user.settings.voiceEnabled) return;

    final lessons = _lessons();
    if (_currentIndex < 0 || _currentIndex >= lessons.length) return;
    final current = lessons[_currentIndex];

    final isAr = user.settings.language.name == 'ar';
    String text = '';
    if (widget.level == 'sounds' || widget.level == 'letters') {
      final l = current as dynamic;
      text = 'الحرف ${l.letter}';
    } else if (widget.level == 'words') {
      final w = current as LessonWord;
      text = isAr
          ? '${w.word} تعني ${w.meaning}'
          : '${w.word} means ${w.meaningEn}';
    } else if (widget.level == 'sentences') {
      final s = current as LessonSentence;
      text = isAr
          ? '${s.sentence} تعني ${s.meaning}'
          : '${s.sentence} means ${s.meaningEn}';
    }

    await speechService.speak(text);
  }

  Future<void> _speakMain() async {
    final lessons = _lessons();
    if (_currentIndex < 0 || _currentIndex >= lessons.length) return;
    final current = lessons[_currentIndex];

    String text = '';
    if (widget.level == 'sounds' || widget.level == 'letters') {
      text = (current as dynamic).letter as String;
    } else if (widget.level == 'words') {
      text = (current as LessonWord).word;
    } else if (widget.level == 'sentences') {
      text = (current as LessonSentence).sentence;
    }

    await speechService.speak(text);
  }

  Future<void> _next() async {
    if (_navigationBusy) return;
    _navigationBusy = true;
    try {
      await speechService.stop();
      final total = _lessons().length;
      if (_currentIndex >= total - 1 || !mounted) return;
      setState(() => _currentIndex += 1);
      await _autoSpeak();
    } finally {
      _navigationBusy = false;
    }
  }

  Future<void> _prev() async {
    if (_navigationBusy) return;
    _navigationBusy = true;
    try {
      await speechService.stop();
      if (_currentIndex <= 0 || !mounted) return;
      setState(() => _currentIndex -= 1);
      await _autoSpeak();
    } finally {
      _navigationBusy = false;
    }
  }

  Future<void> _complete() async {
    if (_completeBusy) return;
    _completeBusy = true;
    final user = ref.read(userControllerProvider);
    final controller = ref.read(userControllerProvider.notifier);

    final lessons = _lessons();
    if (_currentIndex < 0 || _currentIndex >= lessons.length) {
      _completeBusy = false;
      return;
    }
    final current = lessons[_currentIndex];
    final id = (current as dynamic).id as String;

    final completed = _completedList(user);
    if (completed.contains(id)) {
      _completeBusy = false;
      return;
    }

    final newList = [...completed, id];
    final stars = user.progress.totalStars + 1;

    try {
      switch (widget.level) {
        case 'sounds':
          await controller.patchProgress(
            soundsCompleted: newList,
            totalStars: stars,
          );
          break;
        case 'letters':
          await controller.patchProgress(
            lettersCompleted: newList,
            totalStars: stars,
          );
          break;
        case 'words':
          await controller.patchProgress(
            wordsCompleted: newList,
            totalStars: stars,
          );
          break;
        case 'sentences':
          await controller.patchProgress(
            sentencesCompleted: newList,
            totalStars: stars,
          );
          break;
      }
    } finally {
      _completeBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final isAr = user.settings.language.name == 'ar';

    final lessons = _lessons();
    if (_currentIndex < 0 || _currentIndex >= lessons.length) {
      return const Scaffold(body: Center(child: Text('Lesson not found')));
    }

    final current = lessons[_currentIndex];
    final total = lessons.length;
    final completed = _completedList(user);
    final isCompleted = completed.contains((current as dynamic).id as String);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _title(isAr),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '${_currentIndex + 1} / $total',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          if (widget.level == 'sounds' ||
                              widget.level == 'letters')
                            _SoundOrLetterCard(
                              lesson: current as dynamic,
                              isAr: isAr,
                              onSpeakMain: _speakMain,
                            ),
                          if (widget.level == 'words')
                            _WordCard(
                              lesson: current as LessonWord,
                              isAr: isAr,
                              onSpeakMain: _speakMain,
                            ),
                          if (widget.level == 'sentences')
                            _SentenceCard(
                              lesson: current as LessonSentence,
                              isAr: isAr,
                              onSpeakMain: _speakMain,
                            ),
                          if (isCompleted)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '✓ ${isAr ? 'مكتمل' : 'Completed'}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavButton(
                        label: '◀ ${isAr ? 'السابق' : 'Prev'}',
                        enabled: _currentIndex > 0,
                        onTap: _prev,
                      ),
                      _CompleteButton(completed: isCompleted, onTap: _complete),
                      _NavButton(
                        label: '${isAr ? 'التالي' : 'Next'} ▶',
                        enabled: _currentIndex < total - 1,
                        onTap: _next,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: Text(
                      isAr ? 'رجوع للقائمة' : 'Back to Menu',
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? AppColors.primary : AppColors.gray,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.completed, required this.onTap});
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: completed ? AppColors.success : AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          child: Text(
            '✓',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundOrLetterCard extends StatelessWidget {
  const _SoundOrLetterCard({
    required this.lesson,
    required this.isAr,
    required this.onSpeakMain,
  });

  final dynamic lesson;
  final bool isAr;
  final VoidCallback onSpeakMain;

  @override
  Widget build(BuildContext context) {
    final letter = switch (lesson) {
      LessonSound(:final letter) => letter,
      LessonLetter(:final letter) => letter,
      _ => '',
    };
    final name = switch (lesson) {
      LessonSound(:final name) => name,
      LessonLetter(:final name) => name,
      _ => '',
    };
    final emoji = switch (lesson) {
      LessonSound(:final emoji) => emoji,
      _ => '📖',
    };
    final examples = switch (lesson) {
      LessonSound(:final examples) => examples,
      LessonLetter(:final words) => words,
      _ => const <String>[],
    };
    final forms = switch (lesson) {
      LessonLetter(:final initial, :final middle, :final finalForm) => [
        initial,
        middle,
        finalForm,
      ],
      _ => const <String>[],
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onSpeakMain,
            borderRadius: BorderRadius.circular(70),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(70),
                border: Border.all(color: AppColors.primary, width: 4),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 72,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(emoji, style: const TextStyle(fontSize: 48)),
          if (forms.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                for (final form in forms)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        form,
                        style: const TextStyle(
                          fontSize: 26,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'أمثلة:' : 'Examples:',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final ex in examples)
                  InkWell(
                    onTap: () => speechService.speak(ex),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ex,
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.text,
                            ),
                          ),
                          const Icon(
                            Icons.volume_up,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.lesson,
    required this.isAr,
    required this.onSpeakMain,
  });

  final LessonWord lesson;
  final bool isAr;
  final VoidCallback onSpeakMain;

  @override
  Widget build(BuildContext context) {
    final meaning = isAr ? lesson.meaning : lesson.meaningEn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onSpeakMain,
            borderRadius: BorderRadius.circular(90),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(90),
                border: Border.all(color: AppColors.secondary, width: 4),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(lesson.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 4),
                  Text(
                    lesson.word,
                    style: const TextStyle(
                      fontSize: 36,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  isAr ? 'المعنى:' : 'Meaning:',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meaning,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({
    required this.lesson,
    required this.isAr,
    required this.onSpeakMain,
  });

  final LessonSentence lesson;
  final bool isAr;
  final VoidCallback onSpeakMain;

  @override
  Widget build(BuildContext context) {
    final meaning = isAr ? lesson.meaning : lesson.meaningEn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onSpeakMain,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      lesson.sentence,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.volume_up,
                    color: Color(0xFF1976D2),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  isAr ? 'المعنى:' : 'Meaning:',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meaning,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
