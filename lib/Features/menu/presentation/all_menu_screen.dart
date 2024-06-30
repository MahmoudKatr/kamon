import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/home/data/seach_view_model.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
        ),
        body: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.allMenuItems.isEmpty) {
              return const Center(child: Text('No menu items found'));
            } else {
              return ListView.builder(
                itemCount: viewModel.allMenuItems.length,
                itemBuilder: (context, index) {
                  MenuItem menuItem = viewModel.allMenuItems[index];
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(
                        '/menu',
                        extra: {
                          'itemId': menuItem.itemId,
                          'itemName': menuItem.itemName,
                          'itemDescription': menuItem.itemDescription,
                        },
                      );
                    },
                    child: ListTile(
                      title: Text(menuItem.itemName),
                      subtitle: Text(menuItem.itemDescription),
                      trailing: Text('\$${menuItem.price}'),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
