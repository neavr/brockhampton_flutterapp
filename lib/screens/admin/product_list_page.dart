import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductListPage extends StatefulWidget {
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = ProductService.fetchProducts();
  }

  void _navigateToCreatePage() async {
    final result = await Navigator.pushNamed(context, '/add');
    if (result == true) {
      setState(() {
        products = ProductService.fetchProducts();
      });
    }
  }

  void _navigateToEditPage(Product p) async {
    final result = await Navigator.pushNamed(context, '/edit', arguments: p);
    if (result == true) {
      setState(() {
        products = ProductService.fetchProducts();
      });
    }
  }

  void _deleteProduct(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProductService.deleteProduct(p.id);

        setState(() {
          // Instead of removeWhere, re-fetch the list:
          products = ProductService.fetchProducts();
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${p.name} deleted')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
      }
    }
  }

  void _viewDetails(Product p) {
    // TODO: Add your detail page route here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Viewing details for ${p.name}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Product Catalog")),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final p = snapshot.data![index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/detail', arguments: p);
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        p.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    title: Text(p.name),
                    subtitle: Text('${p.category} - ${p.brand}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: p,
                            );
                            if (result == true) {
                              setState(() {
                                products = ProductService.fetchProducts();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text(
                                  'Are you sure you want to delete "${p.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ProductService.deleteProduct(p.id);

                              setState(() {
                                // just trigger the fetch again
                                products = ProductService.fetchProducts();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${p.name} deleted')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePage,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}
