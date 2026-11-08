import 'package:flutter/material.dart';

import '../data/products.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.total,
    this.color = AppColors.primary,
    this.onTap,
  });

  final String title;
  final String icon;
  final int progress;
  final int total;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0
        ? (progress / total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
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
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 12,
                color: AppColors.lightGray,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(color: color),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$progress / $total',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.image,
    required this.onTap,
    required this.onAddToCart,
  });

  final String name;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2E7D32),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProductEmojiBubble(image: image, size: 100, fontSize: 50),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                onTap: onAddToCart,
                borderRadius: BorderRadius.circular(25),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  child: Text(
                    'إضافة',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
}

class ProductEmojiBubble extends StatelessWidget {
  const ProductEmojiBubble({
    super.key,
    required this.image,
    this.size = 56,
    this.fontSize = 30,
    this.backgroundColor = const Color(0xFFF0F7F4),
  });

  final String image;
  final double size;
  final double fontSize;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          productEmojiForImage(image),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            height: 1,
            fontFamilyFallback: const [
              'Apple Color Emoji',
              'Segoe UI Emoji',
              'Noto Color Emoji',
            ],
          ),
        ),
      ),
    );
  }
}
