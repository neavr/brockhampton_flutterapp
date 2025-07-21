import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _categoryController = TextEditingController(text: widget.product.category);
    _brandController = TextEditingController(text: widget.product.brand);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageUrlController.text = pickedFile.path; // just to show something
      });
    }
  }

  void _saveProduct() async {
    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text,
      category: _categoryController.text,
      brand: _brandController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      description: _descriptionController.text,
      imageUrl: widget.product.imageUrl,
    );

    final updated = await ProductService.updateProductWithImage(
      product: updatedProduct,
      imageFile: _selectedImage,
    );

    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      print('✅ Edit successful, popping with result: true');

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter product name'
                    : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: 'Brand'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Enter price';
                  final parsed = double.tryParse(value);
                  return parsed == null || parsed < 0 ? 'Invalid price' : null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Enter stock';
                  final parsed = int.tryParse(value);
                  return parsed == null || parsed < 0 ? 'Invalid stock' : null;
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Image"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, height: 150)
                        : widget.product.imageUrl.isNotEmpty
                        ? Image.network(widget.product.imageUrl, height: 150)
                        : Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text("Tap to select image"),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProduct, child: Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
