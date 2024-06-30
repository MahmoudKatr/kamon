import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/data/favorite_provider.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/menu/presentation/item_card.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Favorites'),
          ),
          body: favoritesProvider.favorites.isEmpty
              ? const Center(child: Text('No favorites added.'))
              : ListView.builder(
                  itemCount: favoritesProvider.favorites.length,
                  itemBuilder: (context, index) {
                    MenuItem item = favoritesProvider.favorites[index];
                    return ListTile(
                      title: Text(item.itemName),
                      subtitle: Text('\$${item.price}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => favoritesProvider.removeFavorite(item),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
