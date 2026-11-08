import '../models/word_game.dart';

const _baseWordGameLevels = <WordGameLevel>[
  WordGameLevel(
    id: 'ar_word_search_01',
    mode: WordGameMode.wordSearch,
    difficulty: WordGameDifficulty.easy,
    languageCode: 'ar',
    category: 'البيت',
    title: 'كلمات من البيت',
    titleEn: 'Words at Home',
    instruction: 'صل الحروف لتكوين كل كلمة.',
    instructionEn: 'Connect letters to form each word.',
    letters: ['ب', 'ا', 'ب', 'ق', 'ل', 'م', 'ك', 'ت'],
    targets: ['باب', 'قلم', 'كتاب'],
    rewardCoins: 12,
    hintCost: 3,
  ),
  WordGameLevel(
    id: 'ar_image_01',
    mode: WordGameMode.imageToWord,
    difficulty: WordGameDifficulty.easy,
    languageCode: 'ar',
    category: 'الحيوانات',
    title: 'ما الصورة؟',
    titleEn: 'What Is the Picture?',
    instruction: 'انظر إلى الصورة ثم كوّن الكلمة.',
    instructionEn: 'Look at the picture, then build the word.',
    letters: ['ق', 'ط', 'ة', 'ك', 'ب'],
    targets: ['قطة'],
    rewardCoins: 10,
    hintCost: 2,
    imageEmoji: '🐱',
  ),
  WordGameLevel(
    id: 'ar_missing_01',
    mode: WordGameMode.missingLetters,
    difficulty: WordGameDifficulty.medium,
    languageCode: 'ar',
    category: 'المدرسة',
    title: 'الحروف الناقصة',
    titleEn: 'Missing Letters',
    instruction: 'اختر الحروف بالترتيب لإكمال الكلمة.',
    instructionEn: 'Choose letters in order to complete the word.',
    letters: ['ر', 'س', 'ة', 'م', 'د'],
    targets: ['مدرسة'],
    rewardCoins: 16,
    hintCost: 4,
    answerSlots: 'م _ ر _ ة',
  ),
  WordGameLevel(
    id: 'ar_sentence_01',
    mode: WordGameMode.sentenceCompletion,
    difficulty: WordGameDifficulty.medium,
    languageCode: 'ar',
    category: 'الجمل',
    title: 'أكمل المعنى',
    titleEn: 'Complete the Meaning',
    instruction: 'كوّن الكلمة المناسبة لإكمال الجملة.',
    instructionEn: 'Build the correct word to complete the sentence.',
    letters: ['ي', 'ق', 'ر', 'أ', 'ك', 'ت'],
    targets: ['يقرأ'],
    rewardCoins: 18,
    hintCost: 4,
    sentence: 'الولد ____ كتابا.',
    sentenceEn: 'The boy ____ a book.',
  ),
  WordGameLevel(
    id: 'ar_listen_01',
    mode: WordGameMode.listeningSpelling,
    difficulty: WordGameDifficulty.hard,
    languageCode: 'ar',
    category: 'الاستماع',
    title: 'استمع واكتب',
    titleEn: 'Listen and Spell',
    instruction: 'استمع إلى الكلمة ثم كوّنها من الحروف.',
    instructionEn: 'Listen to the word, then build it from the letters.',
    letters: ['س', 'م', 'ا', 'ء', 'ر', 'ض'],
    targets: ['سماء'],
    rewardCoins: 24,
    hintCost: 5,
  ),
  WordGameLevel(
    id: 'en_word_search_01',
    mode: WordGameMode.wordSearch,
    difficulty: WordGameDifficulty.easy,
    languageCode: 'en',
    category: 'School',
    title: 'School Words',
    titleEn: 'School Words',
    instruction: 'Connect letters to find the hidden words.',
    instructionEn: 'Connect letters to find the hidden words.',
    letters: ['B', 'O', 'O', 'K', 'P', 'E', 'N', 'A'],
    targets: ['BOOK', 'PEN'],
    rewardCoins: 12,
    hintCost: 3,
  ),
  WordGameLevel(
    id: 'en_image_01',
    mode: WordGameMode.imageToWord,
    difficulty: WordGameDifficulty.easy,
    languageCode: 'en',
    category: 'Nature',
    title: 'Picture Word',
    titleEn: 'Picture Word',
    instruction: 'Build the word shown in the picture.',
    instructionEn: 'Build the word shown in the picture.',
    letters: ['T', 'R', 'E', 'E', 'S', 'U'],
    targets: ['TREE'],
    rewardCoins: 10,
    hintCost: 2,
    imageEmoji: '🌳',
  ),
  WordGameLevel(
    id: 'en_sentence_01',
    mode: WordGameMode.sentenceCompletion,
    difficulty: WordGameDifficulty.medium,
    languageCode: 'en',
    category: 'Sentences',
    title: 'Complete the Sentence',
    titleEn: 'Complete the Sentence',
    instruction: 'Build the missing word.',
    instructionEn: 'Build the missing word.',
    letters: ['R', 'E', 'A', 'D', 'W', 'S'],
    targets: ['READ'],
    rewardCoins: 18,
    hintCost: 4,
    sentence: 'I ____ a story.',
    sentenceEn: 'I ____ a story.',
  ),
];

