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
    final data =
        json['data'] ?? json; // fallback if you're passed inner or outer
    return Product(
      id: data['id'] ?? 0, // or throw if id is required
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : double.tryParse(data['price'].toString()) ?? 0.0,
      stock: data['stock'] ?? 0,
      imageUrl: (() {
        String raw = data['image_url'] ?? '';
        return raw.startsWith('http') ? raw : 'http://10.0.2.2:8000/$raw';
      })(),
    );
  }
}
