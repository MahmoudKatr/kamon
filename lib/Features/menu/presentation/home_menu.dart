import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamon/Features/menu/data/get_menu.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<List<MenuItem>> fetchMenu() async {
    try {
      GetMenu getMenu = GetMenu();
      return await getMenu.getMenu();
    } catch (e) {
      debugPrint('Error fetching menu: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: fetchMenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No menu items available.'));
          } else {
            List<MenuItem> menuItems = snapshot.data!;
            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                MenuItem item = menuItems[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: item.localPicturePath != null &&
                            item.localPicturePath!.isNotEmpty
                        ? Image.file(File(item.localPicturePath!),
                            width: 50, height: 50, fit: BoxFit.cover)
                        : Image.network(
                            item.picturePath ??
                                'https://example.com/default-image.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover),
                    title: Text(item.itemName),
                    subtitle: Text(item.itemDescription),
                    trailing: Text('${item.price} EGP'),
                    onTap: () {
                      GoRouter.of(context).push(
                        '/itemDetail',
                        extra: item, // Pass the MenuItem directly
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
