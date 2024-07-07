import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/Features/menu/presentation/circular_image.dart';
import 'package:kamon/Features/menu/presentation/item_card.dart';
import 'package:kamon/Features/menu/presentation/item_screen_clip_path.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItem menuItem;

  const ItemDetailScreen({super.key, required this.menuItem});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialize the favorite state here if needed
  }

  void addToFavorites() {
    setState(() {
      isFavorite = !isFavorite;
    });
    debugPrint("Added to favorites: ${widget.menuItem.itemName}");
  }

  void handleBack() {
    Navigator.of(context).pop();
  }

  void handleCart() {
    // Logic to handle cart
    debugPrint("Go to cart");
  }

  @override
  Widget build(BuildContext context) {
    final double price = double.tryParse(widget.menuItem.price) ?? 0.0;

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: BaseClipper(),
            child: ItemScreenClipPath(
              menuItem: widget.menuItem,
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
                      imageUrl: widget.menuItem.picturePath != null &&
                              widget.menuItem.picturePath!.isNotEmpty
                          ? widget.menuItem.picturePath!
                          : testImage, // Use a default image if picturePath is null or empty
                      size: 150.0,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        widget.menuItem.itemStatus == 'active'
                            ? Icons.check_circle
                            : Icons.warning,
                        color: widget.menuItem.itemStatus == 'active'
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
                    padding: const EdgeInsets.only(top: 0.0, right: 16, left: 16),
                    child: Column(
                      children: [
                        ItemDetailCard(
                          mealTime: widget.menuItem.categoryId.toString(),
                          itemName: widget.menuItem.itemName,
                          rating: double.parse(widget.menuItem.averageRating),
                          reviewsCount: widget.menuItem.ratersNumber,
                          price: price,
                          itemId: widget.menuItem.itemId,
                          itemDescription: widget.menuItem.itemDescription,
                          vegetarian: widget.menuItem.vegetarian,
                          healthy: widget.menuItem.healthy,
                          itemStatus: widget.menuItem.itemStatus,
                          preparationTime: widget.menuItem.preparationTime.minutes,
                          menuItem: widget.menuItem,
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
