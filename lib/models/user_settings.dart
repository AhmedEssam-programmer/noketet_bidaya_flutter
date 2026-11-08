enum VoiceGender { female, male }

enum AppLanguage { ar, en }

enum AppFontSize { small, medium, large }

class UserSettings {
  const UserSettings({
    required this.voiceGender,
    required this.voiceEnabled,
    required this.soundEnabled,
    required this.fontSize,
    required this.language,
  });

  final VoiceGender voiceGender;
  final bool voiceEnabled;
  final bool soundEnabled;
  final AppFontSize fontSize;
  final AppLanguage language;

  static const defaultValue = UserSettings(
    voiceGender: VoiceGender.female,
    voiceEnabled: true,
    soundEnabled: true,
    fontSize: AppFontSize.large,
    language: AppLanguage.ar,
  );

  UserSettings copyWith({
    VoiceGender? voiceGender,
    bool? voiceEnabled,
    bool? soundEnabled,
    AppFontSize? fontSize,
    AppLanguage? language,
  }) {
    return UserSettings(
      voiceGender: voiceGender ?? this.voiceGender,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
    'voiceGender': voiceGender.name,
    'voiceEnabled': voiceEnabled,
    'soundEnabled': soundEnabled,
    'fontSize': fontSize.name,
    'language': language.name,
  };

  static UserSettings fromJson(Map<String, dynamic> json) {
    final voiceGender = VoiceGender.values.firstWhere(
      (v) => v.name == (json['voiceGender'] ?? 'female'),
      orElse: () => VoiceGender.female,
    );
    final fontSize = AppFontSize.values.firstWhere(
      (v) => v.name == (json['fontSize'] ?? 'large'),
      orElse: () => AppFontSize.large,
    );
    final language = AppLanguage.values.firstWhere(
      (v) => v.name == (json['language'] ?? 'ar'),
      orElse: () => AppLanguage.ar,
    );

    return UserSettings(
      voiceGender: voiceGender,
      voiceEnabled: _boolValue(json['voiceEnabled'], fallback: true),
      soundEnabled: _boolValue(json['soundEnabled'], fallback: true),
      fontSize: fontSize,
      language: language,
    );
  }

  static bool _boolValue(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return fallback;
  }
}
