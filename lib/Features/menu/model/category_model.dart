class Category {
  final int categoryId;
  final String categoryName;
  final String sectionName;
  final String categoryDescription;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.sectionName,
    required this.categoryDescription,
  });

  factory Category.fromJson(Map<String, dynamic> jsonData) {
    return Category(
      categoryId: jsonData['category_id'] as int? ?? 0,
      categoryName: jsonData['category_name'] as String? ?? '',
      sectionName: jsonData['section_name'] as String? ?? '',
      categoryDescription: jsonData['category_description'] as String? ?? '',
    );
  }
}
