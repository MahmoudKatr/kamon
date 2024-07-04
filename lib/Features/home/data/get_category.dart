import 'package:flutter/material.dart';
import 'package:kamon/Features/menu/model/category_model.dart';
import 'package:kamon/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    const url = 'http://$baseUrl:4000/admin/branch/categories-list';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Category> loadedCategories = [];
      if (extractedData['status'] == 'success') {
        for (var categoryData in extractedData['data']) {
          loadedCategories.add(Category.fromJson(categoryData));
        }
      }
      setState(() {
        _categories = loadedCategories;
      });
    } catch (error) {
      // Handle errors here
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
          // Assuming you have some way to derive image URLs for categories
          return _buildCategoryItem(category.categoryName,
              "https://images.pexels.com/photos/1126359/pexels-photo-1126359.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1");
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
