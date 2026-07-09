import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../widgets/banner_widget.dart';
import 'package:food_app/features/food_catalog/presentation/widgets/catalog_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/food_card_widget.dart';
import 'package:food_app/core/services/api_service.dart';

class MealData {
  final String id;
  final String name;
  final String image;
  final String price;
  final String rating;
  final String soldCount;
  final bool isHot;

  MealData({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.soldCount,
    required this.isHot,
  });
}

class FoodHomePage extends StatefulWidget {
  const FoodHomePage({super.key});

  @override
  State<FoodHomePage> createState() => _FoodHomePageState();
}

class _FoodHomePageState extends State<FoodHomePage> {
  final ApiService _apiService = ApiService();
  String _selectedCategory = 'Tất cả';
  final Map<String, List<MealData>> _mealsByCategory = {};
  bool _isLoading = false;
  bool _hasError = false;

  final Map<String, List<MealData>> _localMeals = {
    'Bánh mỳ': [
      MealData(
        id: 'bm1',
        name: 'Bánh Mỳ Heo Quay',
        image: 'assets/image/pho_ga.png',
        price: '30.000đ',
        rating: '4.9',
        soldCount: 'Đã bán 150+',
        isHot: true,
      ),
      MealData(
        id: 'bm2',
        name: 'Bánh Mỳ Chả Lụa',
        image: 'assets/image/pho_ga.png',
        price: '20.000đ',
        rating: '4.5',
        soldCount: 'Đã bán 80+',
        isHot: false,
      ),
      MealData(
        id: 'bm3',
        name: 'Bánh Mỳ Đặc Biệt',
        image: 'assets/image/pho_ga.png',
        price: '25.000đ',
        rating: '4.7',
        soldCount: 'Đã bán 400+',
        isHot: true,
      ),
    ],
    'Phở gà': [
      MealData(
        id: 'pg1',
        name: 'Phở Gà Đùi Đặc Biệt',
        image: 'assets/image/pho_ga.png',
        price: '65.000đ',
        rating: '4.9',
        soldCount: 'Đã bán 95+',
        isHot: true,
      ),
      MealData(
        id: 'pg2',
        name: 'Phở Gà Ta',
        image: 'assets/image/hamberger.png',
        price: '55.000đ',
        rating: '4.8',
        soldCount: 'Đã bán 180+',
        isHot: false,
      ),
    ],
    'Hamberger': [
      MealData(
        id: 'hb1',
        name: 'Hamburger Bò Double Cheese',
        image: 'assets/image/hamberger.png',
        price: '55.000đ',
        rating: '4.9',
        soldCount: 'Đã bán 320+',
        isHot: true,
      ),
      MealData(
        id: 'hb2',
        name: 'Hamburger Bò',
        image: 'assets/image/banner.png',
        price: '45.000đ',
        rating: '4.8',
        soldCount: 'Đã bán 250+',
        isHot: false,
      ),
      MealData(
        id: 'hb3',
        name: 'Hamburger Gà Giòn',
        image: 'assets/image/hamberger.png',
        price: '40.000đ',
        rating: '4.6',
        soldCount: 'Đã bán 110+',
        isHot: false,
      ),
    ],
    'Bún bò Huế': [
      MealData(
        id: 'bb1',
        name: 'Bún Bò Huế Đặc Biệt',
        image: 'assets/image/pho_ga.png',
        price: '65.000đ',
        rating: '4.9',
        soldCount: 'Đã bán 275+',
        isHot: true,
      ),
      MealData(
        id: 'bb2',
        name: 'Bún Bò Huế Giò Gân',
        image: 'assets/image/pho_ga.png',
        price: '50.000đ',
        rating: '4.7',
        soldCount: 'Đã bán 130+',
        isHot: false,
      ),
    ],
    'Gà rán': [
      MealData(
        id: 'gr1',
        name: 'Mẹt Gà Rán Giòn Rụm',
        image: 'assets/image/cooking_burger.png',
        price: '99.000đ',
        rating: '4.9',
        soldCount: 'Đã bán 480+',
        isHot: true,
      ),
      MealData(
        id: 'gr2',
        name: 'Cánh Gà Sốt Chua Ngọt',
        image: 'assets/image/cooking_burger.png',
        price: '45.000đ',
        rating: '4.6',
        soldCount: 'Đã bán 190+',
        isHot: false,
      ),
    ],
    'Trà sữa': [
      MealData(
        id: 'ts1',
        name: 'Trà Sữa Trân Châu Hoàng Gia',
        image: 'assets/image/cooking_burger.png',
        price: '35.000đ',
        rating: '4.9',
        soldCount: 'Đã bán 600+',
        isHot: true,
      ),
      MealData(
        id: 'ts2',
        name: 'Trà Sữa Matcha Đậu Đỏ',
        image: 'assets/image/cooking_burger.png',
        price: '38.000đ',
        rating: '4.7',
        soldCount: 'Đã bán 240+',
        isHot: false,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _localMeals.forEach((category, list) {
      _mealsByCategory[category] = _sortHotItemsFirst(list);
    });
    _loadAllApiData();
  }

  Future<void> _loadAllApiData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        _apiService.fetchSeafoodMeals(),
        _apiService.fetchBeefMeals(),
      ]);

