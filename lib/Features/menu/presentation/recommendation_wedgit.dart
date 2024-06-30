import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/Features/ordars/data/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class RecommendedItems extends StatelessWidget {
  final List<MenuItem> recommendedItems;

  const RecommendedItems({Key? key, required this.recommendedItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recommendedItems.isNotEmpty) ...[
          const Text(
            'Recommended Items:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180, // Adjust height based on the circular image size
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: recommendedItems.length,
              itemBuilder: (context, index) {
                final item = recommendedItems[index];
                return GestureDetector(
                  onTap: () {
                    final String itemJson = jsonEncode(item.toJson());
                    GoRouter.of(context).push('/menu', extra: itemJson);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 160, // Fixed width of each item
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: item.localPicturePath !=
                                            null &&
                                        item.localPicturePath!.isNotEmpty
                                    ? FileImage(File(item.localPicturePath!))
                                    : NetworkImage(item.picturePath ??
                                            'https://images.pexels.com/photos/1352274/pexels-photo-1352274.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1')
                                        as ImageProvider,
                                backgroundColor: Colors.transparent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('${item.price} EGP'),
                            ],
                          ),
                          Positioned(
                            right: 5, // Adjust this value as needed
                            bottom:
                                70, // Adjust this value to position inside the circle
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                backgroundColor: Colors.green,
                                child: const Icon(Icons.add, size: 16),
                                onPressed: () {
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .addItem(item, 1);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Item added to cart'),
                                  ));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const Text(
            'No recommended items found.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
