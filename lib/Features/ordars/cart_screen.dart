// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamon/Features/ordars/data/cart_provider.dart';
import 'package:kamon/Features/ordars/non_virtual_order/data/post_non_virual.dart';
import 'package:kamon/Features/ordars/non_virtual_order/model/non_virual_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  final CartProvider cart;

  const CartScreen({super.key, required this.cart});

  @override
  // ignore: library_private_types_in_public_api
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _controller;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red,
    ).animate(_colorController);
  }

  void _removeItem(int index) {
    final cartItem = widget.cart.items[index];
    widget.cart.removeItem(cartItem.menuItem);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(cartItem, index, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildRemovedItem(
      CartItem cartItem, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 0.2,
              child: Container(
                color: _colorAnimation.value,
                child: _buildItemContent(cartItem),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(CartItem cartItem, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onTap: () {
          _controller.forward(from: 0);
          _colorController.forward(from: 0).then((_) {
            _removeItem(index);
          });
        },
        child: _buildItemContent(cartItem),
      ),
    );
  }

  Widget _buildItemContent(CartItem cartItem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: cartItem.menuItem.localPicturePath != null &&
                  cartItem.menuItem.localPicturePath!.isNotEmpty
              ? FileImage(File(cartItem.menuItem.localPicturePath!))
              : NetworkImage(cartItem.menuItem.picturePath ??
                      'https://images.pexels.com/photos/1352274/pexels-photo-1352274.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1')
                  as ImageProvider,
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          cartItem.menuItem.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${cartItem.quantity} x ${cartItem.menuItem.price} EGP',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _controller.forward(from: 0);
                _colorController.forward(from: 0).then((_) {
                  _removeItem(widget.cart.items.indexOf(cartItem));
                });
              },
            ),
            IconButton(
              icon:
                  const Icon(Icons.remove_circle_outline, color: Colors.orange),
              onPressed: () {
                if (cartItem.quantity > 1) {
                  setState(() {
                    cartItem.quantity--;
                    widget.cart.updateItemQuantity(
                      cartItem.menuItem.itemId,
                      cartItem.quantity,
                    );
                  });
                } else {
                  _controller.forward(from: 0);
                  _colorController.forward(from: 0).then((_) {
                    _removeItem(widget.cart.items.indexOf(cartItem));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    int? branchId = prefs.getInt('branchId');
    String? customerId = await secureStorage.read(key: 'customer_id');

    if (branchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to get branch information'),
      ));
      return;
    }

    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to get customer information'),
      ));
      return;
    }

    List<OrderItem> orderItems = widget.cart.items.map((cartItem) {
      final menuItem = cartItem.menuItem;
      return OrderItem(
        itemId: menuItem.itemId,
        quantity: cartItem.quantity,
        quotePrice: double.tryParse(menuItem.price) ?? 0.0,
      );
    }).toList();

    Order order = Order(
      customerId: customerId,
      branchId: branchId.toString(),
      orderType: 'delivery',
      orderStatus: 'pending',
      totalPrice: widget.cart.totalPrice.toString(),
      paymentMethod: 'cash',
      orderItems: orderItems,
      additionalDiscount: '0',
      creditCardNumber: '1234567891234567', // Example card number
      creditCardExpireMonth: '6',
      creditCardExpireDay: '17',
      nameOnCard: 'ismail',
      tableId: '1',
      addressId: '1',
      customerPhoneId: '1',
    );

    try {
      String response = await placeOrder(order);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order placed successfully: $response'),
      ));
      widget.cart.clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to place order: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: widget.cart.items.length,
        itemBuilder: (context, index, animation) {
          final cartItem = widget.cart.items[index];
          return _buildItem(cartItem, index, animation);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _placeOrder(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Text(
              'Place Order (${widget.cart.totalPrice.toStringAsFixed(2)} EGP)'),
        ),
      ),
    );
  }
}
