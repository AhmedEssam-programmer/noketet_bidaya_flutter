import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/user_progress.dart';
import '../models/user_settings.dart';
import '../utils/constants.dart';

class StorageService {
  Future<UserProgress> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.userProgress);
    if (raw == null) return UserProgress.defaultValue;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProgress.fromJson({
        ...UserProgress.defaultValue.toJson(),
        ...json,
      });
    } catch (_) {
      // Corrupt local cache should not crash startup; reset to a safe default.
      return UserProgress.defaultValue;
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        StorageKeys.userProgress,
        jsonEncode(progress.toJson()),
      );
    } catch (_) {}
  }

  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.userSettings);
    if (raw == null) return UserSettings.defaultValue;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserSettings.fromJson({
        ...UserSettings.defaultValue.toJson(),
        ...json,
      });
    } catch (_) {
      // Invalid settings can happen after app upgrades; defaults keep UI usable.
      return UserSettings.defaultValue;
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        StorageKeys.userSettings,
        jsonEncode(settings.toJson()),
      );
    } catch (_) {}
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.cartItems);
    if (raw == null) return [];
    try {
      final json = jsonDecode(raw) as List<dynamic>;
      return json
          .whereType<Map>()
          .map((e) => CartItem.fromJson(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        StorageKeys.cartItems,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.userProgress);
      await prefs.remove(StorageKeys.userSettings);
      await prefs.remove(StorageKeys.cartItems);
    } catch (_) {}
  }
}

final storageService = StorageService();
