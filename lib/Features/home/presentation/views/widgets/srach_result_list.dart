import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/home/data/seach_view_model.dart';

class SearchResultList extends StatelessWidget {
  const SearchResultList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SearchViewModel>(context);
    return Positioned(
      top: 56, // Adjust this value as needed
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent, // Set Material to transparent
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: MediaQuery.of(context).size.height -
              100, // Adjust height as needed
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.transparent, // Set container to transparent
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListView.builder(
            itemCount: viewModel.searchedForMenuItems.length,
            itemBuilder: (context, index) {
              final menuItem = viewModel.searchedForMenuItems[index];
              final price = double.tryParse(menuItem.price) ??
                  0.0; // Ensure price is a double
              return GestureDetector(
                onTap: () {
                  final String menuItemJson = jsonEncode(menuItem.toJson());
                  GoRouter.of(context).push(
                    '/menu',
                    extra: menuItemJson, // Serialize the MenuItem to JSON
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0), // Reduced margin for smaller space
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    leading: menuItem.localPicturePath != null &&
                            menuItem.localPicturePath!.isNotEmpty
                        ? Image.file(
                            File(menuItem.localPicturePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.fastfood,
                            size: 40.0, color: Colors.orange), // Fallback icon
                    title: Text(
                      menuItem.itemName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      '${price.toStringAsFixed(2)} EGP',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