const _arWordBanks = <_WordBank>[
  _WordBank(
    category: 'البيت',
    categoryEn: 'Home',
    emoji: '🏠',
    words: ['باب', 'بيت', 'سرير', 'كرسي', 'مطبخ', 'نافذة', 'وسادة', 'غرفة'],
  ),
  _WordBank(
    category: 'المدرسة',
    categoryEn: 'School',
    emoji: '🎒',
    words: ['قلم', 'كتاب', 'دفتر', 'درس', 'معلم', 'سبورة', 'ممحاة', 'حقيبة'],
  ),
  _WordBank(
    category: 'الطعام',
    categoryEn: 'Food',
    emoji: '🍽️',
    words: ['خبز', 'أرز', 'جبن', 'عسل', 'تمر', 'تفاح', 'حليب', 'سمك'],
  ),
  _WordBank(
    category: 'الحيوانات',
    categoryEn: 'Animals',
    emoji: '🐾',
    words: ['قطة', 'كلب', 'جمل', 'حصان', 'أسد', 'نمر', 'غزال', 'أرنب'],
  ),
  _WordBank(
    category: 'الطبيعة',
    categoryEn: 'Nature',
    emoji: '🌿',
    words: ['شمس', 'قمر', 'سماء', 'نهر', 'بحر', 'جبل', 'زهرة', 'شجرة'],
  ),
  _WordBank(
    category: 'الجسم',
    categoryEn: 'Body',
    emoji: '🧍',
    words: ['عين', 'يد', 'قدم', 'رأس', 'فم', 'أذن', 'قلب', 'وجه'],
  ),
  _WordBank(
    category: 'الألوان',
    categoryEn: 'Colors',
    emoji: '🎨',
    words: ['أحمر', 'أزرق', 'أخضر', 'أصفر', 'أبيض', 'أسود', 'وردي', 'ذهبي'],
  ),
  _WordBank(
    category: 'الأفعال',
    categoryEn: 'Actions',
    emoji: '🏃',
    words: ['يقرأ', 'يكتب', 'يلعب', 'يرسم', 'يفتح', 'يغلق', 'يسمع', 'ينظر'],
  ),
];

const _enWordBanks = <_WordBank>[
  _WordBank(
    category: 'Home',
    categoryEn: 'Home',
    emoji: '🏠',
    words: [
      'DOOR',
      'HOME',
      'BED',
      'CHAIR',
      'ROOM',
      'WINDOW',
      'PILLOW',
      'KITCHEN',
    ],
  ),
  _WordBank(
    category: 'School',
    categoryEn: 'School',
    emoji: '🎒',
    words: [
      'PEN',
      'BOOK',
      'NOTE',
      'CLASS',
      'TEACHER',
      'BOARD',
      'ERASER',
      'BAG',
    ],
  ),
  _WordBank(
    category: 'Food',
    categoryEn: 'Food',
    emoji: '🍽️',
    words: [
      'BREAD',
      'RICE',
      'CHEESE',
      'HONEY',
      'DATE',
      'APPLE',
      'MILK',
      'FISH',
    ],
  ),
  _WordBank(
    category: 'Animals',
    categoryEn: 'Animals',
    emoji: '🐾',
    words: ['CAT', 'DOG', 'CAMEL', 'HORSE', 'LION', 'TIGER', 'DEER', 'RABBIT'],
  ),
  _WordBank(
    category: 'Nature',
    categoryEn: 'Nature',
    emoji: '🌿',
    words: ['SUN', 'MOON', 'SKY', 'RIVER', 'SEA', 'MOUNTAIN', 'FLOWER', 'TREE'],
  ),
  _WordBank(
    category: 'Body',
    categoryEn: 'Body',
    emoji: '🧍',
    words: ['EYE', 'HAND', 'FOOT', 'HEAD', 'MOUTH', 'EAR', 'HEART', 'FACE'],
  ),
  _WordBank(
    category: 'Colors',
    categoryEn: 'Colors',
    emoji: '🎨',
    words: ['RED', 'BLUE', 'GREEN', 'YELLOW', 'WHITE', 'BLACK', 'PINK', 'GOLD'],
  ),
  _WordBank(
    category: 'Actions',
    categoryEn: 'Actions',
    emoji: '🏃',
    words: ['READ', 'WRITE', 'PLAY', 'DRAW', 'OPEN', 'CLOSE', 'LISTEN', 'LOOK'],
  ),
];

