import 'kategori-model.dart';

class ProductDetail {
  final int id;
  final String name;
  final String description;
  final String originStory;
  final double price;
  final String? imageUrl;
  final Category category;
  final double rating;
  final int reviewCount;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.originStory,
    required this.price,
    this.imageUrl,
    required this.category,
    this.rating = 4.8,
    this.reviewCount = 230,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      originStory: json['origin_story'],
      price:
          json['price'] is String
              ? double.parse(json['price'])
              : json['price'].toDouble(),
      imageUrl: json['image_url'],
      category: Category.fromJson(json['category']),
      rating: json['rating']?.toDouble() ?? 4.8,
      reviewCount: json['review_count'] ?? 230,
    );
  }
}
