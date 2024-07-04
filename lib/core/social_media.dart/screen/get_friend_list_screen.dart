import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamon/constant.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  Future<List<Friend>>? futureFriends;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? accountId;

  @override
  void initState() {
    super.initState();
    _loadAccountId();
  }

  Future<void> _loadAccountId() async {
    accountId = await secureStorage.read(key: 'account_id');
    if (accountId != null) {
      setState(() {
        futureFriends = fetchFriends(accountId!);
      });
    } else {
      // Handle case where account_id is not found
    }
  }

  Future<List<Friend>> fetchFriends(String accountId) async {
    final response = await http.get(
        Uri.parse('http://$baseUrl:4000/admin/social/friendsList/$accountId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> friendsJson = jsonResponse['data']['friends'];
      return friendsJson.map((json) => Friend.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: futureFriends == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Friend>>(
              future: futureFriends,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No friends found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final friend = snapshot.data![index];
                      return FriendCard(name: friend.name);
                    },
                  );
                }
              },
            ),
    );
  }
}

class Friend {
  final String id;
  final String name;

  Friend({required this.id, required this.name});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
    );
  }
}

class FriendCard extends StatelessWidget {
  final String name;

  const FriendCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Text(
              name,
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
