import 'package:flutter/material.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';

class ItemScreenClipPath extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback onFavoriteTap;
  final VoidCallback onBackTap;
  final VoidCallback onCartTap;

  const ItemScreenClipPath({
    super.key,
    required this.menuItem,
    required this.onFavoriteTap,
    required this.onBackTap,
    required this.onCartTap,
  });

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
                    onTap: onBackTap,
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
                    onTap: onFavoriteTap,
                    child: const Center(
                      child: Icon(
                        Icons.favorite_border,
                        color: kPrimaryColor,
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
                    onTap: onCartTap,
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
