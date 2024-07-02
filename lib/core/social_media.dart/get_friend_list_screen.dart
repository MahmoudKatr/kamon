import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamon/constant.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  late Future<List<Friend>> futureFriends;

  @override
  void initState() {
    super.initState();
    futureFriends = fetchFriends();
  }

  Future<List<Friend>> fetchFriends() async {
    final response = await http
        .get(Uri.parse('http://$baseUrl:4000/admin/social/friendsList/301'));

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
      body: FutureBuilder<List<Friend>>(
        future: futureFriends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No friends found'));
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

  FriendCard({required this.name});

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
              child: Text(
                name[0],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: kPrimaryColor,
            ),
            SizedBox(width: 16.0),
            Text(
              name,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
