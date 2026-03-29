import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id, description, image, category, name;
  int oldPrice, newPrice, maxQuantity;

  Product(
      {required this.category,
      required this.description,
      required this.id,
      required this.image,
      required this.maxQuantity,
      required this.name,
      required this.newPrice,
      required this.oldPrice});

  factory Product.fromJson(Map<String, dynamic> data, String id) {
    return Product(
        category: data['category'] ?? '',
        description: data['description'] ?? 'no description',
        id: id,
        image: data['image'] ?? '',
        maxQuantity: _safeParseInt(data['maxQuantity']),
        name: data['name'] ?? '',
        newPrice: _safeParseInt(data['newPrice']),
        oldPrice: _safeParseInt(data['oldPrice']));
  }

  // Helper method to safely convert any number type to int
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt() ?? 0;
    }
    return 0;
  }

  static List<Product> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) => Product.fromJson(e.data() as Map<String, dynamic>, e.id))
        .toList();
  }
}
