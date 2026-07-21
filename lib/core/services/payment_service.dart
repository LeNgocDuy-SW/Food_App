import 'dart:convert';
import 'auth_service.dart';

class PaymentService {
  // Tạo mã QR / Yêu cầu thanh toán
  static Future<Map<String, dynamic>> createPaymentQr({
    required int orderId,
    required String paymentMethod,
    required int amount,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final body = {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount': amount,
      };

      final response = await AuthService.postApi(
        '/api/v1/payments/create-qr',
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
          'message': responseData['detail'] ?? 'Tạo thanh toán thất bại!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối máy chủ thanh toán ($e)'};
    }
  }

  // Xác nhận thanh toán thành công
  static Future<Map<String, dynamic>> confirmPayment({
    required String transactionCode,
    required int orderId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }

      final body = {
        'transaction_code': transactionCode,
        'order_id': orderId,
      };

      final response = await AuthService.postApi(
        '/api/v1/payments/confirm',
        body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Xác nhận thanh toán thất bại!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối máy chủ ($e)'};
    }
  }
}
