import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:food_app/injection_container.dart';
import '../domain/entities/cart_item.dart';

@lazySingleton
class CartManager extends ChangeNotifier {
  static CartManager get instance => getIt<CartManager>();
  static const String _cartKey = 'cached_cart_items';

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

  CartManager() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      if (cartString != null) {
        final List<dynamic> decoded = jsonDecode(cartString);
        _items.clear();
        _items.addAll(decoded.map((x) => CartItem.fromJson(x as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi tải giỏ hàng từ SharedPreferences: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = jsonEncode(_items.map((x) => x.toJson()).toList());
      await prefs.setString(_cartKey, cartString);
    } catch (e) {
      debugPrint("Lỗi lưu giỏ hàng vào SharedPreferences: $e");
    }
  }

  void addItem(CartItem item) {
    for (final i in _items) {
      if (i.name == item.name) {
        i.quantity++;
        notifyListeners();
        _saveToPrefs();
        return;
      }
    }
    _items.add(item);
    notifyListeners();
    _saveToPrefs();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
    _saveToPrefs();
  }

  void incrementQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
    _saveToPrefs();
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
      _saveToPrefs();
    } else {
      removeItem(item);
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveToPrefs();
  }
}