final wordGameLevels = <WordGameLevel>[
  ..._baseWordGameLevels,
  ..._buildGeneratedLevels(languageCode: 'ar', banks: _arWordBanks),
  ..._buildGeneratedLevels(languageCode: 'en', banks: _enWordBanks),
];

List<WordGameLevel> gameLevelsForLanguage(String languageCode) {
  final localized = wordGameLevels
      .where((level) => level.languageCode == languageCode)
      .toList(growable: false);
  return localized.isEmpty
      ? wordGameLevels.where((level) => level.languageCode == 'en').toList()
      : localized;
}

WordGameLevel firstPlayableWordGameLevel({
  required String languageCode,
  required Iterable<String> completedLevelIds,
}) {
  final levels = gameLevelsForLanguage(languageCode);
  final completed = completedLevelIds.toSet();
  return levels.firstWhere(
    (level) => !completed.contains(level.id),
    orElse: () => levels.first,
  );
}

WordGameLevel? nextWordGameLevel({
  required String currentLevelId,
  required String languageCode,
}) {
  final levels = gameLevelsForLanguage(languageCode);
  final index = levels.indexWhere((level) => level.id == currentLevelId);
  if (index < 0 || index >= levels.length - 1) return null;
  return levels[index + 1];
}

WordGameLevel? findWordGameLevel(String id) {
  for (final level in wordGameLevels) {
    if (level.id == id) return level;
  }
  return null;
}

List<WordGameLevel> _buildGeneratedLevels({
  required String languageCode,
  required List<_WordBank> banks,
}) {
  return List<WordGameLevel>.generate(100, (index) {
    final mode = _modeForIndex(index);
    final difficulty = _difficultyForIndex(index);
    final bank = banks[index % banks.length];
    final bankOffset = index ~/ banks.length;
    final primary = bank.words[(index + bankOffset) % bank.words.length];
    final secondary = bank.words[(index + bankOffset + 3) % bank.words.length];
    final tertiary = bank.words[(index + bankOffset + 5) % bank.words.length];
    final candidateTargets = switch (mode) {
      WordGameMode.wordSearch => [primary, secondary, tertiary],
      WordGameMode.crossword => [primary, secondary],
      _ => [primary],
    };
    final targets = switch (mode) {
      WordGameMode.wordSearch => _fitTargets(candidateTargets, difficulty),
      WordGameMode.crossword => _fitTargets(candidateTargets, difficulty),
      _ => candidateTargets,
    };
    final number = (index + 1).toString().padLeft(3, '0');
    final isAr = languageCode == 'ar';

    return WordGameLevel(
      id: '${languageCode}_${_modeSlug(mode)}_$number',
      mode: mode,
      difficulty: difficulty,
      languageCode: languageCode,
      category: bank.category,
      title: _titleForMode(mode, bank.category, isAr),
      titleEn: _titleForMode(mode, bank.categoryEn, false),
      instruction: _instructionForMode(mode, isAr),
      instructionEn: _instructionForMode(mode, false),
      letters: _lettersForTargets(targets, difficulty, isAr),
      targets: targets,
      rewardCoins: _rewardForDifficulty(difficulty),
      hintCost: _hintCostForDifficulty(difficulty),
      imageEmoji: mode == WordGameMode.imageToWord
          ? _emojiForWord(primary, fallback: bank.emoji)
          : null,
      sentence: mode == WordGameMode.sentenceCompletion
          ? _sentenceForTarget(primary, isAr)
          : null,
      sentenceEn: mode == WordGameMode.sentenceCompletion
          ? _sentenceForTarget(primary, false)
          : null,
      answerSlots: mode == WordGameMode.missingLetters
          ? _answerSlots(primary)
          : null,
    );
  }, growable: false);
}

List<String> _fitTargets(List<String> targets, WordGameDifficulty difficulty) {
  final maxLetters = switch (difficulty) {
    WordGameDifficulty.easy => 8,
    WordGameDifficulty.medium => 10,
    WordGameDifficulty.hard => 12,
  };
  final fitted = <String>[];
  var total = 0;
  for (final target in targets) {
    final length = target.split('').length;
    if (total + length > maxLetters && fitted.isNotEmpty) continue;
    fitted.add(target);
    total += length;
  }
  return fitted;
}

