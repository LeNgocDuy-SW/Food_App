import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../data/favorite_manager.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/widgets/app_image_widget.dart';

class FavoritePage extends StatefulWidget {
  final VoidCallback onBack;

  const FavoritePage({super.key, required this.onBack});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Phở & Bún', 'Bánh mỳ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BackgroundContainer(
        opacity: 0.15,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onBack,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                        const Text(
                          'Yêu thích',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryRed : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryRed
                                    : Colors.grey.withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryRed.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Favorites List listening to FavoriteManager reactively
              Expanded(
                child: ValueListenableBuilder<List<FavoriteMeal>>(
                  valueListenable: FavoriteManager.instance.favoritesNotifier,
                  builder: (context, favorites, child) {
                    final filteredItems = favorites.where((item) {
                      if (_selectedCategory == 'Tất cả') return true;
                      return item.category == _selectedCategory;
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Không có món ăn nào yêu thích',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedCategory != 'Tất cả') ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = 'Tất cả';
                                  });
                                },
                                child: const Text(
                                  'Xem tất cả món',
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildFoodCard(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCard(FavoriteMeal item) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRouter.foodDetail,
          extra: {
            'title': item.title,
            'image': item.image,
            'price': item.price,
            'rating': item.rating,
            'prepTime': item.prepTime,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 90,
                height: 90,
                child: AppImageWidget(
                  imagePath: item.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item.rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${item.prepTime}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Side Heart (Click to remove from favorites)
            GestureDetector(
              onTap: () {
                FavoriteManager.instance.toggleFavorite(item);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa "${item.title}" khỏi yêu thích.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.primaryRed,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
