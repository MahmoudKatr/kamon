import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamon/constant.dart';

class FriendRequest {
  final int id;
  final String custName;
  final DateTime requestDate;

  FriendRequest({required this.id, required this.custName, required this.requestDate});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      custName: json['cust_name'],
      requestDate: DateTime.parse(json['request_date']),
    );
  }
}

Future<List<FriendRequest>> fetchFriendRequests() async {
  // Initialize secure storage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  
  // Retrieve the account_id from secure storage
  String? accountId = await secureStorage.read(key: 'account_id');

  // Check if accountId is not null
  if (accountId == null) {
    throw Exception('Account ID not found');
  }

  // Construct the URL with the retrieved account_id
  final response = await http.get(Uri.parse('http://$baseUrl:4000/admin/social/friend-requests/$accountId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data']['requests'];
    return data.map((json) => FriendRequest.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load friend requests');
  }
}
