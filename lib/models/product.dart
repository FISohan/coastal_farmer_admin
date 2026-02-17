class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final String unit;
  final String image;
  final double discount;
  final double originalPrice;
  final bool isPublic;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.stock = 0,
    this.unit = 'kg',
    required this.image,
    this.discount = 0,
    this.originalPrice = 0,
    this.isPublic = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? 'kg',
      image: json['image'],
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
      isPublic: json['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'unit': unit,
      'image': image,
      'discount': discount,
      'originalPrice': originalPrice,
      'isPublic': isPublic,
    };
  }
}
