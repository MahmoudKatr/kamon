// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/constant.dart';
import 'package:kamon/core/social_media.dart/model/get_customer_by_phone_model.dart';

class AddRequestFriend extends StatefulWidget {
  const AddRequestFriend({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddRequestFriendState createState() => _AddRequestFriendState();
}

class _AddRequestFriendState extends State<AddRequestFriend> {
  final TextEditingController _controller = TextEditingController();
  final storage = const FlutterSecureStorage();
  Future<List<Account>>? _futureAccounts;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50), // Adjust the height as needed
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter phone number',
                labelStyle: const TextStyle(color: kPrimaryColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: kPrimaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: kPrimaryColor),
                ),
                prefixIcon: const Icon(Icons.phone, color: kPrimaryColor),
              ),
              keyboardType: TextInputType.phone,
            ),
            if (_showError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please enter a phone number',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_controller.text.isEmpty) {
                  setState(() {
                    _showError = true;
                  });
                } else {
                  setState(() {
                    _showError = false;
                    _futureAccounts = fetchAccountByPhone(_controller.text);
                  });
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            _futureAccounts == null
                ? Container()
                : FutureBuilder<List<Account>>(
                    future: _futureAccounts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No accounts found');
                      } else {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final account = snapshot.data![index];
                              return InkWell(
                                onTap: () {
                                  showRequestDialog(account);
                                },
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: kPrimaryColor,
                                      child: Text(
                                        account.firstName[0],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      '${account.firstName} ${account.lastName}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(Icons.person_add,
                                        color: kPrimaryColor),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void showRequestDialog(Account account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Send Friend Request',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to send a friend request to ${account.firstName} ${account.lastName}?',
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                sendFriendRequest(account);
                Navigator.of(context).pop();
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendFriendRequest(Account account) async {
    String? senderId = await storage.read(key: 'account_id');
    int receiverId = account.accountId;

    if (senderId != null) {
      var url = Uri.parse('http://$baseUrl:4000/admin/social/friend-request');
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', url);
      request.body = json
          .encode({"senderId": senderId, "receiverId": receiverId.toString()});
      request.headers.addAll(headers);

      try {
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          debugPrint(await response.stream.bytesToString());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend request sent successfully')),
          );
        } else {
          debugPrint(response.reasonPhrase);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send friend request')),
          );
        }
      } catch (e) {
        debugPrint('Error sending friend request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending friend request')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to retrieve sender ID')),
      );
    }
  }
}
