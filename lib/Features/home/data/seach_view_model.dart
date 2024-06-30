import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/data/get_menu.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';

class SearchViewModel extends ChangeNotifier {
  final GetMenu _apiService = GetMenu();
  List<MenuItem> allMenuItems = [];
  List<MenuItem> searchedForMenuItems = [];
  bool isLoading = false;
  bool _disposed = false;

  SearchViewModel() {
    fetchMenuItems();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchMenuItems() async {
    _setLoading(true);
    try {
      allMenuItems = await _apiService.getMenu();
      if (!_disposed) {
        _setLoading(false);
      }
    } catch (error) {
      if (!_disposed) {
        _setLoading(false);
        // Handle error (e.g., set an error state or show a message)
      }
    }
  }

  void searchMenuItems(String query) {
    if (query.isEmpty) {
      searchedForMenuItems = [];
    } else {
      searchedForMenuItems = allMenuItems
          .where((menuItem) =>
              menuItem.itemName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (!_disposed) {
      notifyListeners();
    }
  }
}
