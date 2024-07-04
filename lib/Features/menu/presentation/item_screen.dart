import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/Features/menu/presentation/item_detail_screen.dart';

class ItemScreen extends StatelessWidget {
  final MenuItem menuItem;

  const ItemScreen({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ItemDetailScreen(
          menuItem: menuItem,
        ),
      ),
    );
  }
}
