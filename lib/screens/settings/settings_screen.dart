import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/lessons.dart';
import '../../models/user_settings.dart';
import '../../services/speech_service.dart';
import '../../state/user_controller.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = 'Settings';
  static const routePath = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _settingsActionBusy = false;
  bool _testingVoice = false;
  bool _resettingProgress = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final controller = ref.read(userControllerProvider.notifier);
    final isAr = user.settings.language == AppLanguage.ar;

    Future<void> setGender(VoiceGender gender) async {
      if (_settingsActionBusy) return;
      setState(() => _settingsActionBusy = true);
      try {
        await controller.patchSettings(voiceGender: gender);
        speechService.setVoiceGender(gender);
        if (user.settings.voiceEnabled) {
          await speechService.speak(
            gender == VoiceGender.female ? 'صوت أنثوي' : 'صوت ذكر',
          );
        }
      } catch (_) {
        if (mounted) _showError(isAr);
      } finally {
        if (mounted) setState(() => _settingsActionBusy = false);
      }
    }

    Future<void> setLanguage(AppLanguage lang) async {
      if (_settingsActionBusy) return;
      setState(() => _settingsActionBusy = true);
      try {
        await controller.patchSettings(language: lang);
        if (user.settings.voiceEnabled) {
          await speechService.speak(
            lang == AppLanguage.ar ? 'العربية' : 'English',
          );
        }
      } catch (_) {
        if (mounted) _showError(isAr);
      } finally {
        if (mounted) setState(() => _settingsActionBusy = false);
      }
    }

    Future<void> testVoice() async {
      if (_testingVoice) return;
      setState(() => _testingVoice = true);
      final text = user.settings.language == AppLanguage.ar
          ? 'مرحباً، هذا اختبار للصوت'
          : 'Hello, this is a voice test';
      try {
        await speechService.speak(text);
      } catch (_) {
        if (mounted) _showError(isAr);
      } finally {
        if (mounted) setState(() => _testingVoice = false);
      }
    }

    Future<void> resetProgress() async {
      if (_resettingProgress) return;
      setState(() => _resettingProgress = true);
      try {
        await controller.resetProgress();
        if (user.settings.voiceEnabled) {
          await speechService.speak('تم إعادة ضبط التقدم');
        }
      } catch (_) {
        if (mounted) _showError(isAr);
      } finally {
        if (mounted) setState(() => _resettingProgress = false);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'الإعدادات' : 'Settings',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: isAr ? 'اللغة' : 'Language',
                    child: Row(
                      children: [
                        Expanded(
                          child: _ChoiceButton(
                            active: user.settings.language == AppLanguage.ar,
                            label: 'العربية',
                            onTap: () => setLanguage(AppLanguage.ar),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ChoiceButton(
                            active: user.settings.language == AppLanguage.en,
                            label: 'English',
                            onTap: () => setLanguage(AppLanguage.en),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: isAr ? 'الصوت' : 'Voice',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'تفعيل الصوت' : 'Enable Voice',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                            ),
                            Switch(
                              value: user.settings.voiceEnabled,
                              onChanged: _settingsActionBusy
                                  ? null
                                  : (v) async {
                                      setState(
                                        () => _settingsActionBusy = true,
                                      );
                                      try {
                                        await controller.patchSettings(
                                          voiceEnabled: v,
                                        );
                                      } catch (_) {
                                        if (mounted) _showError(isAr);
                                      } finally {
                                        if (mounted) {
                                          setState(
                                            () => _settingsActionBusy = false,
                                          );
                                        }
                                      }
                                    },
                              activeTrackColor: AppColors.primaryLight,
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _GenderButton(
                                active:
                                    user.settings.voiceGender ==
                                    VoiceGender.female,
                                icon: Icons.female,
                                label: isAr ? 'أنثى' : 'Female',
                                onTap: () => setGender(VoiceGender.female),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GenderButton(
                                active:
                                    user.settings.voiceGender ==
                                    VoiceGender.male,
                                icon: Icons.male,
                                label: isAr ? 'ذكر' : 'Male',
                                onTap: () => setGender(VoiceGender.male),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _testingVoice ? null : testVoice,
                            child: Text(
                              isAr ? 'اختبار الصوت' : 'Test Voice',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: isAr ? 'تقدمك' : 'Your Progress',
                    child: Column(
                      children: [
                        _InfoRow(
                          label: isAr ? 'النجوم' : 'Stars',
                          value: '${user.progress.totalStars}',
                        ),
                        _InfoRow(
                          label: isAr ? 'الأصوات' : 'Sounds',
                          value:
                              '${user.progress.soundsCompleted.length}/${soundsLessons.length}',
                        ),
                        _InfoRow(
                          label: isAr ? 'الحروف' : 'Letters',
                          value:
                              '${user.progress.lettersCompleted.length}/${letterWritingLessons.length}',
                        ),
                        _InfoRow(
                          label: isAr ? 'الكلمات' : 'Words',
                          value:
                              '${user.progress.wordsCompleted.length}/${wordsLessons.length}',
                        ),
                        _InfoRow(
                          label: isAr ? 'الجمل' : 'Sentences',
                          value:
                              '${user.progress.sentencesCompleted.length}/${sentencesLessons.length}',
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: isAr ? 'إدارة البيانات' : 'Data Management',
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _resettingProgress ? null : resetProgress,
                        child: Text(
                          isAr ? 'إعادة ضبط التقدم' : 'Reset Progress',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context.pop(),
                  child: Text(
                    isAr ? 'رجوع' : 'Back',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(bool isAr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAr ? 'حدث خطأ، حاول مرة أخرى' : 'Something went wrong'),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.active,
    required this.label,
    required this.onTap,
  });
  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: active ? AppColors.white : AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
