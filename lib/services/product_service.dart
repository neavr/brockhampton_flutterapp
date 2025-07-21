import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  static Future<void> createProductWithImage({
    required String name,
    required String category,
    required String brand,
    required int price,
    required int stock,
    required String description,
    required File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/products');
    final request = http.MultipartRequest('POST', uri);

    // Attach text fields
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['brand'] = brand;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['description'] = description;

    // Attach file if not null
    if (imageFile != null) {
      final fileStream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image', // must match your Laravel request()->file('image')
        fileStream,
        length,
        filename: basename(imageFile.path),
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      print("Product created successfully");
    } else {
      final responseBody = await response.stream.bytesToString();
      print("Failed: ${response.statusCode}");
      print(responseBody); // Laravel's error message
      throw Exception('Failed to create product');
    }
  }

  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': product.name,
        'category': product.category,
        'brand': product.brand,
        'price': product.price,
        'stock': product.stock,
        'description': product.description,
        'image_url': product.imageUrl,
      }),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  static Future<Product?> updateProductWithImage({
    required Product product,
    File? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/products/update/${product.id}');

    // If there's an image, use MultipartRequest
    if (imageFile != null) {
      final request = http.MultipartRequest('POST', url);
      request.fields['name'] = product.name;
      request.fields['category'] = product.category;
      request.fields['brand'] = product.brand;
      request.fields['price'] = product.price.toString();
      request.fields['stock'] = product.stock.toString();
      request.fields['description'] = product.description ?? '';

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: basename(imageFile.path),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        return Product.fromJson(json.decode(responseBody));
      } else {
        print("Failed to update with image: ${streamedResponse.statusCode}");
        print(responseBody);
        return null;
      }
    }

    // Otherwise, just use a simple POST (form-url-encoded)
    final response = await http.post(
      url,
      body: {
        'name': product.name,
        'category': product.category,
        'brand': product.brand,
        'price': product.price.toString(),
        'stock': product.stock.toString(),
        'description': product.description ?? '',
      },
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      print("Failed to update product: ${response.statusCode}");
      print(response.body);
      return null;
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

    print('DELETE status code: ${response.statusCode}');
    print('DELETE response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Success — either with or without body
      return;
    } else {
      throw Exception(
        'Failed to delete product. Status: ${response.statusCode}',
      );
    }
  }
}
