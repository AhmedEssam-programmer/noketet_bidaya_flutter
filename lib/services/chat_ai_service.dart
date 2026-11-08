import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

class ChatAiService {
  ChatAiService();

  /// Pass at build time. Do not hardcode production API keys in the app bundle:
  /// flutter run --dart-define=GEMINI_API_KEY=...
  static const String apiKey = ('AIzaSyAYQ3tCg3fSx3YKNtLvURrzu-J78CpRVw4');

  /// Optional:
  /// flutter run --dart-define=GEMINI_MODEL=gemini-2.5-flash
  static const String modelName = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  late final GenerativeModel _model;

  bool _initialized = false;

  void _ensureInit() {
    if (_initialized) return;
    if (apiKey.isEmpty) {
      throw const ChatException('AI service is not configured.');
    }
    _model = GenerativeModel(model: modelName, apiKey: apiKey);

    _initialized = true;
  }

  Future<String> sendMessage(String message) async {
    final safeMessage = message.trim();
    if (safeMessage.isEmpty) {
      throw const ChatException('Message is empty.');
    }
    if (safeMessage.length > 1000) {
      throw const ChatException('Message is too long.');
    }

    _ensureInit();

    try {
      final response = await _model
          .generateContent([
            Content.text(
              '''You are a helpful assistant. Reply in Arabic when the user writes Arabic.
User message:
$safeMessage''',
            ),
          ])
          .timeout(const Duration(seconds: 30));

      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const ChatException('No response from AI service.');
      }
      return text;
    } on TimeoutException {
      throw const ChatException('Connection timed out. Please try again.');
    } on ChatException {
      rethrow;
    } catch (_) {
      throw const ChatException('Could not reach AI service.');
    }
  }
}

class ChatException implements Exception {
  const ChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

final chatAiService = ChatAiService();
