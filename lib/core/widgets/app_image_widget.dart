import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
            ),
          );
        },
      );
    } else if (imagePath.startsWith('data:image')) {
      try {
        final commaIndex = imagePath.indexOf(',');
        final base64String = commaIndex != -1
            ? imagePath.substring(commaIndex + 1)
            : imagePath;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
          ),
        );
      }
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
            ),
          );
        },
      );
    }
  }
}
