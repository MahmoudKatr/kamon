import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kamon/constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class CompleteOrderCard extends StatefulWidget {
  const CompleteOrderCard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompleteOrderCardState createState() => _CompleteOrderCardState();
}

class _CompleteOrderCardState extends State<CompleteOrderCard> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<Order>> fetchOrders() async {
    // Retrieve customer_id from secure storage
    String? customerId = await secureStorage.read(key: 'customer_id');
    if (customerId == null) throw Exception("Customer ID not found");

    final response = await http.get(Uri.parse(
        'http://$baseUrl:4000/admin/customers/customerOrders/$customerId/10/completed'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List orders = jsonResponse['data']['orders'];
      return orders.map((order) => Order.fromJson(order)).toList();
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
      body: FutureBuilder<List<Order>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found completed'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return OrderItemCard(
                    order: order, capitalizeEachWord: capitalizeEachWord);
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

  const OrderItemCard(
      {super.key, required this.order, required this.capitalizeEachWord});

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
                  decoration: const BoxDecoration(
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
              const SizedBox(width: 16),
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
                    const SizedBox(height: 8),
                    Text(
                      formattedBranchName,
                      style: kSecondaryFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${order.orderTotalPrice} EGP',
                      style: kPrimaryFont(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kItemFontColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment: ${order.orderPaymentMethod}',
                      style: kPrimaryFont(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
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
