import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamon/Features/home/data/seach_view_model.dart';
import 'package:kamon/Features/home/presentation/views/widgets/category_list_View.dart';
import 'package:kamon/Features/home/presentation/views/widgets/srach_result_list.dart';
import 'package:provider/provider.dart';
import 'package:kamon/Features/home/presentation/views/widgets/best_saller_list_view.dart';
import 'package:kamon/Features/home/presentation/views/widgets/home_clip.dart';
import 'package:kamon/constant.dart';
import 'package:kamon/core/shared_widget/base_clip_path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeView extends StatefulWidget {
  final String branchLocation;
  final int branchId;

  const HomeView(
      {super.key, required this.branchLocation, required this.branchId});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<Map<String, String>> bestSellers = [];
  List<Map<String, String>> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBestSellers();
    fetchCustomerRecommendations();
  }

  Future<void> fetchBestSellers() async {
    final response = await http.get(Uri.parse(
        'http://$baseUrl:4000/admin/branch/bestSeller?branchId=${widget.branchId}&startDate=2024-01-01&endDate=2024-12-31'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        bestSellers = (data['data'] as List).map<Map<String, String>>((item) {
          return {
            'imageUrl': item['fn_item_picture_path']?.toString() ?? testImage,
            'price': item['fn_item_price'].toString(),
            'name': item['fn_item_name'].toString(),
          };
        }).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load best sellers');
    }
  }

  Future<void> fetchCustomerRecommendations() async {
    String? customerId = await secureStorage.read(key: 'customer_id');
    if (customerId == null) {
      throw Exception('Customer ID not found in secure storage');
    }

    final response = await http.get(Uri.parse(
        'https://$baseUrl/admin/menu/customerRecommendations/$customerId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<int> recommendedIds =
          data.keys.map<int>((id) => int.parse(id)).toList();

      for (int id in recommendedIds) {
        await fetchRecommendationDetails(id);
      }
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load customer recommendations');
    }
  }

  Future<void> fetchRecommendationDetails(int id) async {
    final response = await http.get(Uri.parse(
        'https://$baseUrl/admin/menu/branchMenuFilter/${widget.branchId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final item = data['data']
          .firstWhere((item) => item['item_id'] == id, orElse: () => null);

      if (item != null) {
        setState(() {
          recommendations.add({
            'imageUrl': item['picture_path']?.toString() ?? testImage,
            'price': item['price'].toString(),
            'name': item['item_name'].toString(),
          });
        });
      }
    } else {
      throw Exception('Failed to load recommendation details');
    }
  }

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
                      child: HomeClip(branchLocation: widget.branchLocation),
                    ),
                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
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
                                    CategoryListView(),
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
                                        ]),
                                    SizedBox(height: 16.0),
                                    BestSellerListView(
                                        bestSellers: bestSellers),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Recommendation',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    RecommendationListView(
                                        recommendations: recommendations),
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

  const BestSellerListView({Key? key, required this.bestSellers})
      : super(key: key);

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
            name: bestSellers[index]['name']!,
          );
        },
      ),
    );
  }
}

class RecommendationListView extends StatelessWidget {
  final List<Map<String, String>> recommendations;

  const RecommendationListView({Key? key, required this.recommendations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return BestSellerCard(
            imageUrl: recommendations[index]['imageUrl']!,
            price: recommendations[index]['price']!,
            name: recommendations[index]['name']!,
          );
        },
      ),
    );
  }
}
