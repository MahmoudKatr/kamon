import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<MenuItem> _favorites = [];

  List<MenuItem> get favorites => _favorites;

  void addFavorite(MenuItem item) {
    _favorites.add(item);
    notifyListeners();
  }

  void removeFavorite(MenuItem item) {
    _favorites.removeWhere((element) => element.itemId == item.itemId);
    notifyListeners();
  }
}
