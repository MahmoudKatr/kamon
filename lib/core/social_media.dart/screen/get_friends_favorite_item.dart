import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/constant.dart';

class FavoriteItemsScreen extends StatefulWidget {
  const FavoriteItemsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavoriteItemsScreenState createState() => _FavoriteItemsScreenState();
}

class _FavoriteItemsScreenState extends State<FavoriteItemsScreen> {
  List<FavoriteItem> favoriteItems = [];
  List<MenuItem> menuItems = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? accountId;

  @override
  void initState() {
    super.initState();
    fetchFavoriteItems();
  }

  Future<void> fetchFavoriteItems() async {
    accountId = await secureStorage.read(key: 'account_id');
    final response1 = await http.get(Uri.parse(
        'http://$baseUrl:4000/admin/social/friendsFavoriteItems/$accountId'));
    final response2 = await http.get(Uri.parse(
        'http://$baseUrl:4000/admin/branch/menu/1')); // in need change 1 to the branchId

    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final favoriteItemsData =
          json.decode(response1.body)['data']['favoriteItems'];
      final menuItemsData = json.decode(response2.body)['data']['menu'];

      setState(() {
        favoriteItems = (favoriteItemsData as List)
            .map((e) => FavoriteItem.fromJson(e))
            .toList();
        menuItems =
            (menuItemsData as List).map((e) => MenuItem.fromJson(e)).toList();
      });
    } else {
      // Handle error
    }
  }

  List<Widget> buildFavoriteCards() {
    if (favoriteItems.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No favorite items available.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    List<Widget> cards = [];

    for (var favoriteItem in favoriteItems) {
      var matchedMenuItem = menuItems.firstWhere(
          (menuItem) => menuItem.id.toString() == favoriteItem.id,
          orElse: () =>
              MenuItem(id: 0, item: 'Unknown Item', picturePath: testImage));

      cards.add(FavoriteItemCard(
          favoriteItem: favoriteItem, menuItem: matchedMenuItem));
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: buildFavoriteCards(),
        ),
      ),
    );
  }
}

class FavoriteItemCard extends StatefulWidget {
  final FavoriteItem favoriteItem;
  final MenuItem menuItem;

  const FavoriteItemCard(
      {super.key, required this.favoriteItem, required this.menuItem});

  @override
  // ignore: library_private_types_in_public_api
  _FavoriteItemCardState createState() => _FavoriteItemCardState();
}

class _FavoriteItemCardState extends State<FavoriteItemCard> {
  bool _isClicked = false;

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
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.menuItem.picturePath ?? testImage),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.menuItem.item,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal[900],
                    ),
                  ),
                ],
              ),
              if (_isClicked) ...[
                const SizedBox(height: 10),
                Text(
                  'Names: ${widget.favoriteItem.names.join(', ')}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteItem {
  final String id;
  final List<String> names;

  FavoriteItem({required this.id, required this.names});

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      names: List<String>.from(json['names']),
    );
  }
}

class MenuItem {
  final int id;
  final String item;
  final String picturePath;

  MenuItem({required this.id, required this.item, required this.picturePath});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      item: json['item'],
      picturePath:
          json['picture_path'] ?? testImage, // Provide a default value here
    );
  }
}
