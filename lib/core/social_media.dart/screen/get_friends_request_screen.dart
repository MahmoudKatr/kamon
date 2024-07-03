import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/social_media.dart/model/get_friend_request_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendRequestsPage extends StatefulWidget {
  @override
  _FriendRequestsPageState createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  late Future<List<FriendRequest>> futureFriendRequests;

  @override
  void initState() {
    super.initState();
    futureFriendRequests = fetchFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<FriendRequest>>(
        future: futureFriendRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No friend requests'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final request = snapshot.data![index];
                return FriendRequestCard(request: request);
              },
            );
          }
        },
      ),
    );
  }
}

class FriendRequestCard extends StatefulWidget {
  final FriendRequest request;

  FriendRequestCard({required this.request});

  @override
  _FriendRequestCardState createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends State<FriendRequestCard> {
  bool _isClicked = false;

  Future<void> _updateFriendRequest(String requestId, String status) async {
    final url = Uri.parse('https://$baseUrl/admin/social/updateFriendRequest');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'requestId': requestId,
        'requestStatus': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update friend request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isClicked = !_isClicked;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kPrimaryColor,
                    child: Text(
                      widget.request.custName[0],
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.custName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(widget.request.requestDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_isClicked) ...[
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await _updateFriendRequest(widget.request.id.toString(), 'accepted');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend request accepted')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept friend request')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await _updateFriendRequest(widget.request.id.toString(), 'rejected');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend request rejected')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reject friend request')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 116, 99, 99),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
