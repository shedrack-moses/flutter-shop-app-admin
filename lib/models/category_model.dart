import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String name, image, id;
  int priority;
  CategoryModel({
    required this.name,
    required this.image,
    required this.id,
    required this.priority,
  });
  factory CategoryModel.fromJson(Map<String, dynamic> data, String id) {
    return CategoryModel(
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        id: id,
        priority: data['priority'] ?? '');
  }
  static List<CategoryModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) =>
            CategoryModel.fromJson(e.data() as Map<String, dynamic>, e.id))
        .toList();
  }
}
