import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:food_app/injection_container.dart';

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

  Map<String, dynamic> toJson() => {
        'title': title,
        'image': image,
        'price': price,
        'rating': rating,
        'category': category,
        'storeName': storeName,
        'prepTime': prepTime,
        'distance': distance,
      };

  factory FavoriteMeal.fromJson(Map<String, dynamic> json) => FavoriteMeal(
        title: json['title'] as String,
        image: json['image'] as String,
        price: json['price'] as String,
        rating: json['rating'] as String,
        category: json['category'] as String,
        storeName: json['storeName'] as String? ?? 'Sà Bì Chưởng - Hà Nội',
        prepTime: json['prepTime'] as String? ?? '25-30 phút',
        distance: json['distance'] as String? ?? '1.2 km',
      );
}

@lazySingleton
class FavoriteManager {
  static const String _favKey = 'cached_favorite_meals';

  static FavoriteManager get instance => getIt<FavoriteManager>();

  FavoriteManager() {
    _loadFromPrefs();
  }

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

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favString = prefs.getString(_favKey);
      if (favString != null) {
        final List<dynamic> decoded = jsonDecode(favString);
        favoritesNotifier.value = decoded
            .map((x) => FavoriteMeal.fromJson(x as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint("Lỗi tải danh sách yêu thích: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favString = jsonEncode(favorites.map((x) => x.toJson()).toList());
      await prefs.setString(_favKey, favString);
    } catch (e) {
      debugPrint("Lỗi lưu danh sách yêu thích: $e");
    }
  }

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
    _saveToPrefs();
  }
}