WordGameMode _modeForIndex(int index) {
  const pattern = [
    WordGameMode.wordSearch,
    WordGameMode.imageToWord,
    WordGameMode.missingLetters,
    WordGameMode.sentenceCompletion,
    WordGameMode.crossword,
    WordGameMode.listeningSpelling,
  ];
  return pattern[index % pattern.length];
}

WordGameDifficulty _difficultyForIndex(int index) {
  if (index < 34) return WordGameDifficulty.easy;
  if (index < 67) return WordGameDifficulty.medium;
  return WordGameDifficulty.hard;
}

String _modeSlug(WordGameMode mode) {
  return switch (mode) {
    WordGameMode.wordSearch => 'word_search',
    WordGameMode.imageToWord => 'image',
    WordGameMode.missingLetters => 'missing',
    WordGameMode.sentenceCompletion => 'sentence',
    WordGameMode.crossword => 'crossword',
    WordGameMode.listeningSpelling => 'listen',
  };
}

String _titleForMode(WordGameMode mode, String category, bool isAr) {
  return switch (mode) {
    WordGameMode.wordSearch => isAr ? 'ابحث في $category' : '$category Search',
    WordGameMode.imageToWord =>
      isAr ? 'صورة من $category' : '$category Picture',
    WordGameMode.missingLetters =>
      isAr ? 'حروف $category' : '$category Letters',
    WordGameMode.sentenceCompletion =>
      isAr ? 'جملة من $category' : '$category Sentence',
    WordGameMode.crossword => isAr ? 'تحدي $category' : '$category Crossword',
    WordGameMode.listeningSpelling =>
      isAr ? 'استماع $category' : '$category Listening',
  };
}

String _instructionForMode(WordGameMode mode, bool isAr) {
  return switch (mode) {
    WordGameMode.wordSearch =>
      isAr
          ? 'ابحث عن الكلمات المخفية وصل حروفها بالترتيب.'
          : 'Find the hidden words and connect their letters in order.',
    WordGameMode.imageToWord =>
      isAr
          ? 'انظر إلى الصورة ثم كوّن الكلمة المناسبة.'
          : 'Look at the picture, then build the matching word.',
    WordGameMode.missingLetters =>
      isAr
          ? 'استخدم الحروف لإكمال الكلمة الناقصة.'
          : 'Use the letters to complete the missing word.',
    WordGameMode.sentenceCompletion =>
      isAr
          ? 'كوّن الكلمة التي تكمل الجملة.'
          : 'Build the word that completes the sentence.',
    WordGameMode.crossword =>
      isAr
          ? 'كوّن الكلمات المطلوبة كما في تحديات الكلمات المتقاطعة.'
          : 'Build the requested words like a crossword challenge.',
    WordGameMode.listeningSpelling =>
      isAr
          ? 'استمع إلى الكلمة ثم هجّئها من الحروف.'
          : 'Listen to the word, then spell it from the letters.',
  };
}

List<String> _lettersForTargets(
  List<String> targets,
  WordGameDifficulty difficulty,
  bool isAr,
) {
  final targetLetters = targets.expand((word) => word.split('')).toList();
  final extras = isAr
      ? ['ا', 'ل', 'م', 'ن', 'ر', 'س', 'ت', 'ب', 'و', 'ي', 'ة', 'د']
      : ['A', 'E', 'I', 'O', 'U', 'R', 'S', 'T', 'N', 'L', 'M', 'P'];
  final wantedLength = switch (difficulty) {
    WordGameDifficulty.easy => 8,
    WordGameDifficulty.medium => 10,
    WordGameDifficulty.hard => 12,
  };
  final letters = <String>[...targetLetters];
  var extraIndex = 0;
  while (letters.length < wantedLength) {
    letters.add(extras[(letters.length + extraIndex) % extras.length]);
    extraIndex += 1;
  }
  return letters.take(12).toList(growable: false);
}

String _sentenceForTarget(String target, bool isAr) {
  return isAr ? 'الكلمة المناسبة هي ____.' : 'The correct word is ____.';
}

String _answerSlots(String word) {
  final chars = word.split('');
  return [
    for (var i = 0; i < chars.length; i++) i.isEven ? chars[i] : '_',
  ].join(' ');
}

int _rewardForDifficulty(WordGameDifficulty difficulty) {
  return switch (difficulty) {
    WordGameDifficulty.easy => 10,
    WordGameDifficulty.medium => 16,
    WordGameDifficulty.hard => 24,
  };
}

