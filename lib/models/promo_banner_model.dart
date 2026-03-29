class PromoBannerModel {
  final String id;
  final String title;
  final String image;
  final String category;

  PromoBannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
  });

  // Convert from JSON Map to PromoBannerModel
  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    return PromoBannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  // Convert from PromoBannerModel to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'category': category,
    };
  }

  // Convert from Firestore DocumentSnapshot
  factory PromoBannerModel.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return PromoBannerModel(
      id: docId,
      title: data['title'] as String? ?? '',
      image: data['image'] as String? ?? '',
      category: data['category'] as String? ?? '',
    );
  }

  // Convert List of JSON Maps to List of PromoBannerModel
  static List<PromoBannerModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PromoBannerModel.fromFirestore(
            json.data() as Map<String, dynamic>, json.id))
        .toList();
  }

  // Convert List of PromoBannerModel to List of JSON Maps
  static List<Map<String, dynamic>> toJsonList(List<PromoBannerModel> banners) {
    return banners.map((banner) => banner.toJson()).toList();
  }

  // Copy with method for creating modified copies
  PromoBannerModel copyWith({
    String? id,
    String? title,
    String? image,
    String? category,
  }) {
    return PromoBannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromoBannerModel &&
        other.id == id &&
        other.title == title &&
        other.image == image &&
        other.category == category;
  }

  // Hash code
  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ image.hashCode ^ category.hashCode;
  }

  // String representation
  @override
  String toString() {
    return 'PromoBannerModel(id: $id, title: $title, image: $image, category: $category)';
  }

  // Validation method
  bool get isValid {
    return id.isNotEmpty &&
        title.isNotEmpty &&
        image.isNotEmpty &&
        category.isNotEmpty;
  }

  // Check if image URL is valid
  bool get hasValidImageUrl {
    return image.isNotEmpty &&
        (image.startsWith('http://') || image.startsWith('https://'));
  }
}
