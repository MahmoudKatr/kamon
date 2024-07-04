import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../menu/data/get_menu.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15), // Consistent border radius for the card
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            15), // Apply border radius to everything inside
        child: GestureDetector(
          onTap: () {
            final String menuItemJson = jsonEncode(item.toJson());
            GoRouter.of(context).push(
              '/menu',
              extra: menuItemJson, // Serialize the MenuItem to JSON
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    item.localPicturePath != null &&
                            File(item.localPicturePath!).existsSync()
                        ? Image.file(
                            File(item.localPicturePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double
                                .infinity, // Use full height of the expanded widget
                          )
                        : (item.picturePath != null
                            ? Image.network(
                                item.picturePath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : const Icon(Icons.broken_image, size: 50)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${double.parse(item.price).toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                    ),
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
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = GetMenu().getMenu();
  }

  static final Map<String, List<double>> branches = {
    'Cairo': [30.0444, 31.2357],
    'Alexandria': [31.2001, 29.9187],
    'Port Said': [31.2653, 32.3019],
  };

  Future<List<String>> fetchBranches() async {
    // Here, we are returning the branch names directly from the static map
    return branches.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ClipPath(
            clipper: BaseClipper(), // Ensures the top part is clipped
            child: Container(
              color: kPrimaryColor, // Background color for visual clarity
              height: 130, // Fixed height for the clipped area
              width: double.infinity,
              child: Center(
                child: Text(
                  ' ${widget.categoryName}',
                  style: kPrimaryFont(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kSecondaryColor,
                  ),
                ),
              ), // Just a placeholder
            ),
          ),
          Expanded(
            // Ensures the remaining space is filled by GridView
            child: FutureBuilder<List<MenuItem>>(
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
                    return FutureBuilder<List<String>>(
                      future: fetchBranches(),
                      builder: (context, branchSnapshot) {
                        if (branchSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (branchSnapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error fetching branches: ${branchSnapshot.error}'));
                        } else if (!branchSnapshot.hasData ||
                            branchSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Sorry, no branches available.'));
                        } else {
                          List<String> branches = branchSnapshot.data!;
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 35),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/sad.svg',
                                    width: 80,
                                    height: 80,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Sorry, you're now out of our delivery area. But you can see the menus for each branch:",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
                                  ...branches.map((branch) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        // Implement navigation to the branch menu screen
                                        GoRouter.of(context)
                                            .push('/branchMenu', extra: branch);
                                      },
                                      child: Text(branch),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        MenuItemCard(item: items[index]),
                  );
                }
                return const Center(child: Text("No items found"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
