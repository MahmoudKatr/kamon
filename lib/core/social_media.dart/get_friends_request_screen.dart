import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamon/core/social_media.dart/model/get_friend_request_model.dart';

import '../../constant.dart';

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

class FriendRequestCard extends StatelessWidget {
  final FriendRequest request;

  FriendRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Text(
                request.custName[0],
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              radius: 30,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.custName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(request.requestDate),
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
      ),
    );
  }
}
