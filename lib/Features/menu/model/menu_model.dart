class MenuItem {
  int itemId;
  String itemName;
  int categoryId;
  String itemDescription;
  PreparationTime preparationTime;
  String? picturePath;
  String? localPicturePath; // New property
  bool vegetarian;
  bool healthy;
  String itemStatus;
  String discount;
  String price;
  String averageRating;
  int ratersNumber;

  MenuItem({
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.itemDescription,
    required this.preparationTime,
    this.picturePath,
    this.localPicturePath, // Initialize new property
    required this.vegetarian,
    required this.healthy,
    required this.itemStatus,
    required this.discount,
    required this.price,
    required this.averageRating,
    required this.ratersNumber,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'],
      itemName: json['item_name'],
      categoryId: json['category_id'],
      itemDescription: json['item_description'],
      preparationTime: PreparationTime.fromJson(json['preparation_time']),
      picturePath: json['picture_path'],
      localPicturePath: json['local_picture_path'], // Read new property
      vegetarian: json['vegetarian'],
      healthy: json['healthy'],
      itemStatus: json['item_status'],
      discount: json['discount'],
      price: json['price'],
      averageRating: json['average_rating'],
      ratersNumber: json['raters_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'category_id': categoryId,
      'item_description': itemDescription,
      'preparation_time': preparationTime.toJson(),
      'picture_path': picturePath,
      'local_picture_path': localPicturePath, // Write new property
      'vegetarian': vegetarian,
      'healthy': healthy,
      'item_status': itemStatus,
      'discount': discount,
      'price': price,
      'average_rating': averageRating,
      'raters_number': ratersNumber,
    };
  }
}

class PreparationTime {
  int minutes;

  PreparationTime({
    required this.minutes,
  });

  factory PreparationTime.fromJson(Map<String, dynamic> json) {
    return PreparationTime(
      minutes: json['minutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minutes': minutes,
    };
  }
}
