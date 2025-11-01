import 'kategori-model.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final String originStory;
  final double price;
  final String? imageUrl;
  final Category category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.originStory,
    required this.price,
    this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      originStory: json['origin_story'],
      // Safer parsing untuk price
      price:
          json['price'] is String
              ? double.parse(json['price'])
              : json['price'].toDouble(),
      imageUrl: json['image_url'],
      category: Category.fromJson(json['category']),
    );
  }
}
