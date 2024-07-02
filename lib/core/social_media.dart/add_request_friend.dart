import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:kamon/constant.dart';
import 'package:kamon/core/social_media.dart/model/get_customer_by_phone_model.dart';

class AddRequestFriend extends StatefulWidget {
  @override
  _AddRequestFriendState createState() => _AddRequestFriendState();
}

class _AddRequestFriendState extends State<AddRequestFriend> {
  final TextEditingController _controller = TextEditingController();
  final storage = new FlutterSecureStorage();
  Future<List<Account>>? _futureAccounts;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),  // Adjust the height as needed
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter phone number',
                labelStyle: TextStyle(color: kPrimaryColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
                prefixIcon: Icon(Icons.phone, color: kPrimaryColor),
              ),
              keyboardType: TextInputType.phone,
            ),
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please enter a phone number',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
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
              icon: Icon(Icons.search),
              label: Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            _futureAccounts == null
                ? Container()
                : FutureBuilder<List<Account>>(
                    future: _futureAccounts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No accounts found');
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
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: kPrimaryColor,
                                      child: Text(
                                        account.firstName[0],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      '${account.firstName} ${account.lastName}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Icon(Icons.person_add, color: kPrimaryColor),
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
          title: Text(
            'Send Friend Request',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to send a friend request to ${account.firstName} ${account.lastName}?',
            style: TextStyle(color: Colors.black87),
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
              child: Text('Cancel'),
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
              child: Text('Send Request'),
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
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', url);
      request.body = json.encode({
        "senderId": senderId,
        "receiverId": receiverId.toString()
      });
      request.headers.addAll(headers);

      try {
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print(await response.stream.bytesToString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Friend request sent successfully')),
          );
        } else {
          print(response.reasonPhrase);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send friend request')),
          );
        }
      } catch (e) {
        print('Error sending friend request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending friend request')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve sender ID')),
      );
    }
  }
}
