import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamon/constant.dart';

class Account {
  final int accountId;
  final String firstName;
  final String lastName;

  Account(
      {required this.accountId,
      required this.firstName,
      required this.lastName});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['account_id'],
      firstName: json['customer_first_name'],
      lastName: json['customer_last_name'],
    );
  }
}

Future<List<Account>> fetchAccountByPhone(String phone) async {
  final response = await http.get(
      Uri.parse('http://$baseUrl:4000/admin/social/getAccountByPhone/$phone'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      List<Account> accounts = (jsonResponse['data'] as List)
          .map((account) => Account.fromJson(account))
          .toList();
      return accounts;
    } else {
      throw Exception('Failed to load accounts');
    }
  } else {
    throw Exception('Failed to load accounts');
  }
}
