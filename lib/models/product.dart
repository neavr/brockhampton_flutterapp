class Product {
  final int id;
  final String name;
  final String category;
  final String brand;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['image_url'];
    String imageUrl = rawImageUrl.startsWith('http')
        ? rawImageUrl
        : 'http://10.0.2.2:8000/$rawImageUrl';

    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      brand: json['brand'],
      description: json['description'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : double.parse(json['price'].toString()),
      stock: json['stock'],
      imageUrl: imageUrl,
    );
  }
}
