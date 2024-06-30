import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  CartProvider() {
    loadCartData();
  }

  void addItem(MenuItem menuItem, int quantity) {
    final index =
        _items.indexWhere((item) => item.menuItem.itemId == menuItem.itemId);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(menuItem: menuItem, quantity: quantity));
    }
    saveCartData();
    notifyListeners();
  }

  void removeItem(MenuItem menuItem) {
    _items.removeWhere((item) => item.menuItem.itemId == menuItem.itemId);
    saveCartData();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    saveCartData();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (total, current) {
      final double itemPrice = double.tryParse(current.menuItem.price) ?? 0.0;
      return total + itemPrice * current.quantity;
    });
  }

  void updateItemQuantity(int itemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItem.itemId == itemId);
    if (index != -1) {
      _items[index].quantity = quantity;
      saveCartData();
      notifyListeners();
    }
  }

  Future<void> saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson =
        _items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cartItems', cartItemsJson);
  }

  Future<void> loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cartItems');
    if (cartItemsJson != null) {
      _items = cartItemsJson
          .map((itemJson) => CartItem.fromJson(jsonDecode(itemJson)))
          .toList();
      notifyListeners();
    }
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'menuItem': menuItem.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'],
    );
  }
}
