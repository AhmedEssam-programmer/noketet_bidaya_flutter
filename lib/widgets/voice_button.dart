import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum VoiceButtonSize { small, medium, large }

enum VoiceButtonVariant { primary, secondary, outline }

class VoiceButton extends StatelessWidget {
  const VoiceButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.size = VoiceButtonSize.medium,
    this.variant = VoiceButtonVariant.primary,
    this.disabled = false,
  });

  final VoidCallback onPressed;
  final String label;
  final String? icon;
  final VoiceButtonSize size;
  final VoiceButtonVariant variant;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final (padV, padH, radius, fontSize) = switch (size) {
      VoiceButtonSize.small => (10.0, 16.0, 12.0, 14.0),
      VoiceButtonSize.medium => (14.0, 24.0, 16.0, 16.0),
      VoiceButtonSize.large => (18.0, 32.0, 20.0, 20.0),
    };

    final isOutline = variant == VoiceButtonVariant.outline;
    final bg = switch (variant) {
      VoiceButtonVariant.primary => AppColors.primary,
      VoiceButtonVariant.secondary => AppColors.secondary,
      VoiceButtonVariant.outline => Colors.transparent,
    };

    final fg = isOutline ? AppColors.primary : AppColors.white;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: isOutline
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Text(icon!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: disabled ? AppColors.lightGray : fg,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LargeVoiceButton extends StatelessWidget {
  const LargeVoiceButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, minHeight: 140),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.white, size: 56),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
