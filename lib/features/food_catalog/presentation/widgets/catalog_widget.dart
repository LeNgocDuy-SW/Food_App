import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CataLogWidget extends StatelessWidget {
  final String title;
  final String image;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const CataLogWidget({
    super.key,
    required this.title,
    required this.image,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textCol = textColor ?? AppColors.primaryRed;
    // Highlight background if selected
    final bg = isSelected
        ? textCol.withValues(alpha: 0.18)
        : (backgroundColor ?? AppColors.primaryRed.withValues(alpha: 0.08));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: bg,
          border: Border.all(
            color: isSelected ? textCol : textCol.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  image,
                  height: 32,
                  width: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
