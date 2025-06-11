class Product {
  final String id;
  final String name;
  final String? description; // Peut être nul
  final double price;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit l'objet [Product] en JSON pour les requêtes API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crée un objet [Product] à partir d'une réponse JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
