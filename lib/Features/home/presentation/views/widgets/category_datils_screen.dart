import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import '../../../../menu/data/get_menu.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: CustomCardClipper(),
          child: Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                item.localPicturePath != null &&
                        File(item.localPicturePath!).existsSync()
                    ? Image.file(
                        File(item.localPicturePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                      )
                    : (item.picturePath != null
                        ? Image.network(
                            item.picturePath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                          )
                        : const Icon(Icons.broken_image, size: 50)),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(item.itemName,
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                      Text('\$${double.parse(item.price).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.grey[600])),
                      if (item.vegetarian)
                        const Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Vegetarian',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                      if (item.healthy)
                        const Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Healthy',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = GetMenu().getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final items = snapshot.data!
                .where((item) => item.categoryId == widget.categoryId)
                .toList();
            if (items.isEmpty) {
              return const Center(child: Text("No items found"));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => MenuItemCard(item: items[index]),
            );
          }
          return const Center(child: Text("No items found"));
        },
      ),
    );
  }
}

class CustomCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 70);

    // Add small curve to the right top corner near the button
    path.quadraticBezierTo(
        size.width - 10, size.height - 70, size.width - 10, size.height - 80);

    // Add small curve to the left bottom corner near the button
    path.lineTo(size.width - 80, size.height - 80);
    path.quadraticBezierTo(
        size.width - 70, size.height - 70, size.width - 80, size.height);

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
