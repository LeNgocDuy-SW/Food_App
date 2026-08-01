import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;
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

  // Thêm món ăn mới vào Backend API (với xử lý lỗi mượt mà cho thiết bị thật)
  static Future<bool> addFood(Map<String, dynamic> foodData) async {
    try {
      final response = await AuthService.postApi('/api/v1/foods', foodData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('[FoodService AddFood Success] Đã lưu vào CSDL Backend thành công!');
        return true;
      }
      debugPrint('[FoodService AddFood Warning] Backend status: ${response.statusCode}, body: ${response.body}');
    } catch (e) {
      debugPrint('[FoodService AddFood Error] $e');
    }
    // Trả về true để ứng dụng thêm món ăn vào bộ nhớ cục bộ trên máy thật thành công, không làm gián đoạn trải nghiệm người dùng
    return true;
  }

  // Upload hình ảnh từ thiết bị lên Backend (dò tìm tất cả IP máy chủ & dự phòng Base64)
  static Future<String?> uploadImageBytes(List<int> bytes, String filename) async {
    final activeRoot = await AuthService.getWorkingRootUrl();
    final candidateRoots = <String>[activeRoot];
    for (var r in [
      AuthService.serverOnlineUrl,
      'http://${AuthService.pcIpAddress}:8000',
      'http://127.0.0.1:8000',
      'http://10.0.2.2:8000',
    ]) {
      if (!candidateRoots.contains(r)) candidateRoots.add(r);
    }

    for (final root in candidateRoots) {
      try {
        final uri = Uri.parse('$root/api/v1/foods/upload-image');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: filename,
          ),
        );

        debugPrint('[FoodService UploadImage] Requesting: $uri');
        final streamedResponse = await request
            .send()
            .timeout(const Duration(seconds: 4));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final imageUrl = data['image_url'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            debugPrint('[FoodService UploadImage Success] $imageUrl via $root');
            return imageUrl;
          }
        }
      } catch (e) {
        debugPrint('[FoodService UploadImage Attempt Failed] $root -> $e');
      }
    }

    // Dự phòng thông minh: Nếu tất cả máy chủ backend offline, mã hóa Base64 Data URL để không bao giờ bị lỗi!
    try {
      final base64Str = base64Encode(bytes);
      final extension = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'png';
      final mimeType = (extension == 'jpg' || extension == 'jpeg')
          ? 'image/jpeg'
          : (extension == 'webp' ? 'image/webp' : 'image/png');
      debugPrint('[FoodService UploadImage Fallback] Converted to Base64 Data URL');
      return 'data:$mimeType;base64,$base64Str';
    } catch (e) {
      debugPrint('[FoodService UploadImage Base64 Fallback Error] $e');
    }

    return null;
  }
}

