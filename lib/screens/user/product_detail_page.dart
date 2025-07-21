import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/cart.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 100),
              ),
            ),
            SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Category: ${product.category}'),
            Text('Brand: ${product.brand}'),
            SizedBox(height: 8),
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
            SizedBox(height: 8),
            Text('Stock: ${product.stock}'),
            SizedBox(height: 16),
            Text(product.description),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CartModel>(
                    context,
                    listen: false,
                  ).addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
                icon: Icon(Icons.add_shopping_cart),
                label: Text("Add to Cart"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
