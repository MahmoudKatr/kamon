import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamon/Features/ordars/non_virtual_order/model/non_virual_model.dart';
import 'package:kamon/constant.dart';

Future<String> placeOrder(Order order) async {
  final url = 'http://$baseUrl:4000/user/order/nonVirtualOrder';
  try {
    final jsonPayload = jsonEncode(order.toJson());
    print('JSON Payload: $jsonPayload'); // Print JSON payload for debugging

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonPayload,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success
      final responseBody = response.body;
      print('Status: ${response.statusCode}');
      print('Response: $responseBody');
      return responseBody;
    } else {
      // Failure
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      throw Exception('Failed to place order: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error placing order: $e');
  }
}
