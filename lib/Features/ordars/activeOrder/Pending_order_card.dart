import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamon/constant.dart';

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

class PendingOrderCard extends StatefulWidget {
  const PendingOrderCard({super.key});

  @override
  _PendingOrderCardState createState() => _PendingOrderCardState();
}

class _PendingOrderCardState extends State<PendingOrderCard> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  late Future<Order?> futureOrder;

  @override
  void initState() {
    super.initState();
    futureOrder = fetchOrder();
  }

  Future<Order?> fetchOrder() async {
    // Retrieve customer_id from secure storage
    String? customerId = await secureStorage.read(key: 'customer_id');
    if (customerId == null) throw Exception("Customer ID not found");

    final response = await http.get(Uri.parse('http://$baseUrl:4000/admin/customers/customerOrders/$customerId/10/pending'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data']['orders'].isNotEmpty) {
        return Order.fromJson(data['data']['orders'][0]);
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to load order');
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
    return FutureBuilder<Order?>(
      future: futureOrder,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: kPrimaryFont(fontSize: 16, color: Colors.red)));
        } else if (!snapshot.hasData) {
          return Center(
              child: Text('No Order Found',
                  style: kPrimaryFont(fontSize: 16, color: Colors.grey)));
        } else {
          final order = snapshot.data!;
          final formattedBranchName = capitalizeEachWord(order.branchName);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
