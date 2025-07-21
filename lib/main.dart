import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'models/cart.dart';
import 'main_wrapper.dart';
import 'screens/admin/add_product_page.dart';
import 'screens/admin/edit_product_page.dart';
import 'screens/admin/product_detail_page.dart';
import 'screens/user/cart_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: ProductApp(),
    ),
  );
}

class ProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainWrapper(),
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => EditProductPage(product: product),
          );
        } else if (settings.name == '/add') {
          return MaterialPageRoute(builder: (context) => AddProductPage());
        } else if (settings.name == '/detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          );
        } else if (settings.name == '/cart') {
          return MaterialPageRoute(builder: (context) => CartPage());
        }
        return null;
      },
    );
  }
}
