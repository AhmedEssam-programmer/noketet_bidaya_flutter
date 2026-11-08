import 'dart:async';

import '../models/cart_item.dart';
import '../models/user_progress.dart';
import '../models/user_settings.dart';
import 'supabase_client.dart';

class CloudSyncResult {
  const CloudSyncResult({required this.success, this.error});
  final bool success;
  final String? error;
}

class CloudDownloadResult {
  const CloudDownloadResult({
    required this.success,
    this.progress,
    this.settings,
    this.items,
    this.error,
  });

  final bool success;
  final UserProgress? progress;
  final UserSettings? settings;
  final List<CartItem>? items;
  final String? error;
}

class CloudSyncService {
  static const _timeout = Duration(seconds: 15);
  String? _userId;

  void setUserId(String? userId) {
    _userId = userId;
  }

  String? get userId => _userId;

  bool get isAuthenticated => _userId != null;

  Future<CloudSyncResult> uploadProgress(UserProgress progress) async {
    final userId = _userId;
    if (userId == null) {
      return const CloudSyncResult(success: false, error: 'Not authenticated');
    }

    try {
      await AppSupabase.client
          .from('user_progress')
          .upsert({
            'id': userId,
            'sounds_completed': progress.soundsCompleted,
            'letters_completed': progress.lettersCompleted,
            'words_completed': progress.wordsCompleted,
            'sentences_completed': progress.sentencesCompleted,
            'total_stars': progress.totalStars,
            'current_level': progress.currentLevel,
            'last_lesson_id': progress.lastLessonId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .timeout(_timeout);

      return const CloudSyncResult(success: true);
    } catch (e) {
      return CloudSyncResult(success: false, error: e.toString());
    }
  }

  Future<(bool success, UserProgress? progress, String? error)>
  downloadProgress() async {
    final userId = _userId;
    if (userId == null) return (false, null, 'Not authenticated');

    try {
      final data = await AppSupabase.client
          .from('user_progress')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(_timeout);

      if (data == null) return (true, null, null);

      final progress = UserProgress(
        soundsCompleted: _stringList(data['sounds_completed']),
        lettersCompleted: _stringList(data['letters_completed']),
        wordsCompleted: _stringList(data['words_completed']),
        sentencesCompleted: _stringList(data['sentences_completed']),
        wordGameCompleted: UserProgress.defaultValue.wordGameCompleted,
        wordGameCoins: UserProgress.defaultValue.wordGameCoins,
        wordGameHintsUsed: UserProgress.defaultValue.wordGameHintsUsed,
        wordGameStreak: UserProgress.defaultValue.wordGameStreak,
        lastWordGameDay: UserProgress.defaultValue.lastWordGameDay,
        totalStars: _intValue(data['total_stars']),
        currentLevel: (data['current_level'] as String?) ?? 'sounds',
        lastLessonId: data['last_lesson_id'] as String?,
      );

      return (true, progress, null);
    } catch (e) {
      return (false, null, e.toString());
    }
  }

  Future<CloudSyncResult> uploadSettings(UserSettings settings) async {
    final userId = _userId;
    if (userId == null) {
      return const CloudSyncResult(success: false, error: 'Not authenticated');
    }

    try {
      await AppSupabase.client
          .from('user_settings')
          .upsert({
            'id': userId,
            'voice_gender': settings.voiceGender.name,
            'voice_enabled': settings.voiceEnabled,
            'sound_enabled': settings.soundEnabled,
            'font_size': settings.fontSize.name,
            'language': settings.language.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .timeout(_timeout);

      return const CloudSyncResult(success: true);
    } catch (e) {
      return CloudSyncResult(success: false, error: e.toString());
    }
  }

  Future<(bool success, UserSettings? settings, String? error)>
  downloadSettings() async {
    final userId = _userId;
    if (userId == null) return (false, null, 'Not authenticated');

    try {
      final data = await AppSupabase.client
          .from('user_settings')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(_timeout);

      if (data == null) return (true, null, null);

      final settings = UserSettings.fromJson({
        'voiceGender': data['voice_gender'] ?? 'female',
        'voiceEnabled': data['voice_enabled'] ?? true,
        'soundEnabled': data['sound_enabled'] ?? true,
        'fontSize': data['font_size'] ?? 'large',
        'language': data['language'] ?? 'ar',
      });

      return (true, settings, null);
    } catch (e) {
      return (false, null, e.toString());
    }
  }

  Future<CloudSyncResult> uploadCart(List<CartItem> items) async {
    final userId = _userId;
    if (userId == null) {
      return const CloudSyncResult(success: false, error: 'Not authenticated');
    }

    try {
      await AppSupabase.client
          .from('user_cart')
          .upsert({
            'id': userId,
            'items': items.map((e) => e.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .timeout(_timeout);

      return const CloudSyncResult(success: true);
    } catch (e) {
      return CloudSyncResult(success: false, error: e.toString());
    }
  }

  Future<(bool success, List<CartItem>? items, String? error)>
  downloadCart() async {
    final userId = _userId;
    if (userId == null) return (false, null, 'Not authenticated');

    try {
      final data = await AppSupabase.client
          .from('user_cart')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(_timeout);

      if (data == null) return (true, <CartItem>[], null);

      final raw = data['items'];
      final items = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => CartItem.fromJson(e.cast<String, dynamic>()))
                .toList()
          : <CartItem>[];
      return (true, items, null);
    } catch (e) {
      return (false, null, e.toString());
    }
  }

  Future<CloudSyncResult> syncAll(
    UserProgress localProgress,
    UserSettings localSettings,
    List<CartItem> localCart,
  ) async {
    final pr = await uploadProgress(localProgress);
    if (!pr.success) return pr;

    final sr = await uploadSettings(localSettings);
    if (!sr.success) return sr;

    final cr = await uploadCart(localCart);
    if (!cr.success) return cr;

    return const CloudSyncResult(success: true);
  }

  Future<CloudDownloadResult> downloadAll() async {
    final p = await downloadProgress();
    if (!p.$1) return CloudDownloadResult(success: false, error: p.$3);

    final s = await downloadSettings();
    if (!s.$1) return CloudDownloadResult(success: false, error: s.$3);

    final c = await downloadCart();
    if (!c.$1) return CloudDownloadResult(success: false, error: c.$3);

    return CloudDownloadResult(
      success: true,
      progress: p.$2,
      settings: s.$2,
      items: c.$2,
    );
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

final cloudSyncService = CloudSyncService();
