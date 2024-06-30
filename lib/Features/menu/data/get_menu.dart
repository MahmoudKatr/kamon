import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';

class GetMenu {
  final Map<String, List<double>> branches = {
    'Cairo': [30.0444, 31.2357],
    'Alexandria': [31.2001, 29.9187],
    'Port Said': [31.2653, 32.3019],
  };

  Future<List<MenuItem>> getMenu() async {
    try {
      List<MenuItem> localMenuItems = await getLocalMenuItems();
      if (localMenuItems.isNotEmpty) {
        return localMenuItems;
      } else {
        return await fetchMenuFromServer();
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<MenuItem>> fetchMenuFromServer() async {
    print('Fetching menu from server...');
    int branchId = await _getBranchIdBasedOnLocation();
    final response = await http.get(Uri.parse(
        'http://$baseUrl:4000/admin/menu/branchMenuFilter/$branchId'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print('Response received: $jsonResponse');

      if (jsonResponse['status'] == 'success') {
        String lastUpdatedServer = jsonResponse['lastUpdated'] ?? '';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? lastUpdatedLocal = prefs.getString('lastUpdated');
        print('Last updated on server: $lastUpdatedServer');
        print('Last updated locally: $lastUpdatedLocal');

        if (lastUpdatedLocal == null || lastUpdatedLocal != lastUpdatedServer) {
          List<dynamic> itemData = jsonResponse['data'];
          List<MenuItem> menuItems =
              itemData.map((data) => MenuItem.fromJson(data)).toList();

          // Save menu items and images locally
          await _saveMenuItemsLocally(menuItems);
          await prefs.setString('lastUpdated', lastUpdatedServer);

          print('Menu items: $menuItems');
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
  }

  Future<void> _saveMenuItemsLocally(List<MenuItem> menuItems) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> menuItemsJson =
        menuItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('menuItems', menuItemsJson);
    print('Menu items saved locally: $menuItemsJson'); // Debug print

    for (var item in menuItems) {
      if (item.picturePath != null && item.picturePath!.isNotEmpty) {
        String localPath = await _downloadAndSaveImage(item.picturePath!);
        item.localPicturePath = localPath;
      }
    }

    // Save updated menu items with local image paths
    List<String> updatedMenuItemsJson =
        menuItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('menuItems', updatedMenuItemsJson);
    print(
        'Updated menu items with local image paths: $updatedMenuItemsJson'); // Debug print
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
      print('Error downloading image from $url: $e'); // Debug print
      return '';
    }
  }

  Future<List<MenuItem>> getLocalMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? menuItemsJson = prefs.getStringList('menuItems');
    if (menuItemsJson != null) {
      return menuItemsJson
          .map((itemJson) => MenuItem.fromJson(jsonDecode(itemJson)))
          .toList();
    } else {
      print('No local menu items found'); // Debug print
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
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double minDistance = double.infinity;
      String closestBranch = '';
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

      if (minDistance <= deliveryRadius) {
        return _getBranchId(closestBranch);
      } else {
        print('Out of delivery area'); // Debug print
        return 0; // Out of delivery area
      }
    } catch (e) {
      print('Failed to determine location: $e'); // Debug print
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
