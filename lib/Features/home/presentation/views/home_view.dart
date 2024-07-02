import 'package:flutter/material.dart';
import 'package:kamon/Features/home/data/seach_view_model.dart';
import 'package:kamon/Features/home/presentation/views/widgets/category_list_View.dart';
import 'package:kamon/Features/home/presentation/views/widgets/srach_result_list.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/home/presentation/views/widgets/best_saller_list_view.dart';
import 'package:kamon/Features/home/presentation/views/widgets/home_clip.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';

class HomeView extends StatelessWidget {
  final String branchLocation;
  final int branchId;

  const HomeView(
      {super.key, required this.branchLocation, required this.branchId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(),
      child: Scaffold(
        body: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipPath(
                      clipper: BaseClipper(),
                      child: HomeClip(branchLocation: branchLocation),
                    ),
                    // SingleChildScrollView starts right after the ClipPath
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Categories',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              CategoryListView(), // Ensure you have set up a default constructor if needed
                              SizedBox(height: 24.0),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Best Seller',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ]),
                              SizedBox(height: 16.0),
                              BestSellerListView(
                                bestSellers: [
                                  {'imageUrl': testImage, 'price': '103.0', 'name': 'Item 1'},
                                  {'imageUrl': testImage, 'price': '103.0', 'name': 'Item 2'},
                                  {'imageUrl': testImage, 'price': '103.0', 'name': 'Item 3'},
                                  {'imageUrl': testImage, 'price': '103.0', 'name': 'Item 5'},
                                  {'imageUrl': testImage, 'price': '103.0', 'name': 'Item 6'},
                                  // Add other best selling items as needed
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.searchedForMenuItems.isNotEmpty)
                  const SearchResultList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BestSellerListView extends StatelessWidget {
  final List<Map<String, String>> bestSellers;

  const BestSellerListView({Key? key, required this.bestSellers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: bestSellers.length,
        itemBuilder: (context, index) {
          return BestSellerCard(
            imageUrl: bestSellers[index]['imageUrl']!,
            price: bestSellers[index]['price']!,
            name: bestSellers[index]['name']!, // Ensure 'name' is added to each item
          );
        },
      ),
    );
  }
}
