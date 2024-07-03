import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kamon/constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

// Model class for Order
class Order {
  final int orderId;
  final String branchName;
  final String orderTotalPrice;
  final String orderPaymentMethod;

  Order({
    required this.orderId,
    required this.branchName,
    required this.orderTotalPrice,
    required this.orderPaymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      branchName: json['branch_name'],
      orderTotalPrice: json['order_total_price'],
      orderPaymentMethod: json['order_payment_method'],
    );
  }
}

class PendingOrder extends StatefulWidget {
  @override
  _PendingOrderState createState() => _PendingOrderState();
}

class _PendingOrderState extends State<PendingOrder> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final ValueNotifier<List<Order>> _ordersNotifier = ValueNotifier([]);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startPolling() {
    _fetchOrders(); // Initial fetch
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    // Retrieve customer_id from secure storage
    String? customerId = await secureStorage.read(key: 'customer_id');
    if (customerId == null) throw Exception("Customer ID not found");

    final response = await http.get(Uri.parse(
        'http://$baseUrl:4000/admin/customers/customerOrders/$customerId/10/pending'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List orders = jsonResponse['data']['orders'];
      _ordersNotifier.value = orders.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<Order>>(
        valueListenable: _ordersNotifier,
        builder: (context, orders, child) {
          if (orders.isEmpty) {
            return Center(child: Text('No orders found Pending'));
          } else {
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderItemCard(
                    order: order, capitalizeEachWord: capitalizeEachWord, onCancel: _fetchOrders);
              },
            );
          }
        },
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final Order order;
  final String Function(String) capitalizeEachWord;
  final VoidCallback onCancel;

  OrderItemCard({required this.order, required this.capitalizeEachWord, required this.onCancel});

  Future<void> cancelOrder(int orderId) async {
    final response = await http.patch(
      Uri.parse('https://54.235.40.102.nip.io/user/order/updateorderStatus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'orderId': orderId.toString(),
        'orderStatus': 'cancelled',
      }),
    );

    if (response.statusCode == 201) {
      print('Order cancelled successfully');
      onCancel(); // Call the onCancel callback to refresh the orders list
    } else {
      throw Exception('Failed to cancel the order');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedBranchName = capitalizeEachWord(order.branchName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Image.network(
                    testImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderId}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: kPrimaryFont(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kItemFontColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      formattedBranchName,
                      style: kSecondaryFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total: ${order.orderTotalPrice} EGP',
                      style: kPrimaryFont(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kItemFontColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Payment: ${order.orderPaymentMethod}',
                      style: kPrimaryFont(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Background color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await cancelOrder(order.orderId);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Order cancelled successfully'),
                          ));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to cancel the order'),
                          ));
                        }
                      },
                      child: Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
