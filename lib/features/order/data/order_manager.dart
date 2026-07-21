import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:food_app/injection_container.dart';
import 'package:food_app/core/services/order_service.dart';
import '../../cart/domain/entities/cart_item.dart';

class OrderHistoryItem {
  final String orderId;
  final DateTime orderDate;
  final List<CartItem> items;
  final int totalPrice;
  final String paymentMethod;
  final String status; // 'Đang chuẩn bị', 'Đang giao', 'Đã giao'
  final String address;
  final String note;

  OrderHistoryItem({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    required this.address,
    this.note = '',
    this.status = 'Đang chuẩn bị',
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'orderDate': orderDate.toIso8601String(),
        'items': items.map((x) => x.toJson()).toList(),
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'status': status,
        'address': address,
        'note': note,
      };

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) => OrderHistoryItem(
        orderId: json['orderId'] as String,
        orderDate: DateTime.parse(json['orderDate'] as String),
        items: (json['items'] as List<dynamic>)
            .map((x) => CartItem.fromJson(x as Map<String, dynamic>))
            .toList(),
        totalPrice: json['totalPrice'] as int,
        paymentMethod: json['paymentMethod'] as String,
        address: json['address'] as String,
        note: json['note'] as String? ?? '',
        status: json['status'] as String? ?? 'Đang chuẩn bị',
      );
}

@lazySingleton
class OrderManager {
  static const String _ordersKey = 'cached_order_items';

  static OrderManager get instance => getIt<OrderManager>();

  OrderManager() {
    fetchOrdersFromBackend();
  }

  final ValueNotifier<List<OrderHistoryItem>> ordersNotifier =
      ValueNotifier<List<OrderHistoryItem>>([]);

  List<OrderHistoryItem> get orders => ordersNotifier.value;

  // Tải danh sách đơn hàng RIÊNG BIỆT của tài khoản đang đăng nhập từ Backend API
  Future<void> fetchOrdersFromBackend() async {
    try {
      final backendOrders = await OrderService.getOrders();
      if (backendOrders.isNotEmpty) {
        final List<OrderHistoryItem> list = [];
        for (var o in backendOrders) {
          final itemsList = (o['items'] as List<dynamic>? ?? []).map((i) {
            final priceStr = (i['price'] as String? ?? '0').replaceAll(RegExp(r'[^0-9]'), '');
            final priceInt = int.tryParse(priceStr) ?? 0;
            return CartItem(
              name: i['food_name'] ?? '',
              price: priceInt,
              quantity: i['quantity'] ?? 1,
              image: i['food_image'] ?? 'assets/image/pho_ga.png',
            );
          }).toList();

          String rawDate = o['created_at']?.toString() ?? '';
          DateTime parsedDate = DateTime.now();
          if (rawDate.isNotEmpty) {
            if (!rawDate.endsWith('Z') && !rawDate.contains('+')) {
              rawDate += 'Z';
            }
            parsedDate = DateTime.parse(rawDate).toLocal();
          }

          list.add(OrderHistoryItem(
            orderId: '#${o['order_code'] ?? 'FOOD-000000'}',
            orderDate: parsedDate,
            items: itemsList,
            totalPrice: o['total_price'] ?? 0,
            paymentMethod: o['payment_method'] ?? 'COD',
            address: o['shipping_address'] ?? '',
            note: o['note'] ?? '',
            status: o['status'] ?? 'Đang chuẩn bị',
          ));
        }
        ordersNotifier.value = list;
      } else {
        ordersNotifier.value = [];
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch sử đơn hàng từ Backend: $e");
    }
  }

  void addOrder(OrderHistoryItem order) {
    ordersNotifier.value = List.from(orders)..insert(0, order);
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final list = List<OrderHistoryItem>.from(orders);
    final index = list.indexWhere((element) => element.orderId == orderId);
    if (index >= 0) {
      final old = list[index];
      list[index] = OrderHistoryItem(
        orderId: old.orderId,
        orderDate: old.orderDate,
        items: old.items,
        totalPrice: old.totalPrice,
        paymentMethod: old.paymentMethod,
        address: old.address,
        note: old.note,
        status: newStatus,
      );
      ordersNotifier.value = list;
    }
  }
}
