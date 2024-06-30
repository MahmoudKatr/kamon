// category_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamon/constant.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    const url = 'http://$baseUrl:4000/admin/branch/categories-list';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedData = jsonDecode(response.body)['data'];
        _categories =
            fetchedData.map((data) => Category.fromJson(data)).toList();
        notifyListeners();
      } else {
        throw 'Failed to load categories';
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }
}

class Category {
  final int categoryId;
  final String categoryName;
  final String sectionName;
  final String categoryDescription;

  Category(
      {required this.categoryId,
      required this.categoryName,
      required this.sectionName,
      required this.categoryDescription});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      sectionName: json['section_name'],
      categoryDescription: json['category_description'],
    );
  }
}
