class CartItem {
  final int itemId;
  final String itemName;
  final double price;
  final int quantity;

  CartItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
  });
}

class Cart {
  List<CartItem> items = [];

  void addItem(CartItem item) {
    items.add(item);
  }

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void clear() {
    items.clear();
  }
}
