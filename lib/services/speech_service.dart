import 'package:flutter_tts/flutter_tts.dart';

import '../models/user_settings.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();
  VoiceGender _voiceGender = VoiceGender.female;
  String? _arabicVoiceNameOrId;
  bool _isSpeaking = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _configureVoice('ar-SA');

      final voices = await _tts.getVoices;
      if (voices is List) {
        final arabic = voices.cast<dynamic>().where((v) {
          final lang = (v is Map ? v['locale'] ?? v['language'] : null)
              ?.toString();
          return lang != null && (lang == 'ar-SA' || lang.startsWith('ar'));
        }).toList();

        if (arabic.isNotEmpty) {
          final first = arabic.first;
          if (first is Map) {
            _arabicVoiceNameOrId =
                (first['name'] ?? first['id'] ?? first['identifier'])
                    ?.toString();
          }
        }
      }
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  void setVoiceGender(VoiceGender gender) {
    _voiceGender = gender;
    _tts.setPitch(gender == VoiceGender.female ? 1.2 : 0.8).catchError((_) {});
  }

  VoiceGender getVoiceGender() => _voiceGender;

  Future<void> speak(
    String text, {
    void Function()? onDone,
    String languageCode = 'ar-SA',
  }) async {
    final safeText = text.trim();
    if (safeText.isEmpty) return;

    try {
      await initialize();
      await stop();
      await _configureVoice(languageCode);

      if (languageCode.startsWith('ar') && _arabicVoiceNameOrId != null) {
        await _tts.setVoice({'name': _arabicVoiceNameOrId!, 'locale': 'ar-SA'});
      }

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        onDone?.call();
      });

      _tts.setErrorHandler((_) {
        _isSpeaking = false;
        onDone?.call();
      });

      _isSpeaking = true;
      await _tts.speak(safeText);
    } catch (_) {
      _isSpeaking = false;
      onDone?.call();
    }
  }

  Future<void> stop() async {
    _isSpeaking = false;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  bool isSpeaking() => _isSpeaking;

  Future<void> _configureVoice(String languageCode) async {
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(_voiceGender == VoiceGender.female ? 1.2 : 0.8);
  }
}

final speechService = SpeechService();
