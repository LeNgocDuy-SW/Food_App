import 'package:flutter/material.dart';
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
}

class OrderManager {
  static final OrderManager instance = OrderManager._internal();
  OrderManager._internal();

  final ValueNotifier<List<OrderHistoryItem>> ordersNotifier =
      ValueNotifier<List<OrderHistoryItem>>([
        // Đơn hàng mẫu lịch sử để giao diện sinh động và chân thực ngay từ đầu
        OrderHistoryItem(
          orderId: '#FOOD-102580',
          orderDate: DateTime.now().subtract(const Duration(hours: 5)),
          items: [
            CartItem(
              name: 'Bánh Mì Heo Quay Đặc Sản',
              price: 35000,
              quantity: 2,
              image: 'assets/image/cooking_burger.png',
            ),
            CartItem(
              name: 'Phở Gà Ta Cổ Truyền',
              price: 35000,
              quantity: 1,
              image: 'assets/image/pho_ga.png',
            ),
          ],
          totalPrice: 115000, // 35000*2 + 35000 + 10000 ship
          paymentMethod: 'COD',
          address: 'Số 11 , ngách 21/50/7 Yên Xá, Tân Triều, Thanh Trì, Hà Nội (Nhà riêng)',
          note: 'Nhiều rau, không hành',
          status: 'Đã giao',
        ),
        OrderHistoryItem(
          orderId: '#FOOD-098522',
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          items: [
            CartItem(
              name: 'Bún Bò Huế Chuẩn Vị',
              price: 45000,
              quantity: 1,
              image: 'assets/image/hamberger.png',
            ),
          ],
          totalPrice: 55000, // 45000 + 10000 ship
          paymentMethod: 'MOMO',
          address: 'Tòa nhà Keangnam, Phạm Hùng, Mễ Trì, Nam Từ Liêm, Hà Nội (Văn phòng)',
          note: 'Để ở quầy lễ tân tầng 1',
          status: 'Đã giao',
        ),
      ]);

  List<OrderHistoryItem> get orders => ordersNotifier.value;

  void addOrder(OrderHistoryItem order) {
    ordersNotifier.value = List.from(orders)..insert(0, order);
    
    if (order.status == 'Đang chuẩn bị') {
      // Tự động cập nhật trạng thái đơn hàng trong nền (background)
      // Sau 12 giây: Chuẩn bị -> Đang giao
      Future.delayed(const Duration(seconds: 12), () {
        updateOrderStatus(order.orderId, 'Đang giao');
      });
      // Sau 28 giây: Đang giao -> Đã giao
      Future.delayed(const Duration(seconds: 28), () {
        updateOrderStatus(order.orderId, 'Đã giao');
      });
    }
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
