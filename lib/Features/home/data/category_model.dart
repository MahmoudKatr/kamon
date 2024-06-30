class Category {
  final int categoryId;
  final String categoryName;
  final String sectionName;
  final String categoryDescription;
  final String picturePath;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.sectionName,
    required this.categoryDescription,
    required this.picturePath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      sectionName: json['section_name'],
      categoryDescription: json['category_description'],
      picturePath: json['picture_path'],
    );
  }
}
