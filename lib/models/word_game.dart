enum WordGameMode {
  wordSearch,
  imageToWord,
  missingLetters,
  sentenceCompletion,
  crossword,
  listeningSpelling,
}

enum WordGameDifficulty { easy, medium, hard }

class WordGameLevel {
  const WordGameLevel({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.languageCode,
    required this.category,
    required this.title,
    required this.titleEn,
    required this.instruction,
    required this.instructionEn,
    required this.letters,
    required this.targets,
    required this.rewardCoins,
    required this.hintCost,
    this.imageEmoji,
    this.sentence,
    this.sentenceEn,
    this.answerSlots,
  });

  final String id;
  final WordGameMode mode;
  final WordGameDifficulty difficulty;
  final String languageCode;
  final String category;
  final String title;
  final String titleEn;
  final String instruction;
  final String instructionEn;
  final List<String> letters;
  final List<String> targets;
  final int rewardCoins;
  final int hintCost;
  final String? imageEmoji;
  final String? sentence;
  final String? sentenceEn;
  final String? answerSlots;

  String localizedTitle(bool isAr) => isAr ? title : titleEn;

  String localizedInstruction(bool isAr) => isAr ? instruction : instructionEn;
}

extension WordGameModeLabel on WordGameMode {
  String label(bool isAr) {
    return switch (this) {
      WordGameMode.wordSearch => isAr ? 'البحث عن الكلمات' : 'Word Search',
      WordGameMode.imageToWord => isAr ? 'الصورة والكلمة' : 'Image to Word',
      WordGameMode.missingLetters =>
        isAr ? 'أكمل الحروف الناقصة' : 'Missing Letters',
      WordGameMode.sentenceCompletion =>
        isAr ? 'أكمل الجملة' : 'Sentence Completion',
      WordGameMode.crossword => isAr ? 'كلمات متقاطعة' : 'Crossword',
      WordGameMode.listeningSpelling =>
        isAr ? 'استمع واكتب' : 'Listening & Spelling',
    };
  }
}

extension WordGameDifficultyLabel on WordGameDifficulty {
  String label(bool isAr) {
    return switch (this) {
      WordGameDifficulty.easy => isAr ? 'سهل' : 'Easy',
      WordGameDifficulty.medium => isAr ? 'متوسط' : 'Medium',
      WordGameDifficulty.hard => isAr ? 'صعب' : 'Hard',
    };
  }
}
