import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import 'food_detail_page.dart';

class FavoriteFoodItem {
  final String id;
  final String title;
  final String image;
  final String category; // 'Bánh mỳ', 'Phở & Bún'
  final String rating;
  final String storeName;
  final String prepTime;
  final String distance;
  bool isFavorite;

  FavoriteFoodItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.rating,
    required this.storeName,
    required this.prepTime,
    required this.distance,
    this.isFavorite = true,
  });
}

class FavoritePage extends StatefulWidget {
  final VoidCallback onBack;

  const FavoritePage({super.key, required this.onBack});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Phở & Bún', 'Bánh mỳ'];

  late List<FavoriteFoodItem> _favoriteItems;

  @override
  void initState() {
    super.initState();
    _favoriteItems = [
      FavoriteFoodItem(
        id: '1',
        title: 'Bánh Mì - Đặc Sản',
        image: 'assets/image/cooking_burger.png',
        category: 'Bánh mỳ',
        rating: '4.8',
        storeName: 'Sà Bì Chưởng- Hà Nội',
        prepTime: '25-30 phút',
        distance: '1.2 km',
      ),
      FavoriteFoodItem(
        id: '2',
        title: 'Bún Bò Huế',
        image: 'assets/image/hamberger.png',
        category: 'Phở & Bún',
        rating: '4.8',
        storeName: 'Bún Chả Cửa Đông - Hoàn Kiếm',
        prepTime: '25-30 phút',
        distance: '1.2 km',
      ),
      FavoriteFoodItem(
        id: '3',
        title: 'Phở Gà Ta',
        image: 'assets/image/pho_ga.png',
        category: 'Phở & Bún',
        rating: '4.9',
        storeName: 'Phở Gà Lâm - Nam Ngư',
        prepTime: '15-20 phút',
        distance: '0.8 km',
      ),
      FavoriteFoodItem(
        id: '4',
        title: 'Bánh Mỳ Heo Quay',
        image: 'assets/image/banner.png',
        category: 'Bánh mỳ',
        rating: '4.7',
        storeName: 'Bánh Mì Phố - Bà Triệu',
        prepTime: '10-15 phút',
        distance: '1.5 km',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on the selected category tag
    final filteredItems = _favoriteItems.where((item) {
      if (_selectedCategory == 'Tất cả') return item.isFavorite;
      return item.isFavorite && item.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Món ăn yêu thích',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BackgroundContainer(
        opacity: 1.0,
        child: Column(
          children: [
            // Category Filter Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryRed : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryRed
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Favorites List
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có món ăn yêu thích nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedCategory != 'Tất cả') ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'Tất cả';
                                });
                              },
                              child: const Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildFoodCard(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FavoriteFoodItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailPage(
              title: item.title,
              image: item.image,
              price: "35.000đ",
              rating: item.rating,
              prepTime: item.prepTime,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image + Heart Toggle Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.asset(
                    item.image,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Favorite toggle heart button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      _toggleFavorite(item);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        item.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.primaryRed,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32), // Dark Green
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              item.rating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Storefront name row
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.storeName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Info row (prep time and distance)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.prepTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.distance,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
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

  void _toggleFavorite(FavoriteFoodItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });

    final snackBar = SnackBar(
      content: Text(
        item.isFavorite
            ? 'Đã thêm "${item.title}" vào yêu thích.'
            : 'Đã xóa "${item.title}" khỏi yêu thích.',
      ),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Hoàn tác',
        textColor: Colors.amber,
        onPressed: () {
          setState(() {
            item.isFavorite = !item.isFavorite;
          });
        },
      ),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
