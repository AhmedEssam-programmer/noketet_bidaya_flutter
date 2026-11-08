import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/user_progress.dart';
import '../models/user_settings.dart';
import '../services/cloud_sync_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import 'auth_controller.dart';

class UserState {
  const UserState({
    required this.progress,
    required this.settings,
    required this.cart,
    required this.isLoading,
    required this.isSyncing,
  });

  final UserProgress progress;
  final UserSettings settings;
  final List<CartItem> cart;
  final bool isLoading;
  final bool isSyncing;

  static const initial = UserState(
    progress: UserProgress.defaultValue,
    settings: UserSettings.defaultValue,
    cart: [],
    isLoading: true,
    isSyncing: false,
  );

  UserState copyWith({
    UserProgress? progress,
    UserSettings? settings,
    List<CartItem>? cart,
    bool? isLoading,
    bool? isSyncing,
  }) {
    return UserState(
      progress: progress ?? this.progress,
      settings: settings ?? this.settings,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class UserController extends Notifier<UserState> {
  ProviderSubscription<AuthState>? _authSub;
  bool _didInitialLoad = false;
  bool _disposed = false;
  bool _syncInFlight = false;

  @override
  UserState build() {
    state = UserState.initial;
    _initialize();
    return state;
  }

  Future<void> _initialize() async {
    if (_didInitialLoad) return;
    _didInitialLoad = true;

    try {
      final loaded = await Future.wait([
        storageService.getProgress(),
        storageService.getSettings(),
        storageService.getCart(),
      ]);

      if (_disposed) return;
      final progress = loaded[0] as UserProgress;
      final settings = loaded[1] as UserSettings;
      final cart = loaded[2] as List<CartItem>;

      state = state.copyWith(
        progress: progress,
        settings: settings,
        cart: cart,
        isLoading: false,
      );

      await speechService.initialize();
      speechService.setVoiceGender(settings.voiceGender);
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false);
    }

    _authSub?.close();
    _authSub = ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (!state.isLoading && next.isAuthenticated) {
        _syncFromCloud();
      }
    });

    ref.onDispose(() {
      _disposed = true;
      _authSub?.close();
    });
  }

  Future<void> _syncFromCloud() async {
    if (_syncInFlight) return;
    _syncInFlight = true;
    state = state.copyWith(isSyncing: true);
    late final CloudDownloadResult result;
    try {
      result = await cloudSyncService.downloadAll();
    } finally {
      _syncInFlight = false;
      if (!_disposed) state = state.copyWith(isSyncing: false);
    }

    if (_disposed) return;

    if (result.success) {
      final downloadedProgress = result.progress;
      final newProgress = downloadedProgress == null
          ? state.progress
          : downloadedProgress.copyWith(
              wordGameCompleted: state.progress.wordGameCompleted,
              wordGameCoins: state.progress.wordGameCoins,
              wordGameHintsUsed: state.progress.wordGameHintsUsed,
              wordGameStreak: state.progress.wordGameStreak,
              lastWordGameDay: state.progress.lastWordGameDay,
            );
      final newSettings = result.settings ?? state.settings;
      final newCart = result.items ?? state.cart;

      state = state.copyWith(
        progress: newProgress,
        settings: newSettings,
        cart: newCart,
      );

      await Future.wait([
        storageService.saveProgress(newProgress),
        storageService.saveSettings(newSettings),
        storageService.saveCart(newCart),
      ]);

      speechService.setVoiceGender(newSettings.voiceGender);
    }
  }

  Future<CloudSyncResult> syncToCloud() async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      return const CloudSyncResult(success: false, error: 'Not authenticated');
    }

    if (_syncInFlight) {
      return const CloudSyncResult(
        success: false,
        error: 'Sync already running',
      );
    }

    _syncInFlight = true;
    state = state.copyWith(isSyncing: true);
    try {
      final result = await cloudSyncService.syncAll(
        state.progress,
        state.settings,
        state.cart,
      );
      return result;
    } finally {
      _syncInFlight = false;
      if (!_disposed) state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> updateProgress(UserProgress progress) async {
    state = state.copyWith(progress: progress);
    await storageService.saveProgress(progress);

    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      unawaited(cloudSyncService.uploadProgress(progress));
    }
  }

  Future<void> patchProgress({
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
  }) async {
    final next = state.progress.copyWith(
      soundsCompleted: soundsCompleted,
      lettersCompleted: lettersCompleted,
      wordsCompleted: wordsCompleted,
      sentencesCompleted: sentencesCompleted,
      wordGameCompleted: wordGameCompleted,
      wordGameCoins: wordGameCoins,
      wordGameHintsUsed: wordGameHintsUsed,
      wordGameStreak: wordGameStreak,
      lastWordGameDay: lastWordGameDay,
      totalStars: totalStars,
      currentLevel: currentLevel,
      lastLessonId: lastLessonId,
    );
    await updateProgress(next);
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = state.copyWith(settings: settings);
    await storageService.saveSettings(settings);
    speechService.setVoiceGender(settings.voiceGender);

    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      unawaited(cloudSyncService.uploadSettings(settings));
    }
  }

  Future<void> patchSettings({
    VoiceGender? voiceGender,
    bool? voiceEnabled,
    bool? soundEnabled,
    AppFontSize? fontSize,
    AppLanguage? language,
  }) async {
    final next = state.settings.copyWith(
      voiceGender: voiceGender,
      voiceEnabled: voiceEnabled,
      soundEnabled: soundEnabled,
      fontSize: fontSize,
      language: language,
    );
    await updateSettings(next);
  }

  Future<void> addToCart(String productId) async {
    if (productId.trim().isEmpty) return;
    final existing = state.cart.where((i) => i.productId == productId).toList();
    late final List<CartItem> next;
    if (existing.isNotEmpty) {
      next = state.cart
          .map(
            (i) => i.productId == productId
                ? i.copyWith(quantity: i.quantity + 1)
                : i,
          )
          .toList();
    } else {
      next = [...state.cart, CartItem(productId: productId, quantity: 1)];
    }

    state = state.copyWith(cart: next);
    await storageService.saveCart(next);

    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      unawaited(cloudSyncService.uploadCart(next));
    }
  }

  Future<void> removeFromCart(String productId) async {
    final next = state.cart.where((i) => i.productId != productId).toList();
    state = state.copyWith(cart: next);
    await storageService.saveCart(next);

    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      unawaited(cloudSyncService.uploadCart(next));
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(cart: []);
    await storageService.saveCart(const []);

    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      unawaited(cloudSyncService.uploadCart(const []));
    }
  }

  Future<void> resetProgress() async {
    await updateProgress(UserProgress.defaultValue);
  }
}

final userControllerProvider = NotifierProvider<UserController, UserState>(
  UserController.new,
);
