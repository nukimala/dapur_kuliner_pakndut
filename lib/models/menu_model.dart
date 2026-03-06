class MenuModel {
  String? id;
  String name;
  String description;
  double price;
  String imageUrl;
  String category;

  MenuModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MenuModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }
}
