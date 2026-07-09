import 'package:flutter/material.dart';
import '../domain/entities/cart_item.dart';

class CartManager {
  static final CartManager instance = CartManager._internal();
  CartManager._internal();

  final ValueNotifier<List<CartItem>> itemsNotifier = ValueNotifier<List<CartItem>>([
    CartItem(
      name: 'Bánh Mỳ',
      price: 20000,
      quantity: 1,
      image: 'assets/image/hamberger.png',
    ),
    CartItem(
      name: 'Hamberger',
      price: 45000,
      quantity: 2,
      image: 'assets/image/hamberger.png',
    ),
    CartItem(
      name: 'Bánh Mỳ Sai Gon VN',
      price: 25000,
      quantity: 1,
      image: 'assets/image/hamberger.png',
    ),
  ]);

  List<CartItem> get items => itemsNotifier.value;

  void addItem(CartItem item) {
    final existingIndex = items.indexWhere((element) => element.name == item.name);
    if (existingIndex >= 0) {
      items[existingIndex].quantity += item.quantity;
      itemsNotifier.value = List.from(items);
    } else {
      itemsNotifier.value = List.from(items)..add(item);
    }
  }

  void removeItem(CartItem item) {
    itemsNotifier.value = List.from(items)..remove(item);
  }

  void incrementQuantity(CartItem item) {
    item.quantity++;
    itemsNotifier.value = List.from(items);
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      itemsNotifier.value = List.from(items);
    } else {
      removeItem(item);
    }
  }

  void clear() {
    itemsNotifier.value = [];
  }
}
