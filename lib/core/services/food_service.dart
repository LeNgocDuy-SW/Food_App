import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class FoodService {
  // Lấy danh sách món ăn từ Backend (hỗ trợ lọc theo danh mục hoặc tìm kiếm)
  static Future<List<Map<String, dynamic>>> getFoods({
    String? category,
    String? search,
    bool? isPopular,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isPopular != null) queryParams['is_popular'] = isPopular.toString();

      final queryString = queryParams.isNotEmpty
          ? '?${Uri(queryParameters: queryParams).query}'
          : '';

      final response = await AuthService.getApi('/api/v1/foods$queryString');

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('[FoodService Error] $e');
    }
    return [];
  }

  // Lấy danh mục món ăn
  static Future<List<String>> getCategories() async {
    try {
      final response = await AuthService.getApi('/api/v1/foods/categories');

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item.toString()).toList();
      }
    } catch (e) {
      debugPrint('[FoodService Categories Error] $e');
    }
    return ['All'];
  }
}
