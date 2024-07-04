import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/Features/ordars/non_virtual_order/model/non_virual_model.dart';
import 'package:kamon/constant.dart';

Future<String> placeOrder(Order order) async {
  const url = 'http://$baseUrl:4000/user/order/nonVirtualOrder';
  try {
    final jsonPayload = jsonEncode(order.toJson());
    debugPrint(
        'JSON Payload: $jsonPayload'); // debugPrint JSON payload for debugging

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonPayload,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success
      final responseBody = response.body;
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: $responseBody');
      return responseBody;
    } else {
      // Failure
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      throw Exception('Failed to place order: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error: $e');
    throw Exception('Error placing order: $e');
  }
}
