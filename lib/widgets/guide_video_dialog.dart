import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_colors.dart';

const kGuideVideoAsset = 'assets/videos/guide.mp4';

class GuideVideoButton extends StatelessWidget {
  const GuideVideoButton({
    super.key,
    required this.isAr,
    required this.onTap,
  });

  final bool isAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isAr ? 'دليل' : 'Guide';

    return Material(
      color: AppColors.white,
      elevation: 3,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuideVideoDialog extends StatefulWidget {
  const GuideVideoDialog({
    super.key,
    required this.isAr,
    this.assetPath = kGuideVideoAsset,
  });

  final bool isAr;
  final String assetPath;

  static Future<void> show(BuildContext context, {required bool isAr}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => GuideVideoDialog(isAr: isAr),
    );
  }

  @override
  State<GuideVideoDialog> createState() => _GuideVideoDialogState();
}

class _GuideVideoDialogState extends State<GuideVideoDialog> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      await rootBundle.load(widget.assetPath);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = widget.isAr
            ? 'ملف الفيديو غير موجود. أعد تشغيل التطبيق بعد إضافة guide.mp4'
            : 'Video file not found. Restart the app after adding guide.mp4';
      });
      return;
    }

    final controller = VideoPlayerController.asset(
      widget.assetPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.setLooping(false);
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
      await controller.play();
    } catch (e) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = widget.isAr
            ? 'تعذّر تشغيل الفيديو. جرّب إعادة تشغيل التطبيق.'
            : 'Could not play video. Try a full app restart.';
      });
      debugPrint('Guide video error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isAr ? 'دليل الاستخدام' : 'App Guide';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: widget.isAr ? 'إغلاق' : 'Close',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: const Color(0xFF1A1A1A),
                child: AspectRatio(
                  aspectRatio: _controller?.value.isInitialized == true
                      ? _controller!.value.aspectRatio
                      : 16 / 9,
                  child: _buildVideoContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              color: AppColors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final controller = _controller!;
    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          if (!controller.value.isPlaying)
            Container(
              decoration: const BoxDecoration(
                color: Color(0x66000000),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}
