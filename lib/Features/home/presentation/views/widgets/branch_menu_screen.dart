import 'package:flutter/material.dart';
import 'package:kamon/Features/home/presentation/views/widgets/category_datils_screen.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

import '../../../../menu/data/get_menu.dart';

class BranchMenuScreen extends StatefulWidget {
  final int branchId;
  final String branchName;

  const BranchMenuScreen(
      {super.key, required this.branchId, required this.branchName});

  @override
  // ignore: library_private_types_in_public_api
  _BranchMenuScreenState createState() => _BranchMenuScreenState();
}

class _BranchMenuScreenState extends State<BranchMenuScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = fetchBranchMenu(widget.branchId);
  }

  Future<List<MenuItem>> fetchBranchMenu(int branchId) async {
    try {
      GetMenu getMenu = GetMenu();
      return await getMenu.getMenuByBranch(branchId); // Fetch menu by branch ID
    } catch (e) {
      debugPrint('Error fetching menu for branch $branchId: $e');
      return Future.value([]); // Return an empty list wrapped in a Future
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ClipPath(
            clipper: BaseClipper(), // Ensures the top part is clipped
            child: Container(
              color: kPrimaryColor, // Background color for visual clarity
              height: 130, // Fixed height for the clipped area
              width: double.infinity,
              child: Center(
                child: Text(
                  "${widget.branchName} Branch Menu",
                  style: kPrimaryFont(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kSecondaryColor,
                  ),
                ),
              ), // Just a placeholder
            ),
          ),
          Expanded(
            // Ensures the remaining space is filled by GridView
            child: FutureBuilder<List<MenuItem>>(
              future: _menuItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No items found"));
                } else {
                  final items = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        MenuItemCard(item: items[index]),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
