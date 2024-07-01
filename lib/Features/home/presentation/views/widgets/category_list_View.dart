import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/Features/home/presentation/views/widgets/category_datils_screen.dart';
import 'package:kamon/constant.dart';
import 'dart:convert';


class CategoryListView extends StatefulWidget {
  const CategoryListView({Key? key}) : super(key: key);

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    String url = 'http://$baseUrl:4000/admin/branch/categories-list';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Map<String, dynamic>> loadedCategories = [];
      if (extractedData['status'] == 'success') {
        for (var categoryData in extractedData['data']) {
          loadedCategories.add({
            'categoryId': categoryData['category_id'],
            'categoryName': categoryData['category_name'],
            'picturePath': categoryData['picture_path'],
          });
        }
      }
      setState(() {
        _categories = loadedCategories;
      });
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          var category = _categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailScreen(
                      categoryId: category['categoryId'],
                      categoryName: category['categoryName']),
                ),
              );
            },
            child: _buildCategoryItem(
              category['categoryName'],
              category['picturePath'] ?? 
              "https://images.pexels.com/photos/1126359/pexels-photo-1126359.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imageUrl) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 16.0),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
