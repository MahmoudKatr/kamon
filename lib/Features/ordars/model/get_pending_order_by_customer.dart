import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Order {
  final int orderId;
  final String branchName;
  final String orderType;
  final String orderTotalPrice;
  final String orderPaymentMethod;

  Order({
    required this.orderId,
    required this.branchName,
    required this.orderType,
    required this.orderTotalPrice,
    required this.orderPaymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      branchName: json['branch_name'],
      orderType: json['order_type'],
      orderTotalPrice: json['order_total_price'],
      orderPaymentMethod: json['order_payment_method'],
    );
  }
}

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<List<Order>> fetchOrders() async {
  try {
    // Read the customer ID from secure storage
    String? customerId = await secureStorage.read(key: 'customer_id');
    
    if (customerId == null) {
      throw Exception('Customer ID not found');
    }
    
    final response = await Dio().get('http://localhost:4000/admin/customers/customerOrders/$customerId/10/pending');

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final List<dynamic> ordersJson = jsonResponse['data']['orders'];
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  } catch (e) {
    throw Exception('Failed to load orders: $e');
  }
}