      final rawSeafood = results[0];
      final rawBeef = results[1];

      final mappedSeafood = rawSeafood.map((meal) {
        final String id = meal['idMeal'] ?? '0';
        final String name = meal['strMeal'] ?? '';
        final String image = meal['strMealThumb'] ?? '';
        final int idNum = int.tryParse(id) ?? 0;
        return MealData(
          id: id,
          name: name,
          image: image,
          price: '${(60 + (idNum % 5) * 15).toString()}.000đ',
          rating: (4.5 + (idNum % 5) * 0.1).toStringAsFixed(1),
          soldCount: 'Đã bán ${(idNum * 13) % 210 + 45}+',
          isHot: (idNum % 3 == 0),
        );
      }).toList();

      final mappedBeef = rawBeef.map((meal) {
        final String id = meal['idMeal'] ?? '0';
        final String name = meal['strMeal'] ?? '';
        final String image = meal['strMealThumb'] ?? '';
        final int idNum = int.tryParse(id) ?? 0;
        return MealData(
          id: id,
          name: name,
          image: image,
          price: '${(80 + (idNum % 5) * 15).toString()}.000đ',
          rating: (4.6 + (idNum % 5) * 0.1).toStringAsFixed(1),
          soldCount: 'Đã bán ${(idNum * 17) % 180 + 35}+',
          isHot: (idNum % 2 == 0),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _mealsByCategory['Hải sản'] = _sortHotItemsFirst(mappedSeafood);
        _mealsByCategory['Thịt bò'] = _sortHotItemsFirst(mappedBeef);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onCategoryTapped(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });

    if ((categoryName == 'Hải sản' || categoryName == 'Thịt bò' || categoryName == 'Tất cả') &&
        (_mealsByCategory['Hải sản'] == null || _mealsByCategory['Thịt bò'] == null) &&
        !_isLoading) {
      _loadAllApiData();
    }
  }

  List<MealData> _sortHotItemsFirst(List<MealData> meals) {
    final hot = meals.where((m) => m.isHot).toList();
    final regular = meals.where((m) => !m.isHot).toList();
    return [...hot, ...regular];
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Tất cả',
        'image': 'assets/image/banner.png',
        'bg': const Color(0xFFE8EAF6),
        'text': const Color(0xFF3F51B5),
      },
      {
        'title': 'Bánh mỳ',
        'image': 'assets/image/banner.png',
        'bg': const Color(0xFFFFF3E0),
        'text': const Color(0xFFE65100),
      },
      {
        'title': 'Phở gà',
        'image': 'assets/image/pho_ga.png',
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF2E7D32),
      },
      {
        'title': 'Hamberger',
        'image': 'assets/image/hamberger.png',
        'bg': const Color(0xFFFFEBEE),
        'text': const Color(0xFFC62828),
      },
      {
        'title': 'Bún bò Huế',
        'image': 'assets/image/banner.png',
        'bg': const Color(0xFFF3E5F5),
        'text': const Color(0xFF6A1B9A),
      },
      {
        'title': 'Thịt bò',
        'image': 'assets/image/food_banner.png',
        'bg': const Color(0xFFEFEBE9),
        'text': const Color(0xFF4E342E),
      },
      {
        'title': 'Hải sản',
        'image': 'assets/image/cooking_burger.png',
        'bg': const Color(0xFFE0F7FA),
        'text': const Color(0xFF00838F),
      },
      {
        'title': 'Gà rán',
        'image': 'assets/image/food_banner.png',
        'bg': const Color(0xFFFFFDE7),
        'text': const Color(0xFFF57F17),
      },
      {
        'title': 'Trà sữa',
        'image': 'assets/image/cooking_burger.png',
        'bg': const Color(0xFFECEFF1),
        'text': const Color(0xFF37474F),
      },
    ];

    List<MealData> hotMeals = [];
    if (_selectedCategory == 'Tất cả') {
      for (var list in _mealsByCategory.values) {
        hotMeals.addAll(list.where((m) => m.isHot));
      }
      hotMeals = hotMeals.take(12).toList();
    } else {
      final list = _mealsByCategory[_selectedCategory] ?? [];
      hotMeals = list.where((m) => m.isHot).toList();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundContainer(
        opacity: 0.5,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SearchBarWidget(),
                  const SizedBox(height: 25),
                  const BannerWidget(),
                  const SizedBox(height: 25),
                  const Text(
                    "Danh mục",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: categories.map((cat) {
                        final isSel = _selectedCategory == cat['title'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CataLogWidget(
                            title: cat['title'] as String,
                            image: cat['image'] as String,
                            backgroundColor: cat['bg'] as Color,
                            textColor: cat['text'] as Color,
                            isSelected: isSel,
                            onTap: () => _onCategoryTapped(cat['title'] as String),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Phổ Biến Hôm Nay",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            const Text(
                              "View all",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primaryRed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const SizedBox(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        )
                      : _hasError || hotMeals.isEmpty
                          ? const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  'Không có món ăn phổ biến.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: hotMeals.map((meal) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: FoodCardWidget(
                                      title: meal.name,
                                      image: meal.image,
                                      price: meal.price,
                                      rating: meal.rating,
                                      isHot: meal.isHot,
                                      soldCount: meal.soldCount,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                  const SizedBox(height: 30),
                  Text(
                    _selectedCategory,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const SizedBox(
                          height: 250,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        )
                      : _hasError
                          ? SizedBox(
                              height: 100,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Không thể tải danh sách món ăn.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    TextButton(
                                      onPressed: _loadAllApiData,
                                      child: const Text(
                                        'Thử lại',
                                        style: TextStyle(
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildCategoryMealsGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryMealsGrid() {
    if (_selectedCategory == 'Tất cả') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _mealsByCategory.keys.map((catName) {
          final list = _mealsByCategory[catName] ?? [];
          if (list.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  catName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: list.map((meal) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: FoodCardWidget(
                        title: meal.name,
                        image: meal.image,
                        price: meal.price,
                        rating: meal.rating,
                        isHot: meal.isHot,
                        soldCount: meal.soldCount,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      );
    }

    final singleList = _mealsByCategory[_selectedCategory] ?? [];
    List<List<MealData>> chunkedMeals = [];
    for (var i = 0; i < singleList.length; i += 5) {
      final end = (i + 5 < singleList.length) ? i + 5 : singleList.length;
      chunkedMeals.add(singleList.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chunkedMeals.map((chunk) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: chunk.map((meal) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: FoodCardWidget(
                    title: meal.name,
                    image: meal.image,
                    price: meal.price,
                    rating: meal.rating,
                    isHot: meal.isHot,
                    soldCount: meal.soldCount,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
