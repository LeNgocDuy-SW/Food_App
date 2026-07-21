import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class OrderService {
  // Tạo đơn hàng mới lên Backend
  static Future<Map<String, dynamic>> createOrder({
    required int totalPrice,
    required String paymentMethod,
    required String shippingAddress,
    required List<Map<String, dynamic>> items,
    String? note,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final body = {
        'total_price': totalPrice,
        'payment_method': paymentMethod,
        'shipping_address': shippingAddress,
        'note': note,
        'items': items,
      };

      final response = await AuthService.postApi(
        '/api/v1/orders',
        body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Tạo đơn hàng thất bại!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối tới máy chủ ($e)'};
    }
  }

  // Lấy lịch sử đơn hàng của người dùng
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) return [];

      final response = await AuthService.getApi(
        '/api/v1/orders',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('[OrderService getOrders Error] $e');
    }
    return [];
  }
}
