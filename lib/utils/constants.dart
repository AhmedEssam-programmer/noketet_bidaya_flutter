import '../theme/app_colors.dart';

class StorageKeys {
  static const userProgress = '@noktet_progress';
  static const userSettings = '@noktet_settings';
  static const cartItems = '@noktet_cart';
}

class VoiceCommands {
  static const startLearning = ['ابدأ', 'ابدأ التعلم', 'start', 'learn'];
  static const goShopping = ['تسوق', 'السوق', 'shop', 'shopping'];
  static const goHome = ['رئيسية', 'الرئيسية', 'home', 'menu'];
  static const cont = ['continue', 'استمر', 'التالي', 'next'];
  static const repeat = ['repeat', 'كرر', 'مرة أخرى', 'again'];
  static const back = ['رجوع', 'back', '返回'];
  static const help = ['help', 'مساعدة', 'help'];
}

class ArabicAlphabet {
  static const items = [
    (letter: 'أ', name: 'همزة', sound: 'alif'),
    (letter: 'ب', name: 'باء', sound: 'ba'),
    (letter: 'ت', name: 'تاء', sound: 'ta'),
    (letter: 'ث', name: 'ثاء', sound: 'tha'),
    (letter: 'ج', name: 'جيم', sound: 'jim'),
    (letter: 'ح', name: 'حاء', sound: 'ha'),
    (letter: 'خ', name: 'خاء', sound: 'kha'),
    (letter: 'د', name: 'دال', sound: 'dal'),
    (letter: 'ذ', name: 'ذال', sound: 'dhal'),
    (letter: 'ر', name: 'راء', sound: 'ra'),
    (letter: 'ز', name: 'زاي', sound: 'zay'),
    (letter: 'س', name: 'سين', sound: 'sin'),
    (letter: 'ش', name: 'شين', sound: 'shin'),
    (letter: 'ص', name: 'صاد', sound: 'sad'),
    (letter: 'ض', name: 'ضاد', sound: 'dad'),
    (letter: 'ط', name: 'طاء', sound: 'taMarbuta'),
    (letter: 'ظ', name: 'ظاء', sound: 'za'),
    (letter: 'ع', name: 'عين', sound: 'ain'),
    (letter: 'غ', name: 'غين', sound: 'ghain'),
    (letter: 'ف', name: 'فاء', sound: 'fa'),
    (letter: 'ق', name: 'قاف', sound: 'qaf'),
    (letter: 'ك', name: 'كاف', sound: 'kaf'),
    (letter: 'ل', name: 'لام', sound: 'lam'),
    (letter: 'م', name: 'ميم', sound: 'mim'),
    (letter: 'ن', name: 'نون', sound: 'nun'),
    (letter: 'ه', name: 'هاء', sound: 'haMarbuta'),
    (letter: 'و', name: 'واو', sound: 'waw'),
    (letter: 'ي', name: 'ياء', sound: 'ya'),
  ];
}

class LessonLevels {
  static const items = [
    (id: 'sounds', title: 'الأصوات', titleEn: 'Sounds', order: 1),
    (id: 'letters', title: 'الحروف', titleEn: 'Letters', order: 2),
    (id: 'words', title: 'الكلمات', titleEn: 'Words', order: 3),
    (id: 'sentences', title: 'الجمل', titleEn: 'Sentences', order: 4),
  ];
}

class AppPalette {
  static const colors = AppColors;
}

