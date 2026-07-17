import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_app/core/constants/app_colors.dart';
import '../../data/favorite_manager.dart';
import 'package:food_app/core/router/app_router.dart';

class FoodCardWidget extends StatefulWidget {
  final String title;
  final String image;
  final String price;
  final String rating;
  final String? soldCount;
  final bool isHot;
  final VoidCallback? onTap;

  const FoodCardWidget({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    this.soldCount,
    this.isHot = false,
    this.onTap,
  });

  @override
  State<FoodCardWidget> createState() => _FoodCardWidgetState();
}

class _FoodCardWidgetState extends State<FoodCardWidget> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ??
          () => context.push(
                AppRouter.foodDetail,
                extra: {
                  'title': widget.title,
                  'image': widget.image,
                  'price': widget.price,
                  'rating': widget.rating,
                  'prepTime': null,
                },
              ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: widget.image.startsWith('http')
                      ? Image.network(
                          widget.image,
                          height: 135,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 135,
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 135,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      : Image.asset(
                          widget.image,
                          height: 135,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // HOT Badge
                if (widget.isHot)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.whatshot, color: Colors.white, size: 11),
                          SizedBox(width: 2),
                          Text(
                            'HOT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Favorite Heart Button (Top Right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<List<FavoriteMeal>>(
                    valueListenable: FavoriteManager.instance.favoritesNotifier,
                    builder: (context, favorites, child) {
                      final isFav = FavoriteManager.instance.isFavorite(widget.title);
                      return GestureDetector(
                        onTap: () {
                          final category = widget.title.contains('Bánh Mì') || widget.title.contains('Bánh mỳ')
                              ? 'Bánh mỳ'
                              : 'Phở & Bún';
                          FavoriteManager.instance.toggleFavorite(
                            FavoriteMeal(
                              title: widget.title,
                              image: widget.image,
                              price: widget.price,
                              rating: widget.rating,
                              category: category,
                            ),
                          );
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !isFav
                                    ? 'Đã thêm "${widget.title}" vào yêu thích.'
                                    : 'Đã xóa "${widget.title}" khỏi yêu thích.',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: AppColors.primaryRed,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Info padding
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Rating and Sales Count Row
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        widget.rating,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.soldCount ?? 'Đã bán 50+',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and Add button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

