import 'package:flutter/material.dart';
import '../domain/entities/cart_item.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [
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
  ];

  List<CartItem> get items => _items;

  void addItem(CartItem item) {
    for (final i in _items) {
      if (i.name == item.name) {
        i.quantity++;
        notifyListeners();
        return;
      }
    }
    _items.add(item);
    notifyListeners();
  }

  // void addItem(CartItem item) {
  //   final existingIndex = items.indexWhere(
  //     (element) => element.name == item.name,
  //   );
  //   if (existingIndex >= 0) {
  //     items[existingIndex].quantity += item.quantity;
  //     itemsNotifier.value = List.from(items);
  //   } else {
  //     itemsNotifier.value = List.from(items)..add(item);
  //   }
  // }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void incrementQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    } else {
      removeItem(item);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