int _hintCostForDifficulty(WordGameDifficulty difficulty) {
  return switch (difficulty) {
    WordGameDifficulty.easy => 2,
    WordGameDifficulty.medium => 4,
    WordGameDifficulty.hard => 6,
  };
}

class _WordBank {
  const _WordBank({
    required this.category,
    required this.categoryEn,
    required this.emoji,
    required this.words,
  });

  final String category;
  final String categoryEn;
  final String emoji;
  final List<String> words;
}

String _emojiForWord(String word, {required String fallback}) {
  return _wordEmojis[word] ?? fallback;
}

const _wordEmojis = <String, String>{
  'باب': '🚪',
  'بيت': '🏠',
  'سرير': '🛏️',
  'كرسي': '🪑',
  'مطبخ': '🍳',
  'نافذة': '🪟',
  'وسادة': '🛏️',
  'غرفة': '🏠',
  'قلم': '✏️',
  'كتاب': '📖',
  'دفتر': '📓',
  'درس': '📚',
  'معلم': '👨‍🏫',
  'سبورة': '⬛',
  'ممحاة': '🧽',
  'حقيبة': '🎒',
  'خبز': '🍞',
  'أرز': '🍚',
  'جبن': '🧀',
  'عسل': '🍯',
  'تمر': '🌴',
  'تفاح': '🍎',
  'حليب': '🥛',
  'سمك': '🐟',
  'قطة': '🐱',
  'كلب': '🐶',
  'جمل': '🐪',
  'حصان': '🐴',
  'أسد': '🦁',
  'نمر': '🐅',
  'غزال': '🦌',
  'أرنب': '🐰',
  'شمس': '☀️',
  'قمر': '🌙',
  'سماء': '☁️',
  'نهر': '🏞️',
  'بحر': '🌊',
  'جبل': '⛰️',
  'زهرة': '🌸',
  'شجرة': '🌳',
  'عين': '👁️',
  'يد': '✋',
  'قدم': '🦶',
  'رأس': '🙂',
  'فم': '👄',
  'أذن': '👂',
  'قلب': '❤️',
  'وجه': '🙂',
  'أحمر': '🔴',
  'أزرق': '🔵',
  'أخضر': '🟢',
  'أصفر': '🟡',
  'أبيض': '⚪',
  'أسود': '⚫',
  'وردي': '🌸',
  'ذهبي': '🟡',
  'يقرأ': '📖',
  'يكتب': '✏️',
  'يلعب': '⚽',
  'يرسم': '🎨',
  'يفتح': '🔓',
  'يغلق': '🔒',
  'يسمع': '👂',
  'ينظر': '👁️',
  'DOOR': '🚪',
  'HOME': '🏠',
  'BED': '🛏️',
  'CHAIR': '🪑',
  'ROOM': '🏠',
  'WINDOW': '🪟',
  'PILLOW': '🛏️',
  'KITCHEN': '🍳',
  'PEN': '✏️',
  'BOOK': '📖',
  'NOTE': '📓',
  'CLASS': '🏫',
  'TEACHER': '👨‍🏫',
  'BOARD': '⬛',
  'ERASER': '🧽',
  'BAG': '🎒',
  'BREAD': '🍞',
  'RICE': '🍚',
  'CHEESE': '🧀',
  'HONEY': '🍯',
  'DATE': '🌴',
  'APPLE': '🍎',
  'MILK': '🥛',
  'FISH': '🐟',
  'CAT': '🐱',
  'DOG': '🐶',
  'CAMEL': '🐪',
  'HORSE': '🐴',
  'LION': '🦁',
  'TIGER': '🐅',
  'DEER': '🦌',
  'RABBIT': '🐰',
  'SUN': '☀️',
  'MOON': '🌙',
  'SKY': '☁️',
  'RIVER': '🏞️',
  'SEA': '🌊',
  'MOUNTAIN': '⛰️',
  'FLOWER': '🌸',
  'TREE': '🌳',
  'EYE': '👁️',
  'HAND': '✋',
  'FOOT': '🦶',
  'HEAD': '🙂',
  'MOUTH': '👄',
  'EAR': '👂',
  'HEART': '❤️',
  'FACE': '🙂',
  'RED': '🔴',
  'BLUE': '🔵',
  'GREEN': '🟢',
  'YELLOW': '🟡',
  'WHITE': '⚪',
  'BLACK': '⚫',
  'PINK': '🌸',
  'GOLD': '🟡',
  'READ': '📖',
  'WRITE': '✏️',
  'PLAY': '⚽',
  'DRAW': '🎨',
  'OPEN': '🔓',
  'CLOSE': '🔒',
  'LISTEN': '👂',
  'LOOK': '👁️',
};
