import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/utils/kamon_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetMenu {
  final Map<String, List<double>> branches = {
    'Alexandria': [31.2001, 29.9187],
    'Port Said': [31.2653, 32.3019],
    'Cairo': [30.0444, 31.2357],
  };

  Future<List<MenuItem>> getMenu() async {
    try {
      if (await _hasInternetConnection()) {
        return await fetchMenuFromServer();
      } else {
        return await getLocalMenuItems();
      }
    } catch (e) {
      debugPrint('Error in getMenu: $e'); // Debug debugPrint
      return [];
    }
  }

  Future<bool> _hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<MenuItem>> fetchMenuFromServer() async {
    try {
      debugPrint('Fetching menu from server...');
      int branchId = await getBranchIdBasedOnLocation();

      if (branchId == 0) {
        throw Exception('Invalid branch ID');
      }

      final response = await http.get(
        Uri.parse('http://$baseUrl:4000/admin/menu/branchMenuFilter/$branchId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to retrieve data');
      }

      var jsonResponse = jsonDecode(response.body);
      debugPrint('Response received: $jsonResponse');

      if (jsonResponse['status'] != 'success') {
        throw Exception('Failed to retrieve data');
      }

      List<dynamic> itemData = jsonResponse['data'];
      List<MenuItem> menuItems =
          itemData.map((data) => MenuItem.fromJson(data)).toList();

      debugPrint('Menu items: $menuItems');
      return menuItems;
    } catch (e) {
      debugPrint('Error fetching menu from server: $e');
      throw Exception('Failed to retrieve data');
    }
  }

  Future<List<MenuItem>> getMenuByBranch(int branchId) async {
    try {
      debugPrint('Fetching menu from server...');

      if (branchId == 0) {
        throw Exception('Invalid branch ID');
      }

      final response = await http.get(
        Uri.parse('http://$baseUrl:4000/admin/menu/branchMenuFilter/$branchId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to retrieve data');
      }

      var jsonResponse = jsonDecode(response.body);
      debugPrint('Response received: $jsonResponse');

      if (jsonResponse['status'] != 'success') {
        throw Exception('Failed to retrieve data');
      }

      List<dynamic> itemData = jsonResponse['data'];
      List<MenuItem> menuItems =
          itemData.map((data) => MenuItem.fromJson(data)).toList();

      debugPrint('Menu items: $menuItems');
      return menuItems;
    } catch (e) {
      debugPrint('Error fetching menu from server: $e');
      throw Exception('Failed to retrieve data');
    }
  }

  Future<void> saveMenuItemsLocally(List<MenuItem> menuItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> menuItemsJson =
          menuItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('menuItems', menuItemsJson);
      debugPrint('Menu items saved locally: $menuItemsJson');

      for (var item in menuItems) {
        if (item.picturePath != null && item.picturePath!.isNotEmpty) {
          String localPath = await downloadAndSaveImage(item.picturePath!);
          item.localPicturePath = localPath;
        }
      }

      List<String> updatedMenuItemsJson =
          menuItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('menuItems', updatedMenuItemsJson);
      debugPrint(
          'Updated menu items with local image paths: $updatedMenuItemsJson');
    } catch (e) {
      debugPrint('Error saving menu items locally: $e');
    }
  }

  Future<String> downloadAndSaveImage(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${url.split('/').last}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        return '';
      }
    } catch (e) {
      debugPrint('Error downloading image from $url: $e');
      return '';
    }
  }

  Future<List<MenuItem>> getLocalMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? menuItemsJson = prefs.getStringList('menuItems');
      if (menuItemsJson != null) {
        return menuItemsJson
            .map((itemJson) => MenuItem.fromJson(jsonDecode(itemJson)))
            .toList();
      } else {
        debugPrint('No local menu items found');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting local menu items: $e');
      return [];
    }
  }

  Future<void> saveRecommendedItemsLocally(
      int itemId, List<MenuItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> itemsJson =
        items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('recommendedItems_$itemId', itemsJson);
  }

  Future<List<MenuItem>> getLocalRecommendedItems(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? itemsJson = prefs.getStringList('recommendedItems_$itemId');
    if (itemsJson != null) {
      return itemsJson
          .map((itemJson) => MenuItem.fromJson(jsonDecode(itemJson)))
          .toList();
    } else {
      return [];
    }
  }

  Future<int> getBranchIdBasedOnLocation() async {
    try {
      await KamonPermissions.requestLocationPermission();

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String? closestBranch;
      double minDistance = double.infinity;
      const double deliveryRadius = 10000.0; // 10 km in meters

      branches.forEach((branch, coordinates) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          coordinates[0],
          coordinates[1],
        );
        if (distance < minDistance) {
          minDistance = distance;
          closestBranch = branch;
        }
      });

      if (closestBranch != null && minDistance <= deliveryRadius) {
        int branchId = getBranchId(closestBranch!);
        debugPrint(
            'Closest branch: $closestBranch with ID: $branchId at distance: $minDistance meters');
        return branchId;
      } else {
        debugPrint(
            'Out of delivery area. Closest branch: $closestBranch at distance: $minDistance meters');
        return 0; // Out of delivery area
      }
    } catch (e) {
      debugPrint('Failed to determine location: $e'); // Debug debugPrint
      return 0; // Failed to determine location
    }
  }

  int getBranchId(String branchName) {
    switch (branchName) {
      case 'Cairo':
        return 3;
      case 'Alexandria':
        return 1;
      case 'Port Said':
        return 2;
      default:
        return 0; // or handle appropriately
    }
  }
}
