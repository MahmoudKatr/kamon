import 'dart:convert';
import 'dart:developer';
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
    'Cairo': [30.0444, 31.2357],
    'Alexandria': [31.2001, 29.9187],
    'Port Said': [31.2653, 32.3019],
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
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<MenuItem>> fetchMenuFromServer() async {
    try {
      debugPrint('Fetching menu from server...');
      int branchId = await _getBranchIdBasedOnLocation();
      final response = await http.get(
        Uri.parse('http://$baseUrl:4000/admin/menu/branchMenuFilter/$branchId'),
      );

      log('Response received: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        debugPrint('Response received: $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          String lastUpdatedServer = jsonResponse['lastUpdated'] ?? '';
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? lastUpdatedLocal = prefs.getString('lastUpdated');
          debugPrint('Last updated on server: $lastUpdatedServer');
          debugPrint('Last updated locally: $lastUpdatedLocal');

          if (lastUpdatedServer.isEmpty || lastUpdatedLocal == null) {
            debugPrint('Missing lastUpdated timestamp. Fetching new data...');
            List<dynamic> itemData = jsonResponse['data'];
            List<MenuItem> menuItems =
                itemData.map((data) => MenuItem.fromJson(data)).toList();

            await _saveMenuItemsLocally(menuItems);
            await prefs.setString('lastUpdated', lastUpdatedServer);

            debugPrint('Menu items: $menuItems');
            return menuItems;
          } else if (lastUpdatedLocal != lastUpdatedServer) {
            List<dynamic> itemData = jsonResponse['data'];
            List<MenuItem> menuItems =
                itemData.map((data) => MenuItem.fromJson(data)).toList();

            await _saveMenuItemsLocally(menuItems);
            await prefs.setString('lastUpdated', lastUpdatedServer);

            debugPrint('Menu items: $menuItems');
            return menuItems;
          } else {
            return await getLocalMenuItems();
          }
        } else {
          throw Exception('Failed to load menu data');
        }
      } else {
        throw Exception('Failed to retrieve data');
      }
    } catch (e) {
      debugPrint('Error fetching menu from server: $e');
      return [];
    }
  }

  Future<void> _saveMenuItemsLocally(List<MenuItem> menuItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> menuItemsJson =
          menuItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('menuItems', menuItemsJson);
      debugPrint('Menu items saved locally: $menuItemsJson');

      for (var item in menuItems) {
        if (item.picturePath != null && item.picturePath!.isNotEmpty) {
          String localPath = await _downloadAndSaveImage(item.picturePath!);
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

  Future<String> _downloadAndSaveImage(String url) async {
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

  Future<int> _getBranchIdBasedOnLocation() async {
    try {
      await KamonPermissions.requestLocationPermission();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double minDistance = double.infinity;
      String closestBranch = '';
      const double deliveryRadius = 10000.0; // 10 km in meters

      for (var entry in branches.entries) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          entry.value[0],
          entry.value[1],
        );
        if (distance < minDistance) {
          minDistance = distance;
          closestBranch = entry.key;
        }
      }

      if (minDistance <= deliveryRadius) {
        int branchId = _getBranchId(closestBranch);
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

  int _getBranchId(String branchName) {
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
