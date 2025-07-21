import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatelessWidget {
  final String apiBaseUrl = 'http://10.0.2.2:8000/api'; // Adjust if needed

  Future<void> checkout(BuildContext context) async {
    final cart = Provider.of<CartModel>(context, listen: false);
    final List<Product> items = cart.items;

    try {
      for (var product in items) {
        final response = await http.put(
          Uri.parse('$apiBaseUrl/products/${product.id}/decrease-stock'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'quantity': 1}),
          
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update stock for ${product.name}');
        }
      }

      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout successful! 🎉')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: items.isEmpty
          ? Center(child: Text('Cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final product = items[index];
                      return ListTile(
                        leading: Image.network(product.imageUrl, width: 50, height: 50),
                        title: Text(product.name),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => cart.remove(product),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => checkout(context),
                        icon: Icon(Icons.payment),
                        label: Text('Checkout'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
