import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/Features/menu/presentation/circular_image.dart';
import 'package:kamon/Features/menu/presentation/item_card.dart';
import 'package:kamon/Features/menu/presentation/item_screen_clip_path.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

class ItemDetailScreen extends StatelessWidget {
  final MenuItem menuItem;

  const ItemDetailScreen({super.key, required this.menuItem});

  void addToFavorites() {
    // Logic to add to favorites
    debugPrint("Added to favorites: ${menuItem.itemName}");
  }

  void handleBack() {
    // Logic to handle back navigation
  }

  void handleCart() {
    // Logic to handle cart
  }

  @override
  Widget build(BuildContext context) {
    final double price = double.tryParse(menuItem.price) ?? 0.0;

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: BaseClipper(),
            child: ItemScreenClipPath(
              menuItem: menuItem,
              onFavoriteTap: addToFavorites,
              onBackTap: handleBack,
              onCartTap: handleCart,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 150),
              Center(
                child: Stack(
                  children: [
                    CircularImageWithShadow(
                      imageUrl: menuItem.picturePath != null &&
                              menuItem.picturePath!.isNotEmpty
                          ? menuItem.picturePath!
                          : testImage, // Use a default image if picturePath is null or empty
                      size: 150.0,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        menuItem.itemStatus == 'active'
                            ? Icons.check_circle
                            : Icons.warning,
                        color: menuItem.itemStatus == 'active'
                            ? Colors.green
                            : Colors.red,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 0.0, right: 16, left: 16),
                    child: Column(
                      children: [
                        ItemDetailCard(
                          mealTime: menuItem.categoryId.toString(),
                          itemName: menuItem.itemName,
                          rating: double.parse(menuItem.averageRating),
                          reviewsCount: menuItem.ratersNumber,
                          price: price,
                          itemId: menuItem.itemId,
                          itemDescription: menuItem.itemDescription,
                          vegetarian: menuItem.vegetarian,
                          healthy: menuItem.healthy,
                          itemStatus: menuItem.itemStatus,
                          preparationTime: menuItem.preparationTime.minutes,
                          menuItem: menuItem,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
