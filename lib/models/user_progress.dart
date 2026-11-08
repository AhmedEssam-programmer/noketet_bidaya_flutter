class UserProgress {
  const UserProgress({
    required this.soundsCompleted,
    required this.lettersCompleted,
    required this.wordsCompleted,
    required this.sentencesCompleted,
    required this.wordGameCompleted,
    required this.wordGameCoins,
    required this.wordGameHintsUsed,
    required this.wordGameStreak,
    required this.lastWordGameDay,
    required this.totalStars,
    required this.currentLevel,
    required this.lastLessonId,
  });

  final List<String> soundsCompleted;
  final List<String> lettersCompleted;
  final List<String> wordsCompleted;
  final List<String> sentencesCompleted;
  final List<String> wordGameCompleted;
  final int wordGameCoins;
  final int wordGameHintsUsed;
  final int wordGameStreak;
  final String? lastWordGameDay;
  final int totalStars;
  final String currentLevel;
  final String? lastLessonId;

  static const defaultValue = UserProgress(
    soundsCompleted: [],
    lettersCompleted: [],
    wordsCompleted: [],
    sentencesCompleted: [],
    wordGameCompleted: [],
    wordGameCoins: 20,
    wordGameHintsUsed: 0,
    wordGameStreak: 0,
    lastWordGameDay: null,
    totalStars: 0,
    currentLevel: 'sounds',
    lastLessonId: null,
  );

  UserProgress copyWith({
    List<String>? soundsCompleted,
    List<String>? lettersCompleted,
    List<String>? wordsCompleted,
    List<String>? sentencesCompleted,
    List<String>? wordGameCompleted,
    int? wordGameCoins,
    int? wordGameHintsUsed,
    int? wordGameStreak,
    String? lastWordGameDay,
    int? totalStars,
    String? currentLevel,
    String? lastLessonId,
  }) {
    return UserProgress(
      soundsCompleted: soundsCompleted ?? this.soundsCompleted,
      lettersCompleted: lettersCompleted ?? this.lettersCompleted,
      wordsCompleted: wordsCompleted ?? this.wordsCompleted,
      sentencesCompleted: sentencesCompleted ?? this.sentencesCompleted,
      wordGameCompleted: wordGameCompleted ?? this.wordGameCompleted,
      wordGameCoins: wordGameCoins ?? this.wordGameCoins,
      wordGameHintsUsed: wordGameHintsUsed ?? this.wordGameHintsUsed,
      wordGameStreak: wordGameStreak ?? this.wordGameStreak,
      lastWordGameDay: lastWordGameDay ?? this.lastWordGameDay,
      totalStars: totalStars ?? this.totalStars,
      currentLevel: currentLevel ?? this.currentLevel,
      lastLessonId: lastLessonId ?? this.lastLessonId,
    );
  }

  Map<String, dynamic> toJson() => {
    'soundsCompleted': soundsCompleted,
    'lettersCompleted': lettersCompleted,
    'wordsCompleted': wordsCompleted,
    'sentencesCompleted': sentencesCompleted,
    'wordGameCompleted': wordGameCompleted,
    'wordGameCoins': wordGameCoins,
    'wordGameHintsUsed': wordGameHintsUsed,
    'wordGameStreak': wordGameStreak,
    'lastWordGameDay': lastWordGameDay,
    'totalStars': totalStars,
    'currentLevel': currentLevel,
    'lastLessonId': lastLessonId,
  };

  static UserProgress fromJson(Map<String, dynamic> json) {
    return UserProgress(
      soundsCompleted: _stringList(json['soundsCompleted']),
      lettersCompleted: _stringList(json['lettersCompleted']),
      wordsCompleted: _stringList(json['wordsCompleted']),
      sentencesCompleted: _stringList(json['sentencesCompleted']),
      wordGameCompleted: _stringList(json['wordGameCompleted']),
      wordGameCoins: _intValue(json['wordGameCoins'], fallback: 20),
      wordGameHintsUsed: _intValue(json['wordGameHintsUsed']),
      wordGameStreak: _intValue(json['wordGameStreak']),
      lastWordGameDay: json['lastWordGameDay'] as String?,
      totalStars: _intValue(json['totalStars']),
      currentLevel: (json['currentLevel'] as String?) ?? 'sounds',
      lastLessonId: json['lastLessonId'] as String?,
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  static int _intValue(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
