import 'package:flutter/material.dart';

class FavoriteMeal {
  final String title;
  final String image;
  final String price;
  final String rating;
  final String category;
  final String storeName;
  final String prepTime;
  final String distance;

  FavoriteMeal({
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    this.storeName = 'Sà Bì Chưởng - Hà Nội',
    this.prepTime = '25-30 phút',
    this.distance = '1.2 km',
  });
}

class FavoriteManager {
  static final FavoriteManager instance = FavoriteManager._internal();
  FavoriteManager._internal();

  final ValueNotifier<List<FavoriteMeal>> favoritesNotifier = ValueNotifier<List<FavoriteMeal>>([
    // Khởi tạo một số món yêu thích mẫu cực kỳ bắt mắt
    FavoriteMeal(
      title: 'Bánh Mì Heo Quay Đặc Sản',
      image: 'assets/image/cooking_burger.png',
      price: '35.000đ',
      rating: '4.8',
      category: 'Bánh mỳ',
      storeName: 'Sà Bì Chưởng - Hà Nội',
    ),
    FavoriteMeal(
      title: 'Bún Bò Huế Chuẩn Vị',
      image: 'assets/image/hamberger.png',
      price: '45.000đ',
      rating: '4.8',
      category: 'Phở & Bún',
      storeName: 'Bún Chả Cửa Đông - Hoàn Kiếm',
    ),
  ]);

  List<FavoriteMeal> get favorites => favoritesNotifier.value;

  bool isFavorite(String title) {
    return favorites.any((element) => element.title == title);
  }

  void toggleFavorite(FavoriteMeal meal) {
    final list = List<FavoriteMeal>.from(favorites);
    final idx = list.indexWhere((element) => element.title == meal.title);
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.add(meal);
    }
    favoritesNotifier.value = list;
  }
}
