import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/constant.dart';

class ItemScreenClipPath extends StatefulWidget {
  final MenuItem menuItem;
  final VoidCallback onBackTap;
  final VoidCallback onCartTap;

  const ItemScreenClipPath({
    super.key,
    required this.menuItem,
    required this.onBackTap,
    required this.onCartTap,
  });

  @override
  _ItemScreenClipPathState createState() => _ItemScreenClipPathState();
}

class _ItemScreenClipPathState extends State<ItemScreenClipPath> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    String? customerId = await secureStorage.read(key: 'customer_id');
    // Check if the item is already a favorite (you can add a condition to check this from your backend)
    // For now, assuming it is not a favorite initially
    setState(() {
      isFavorite = false; // Replace this with actual check
    });
  }

Future<void> _toggleFavorite() async {
    String? customerId = await secureStorage.read(key: 'customer_id');
    int itemId = widget.menuItem.itemId;

    if (customerId == null) {
      // Handle error
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://$baseUrl:4000/admin/customers/addFavorite',
        data: {
          'customerId': customerId,
          'itemId': itemId.toString(),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = !isFavorite;
        });
        debugPrint('Response: ${response.data}');
      } else {
        // Handle API error
        debugPrint('Failed to toggle favorite. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      color: kPrimaryColor,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 40), // Space from the top
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 30,
                  width: 30,
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: widget.onBackTap,
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Spacing between icons
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 30,
                  width: 30,
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Center(
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Spacing
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 30,
                  width: 30,
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: widget.onCartTap,
                    child: const Center(
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Additional spacing
          Center(
            child: Image.asset(
                'assets/images/kamonText.png'), // Adjust the path as necessary
          ),
        ],
      ),
    );
  }
}
