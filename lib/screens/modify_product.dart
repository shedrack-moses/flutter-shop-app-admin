import 'dart:io';

import 'package:eccomerce_app/controllers/firestore_db.dart';
import 'package:eccomerce_app/models/product.dart';
import 'package:eccomerce_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/custom_textfield.dart';
import '../controllers/storage_sercices.dart';

class ModifyProduct extends StatefulWidget {
  const ModifyProduct({super.key});

  @override
  State<ModifyProduct> createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  XFile? _file;
  String? productId;
  Product? _productData;
  bool _isDataSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set data once
    if (!_isDataSet) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Product) {
        _productData = arguments;
        setData(_productData!);
        _isDataSet = true;
      }
    }
  }

  void setData(Product data) {
    productId = data.id;
    _nameController.text = data.name;
    _originalPriceController.text = data.oldPrice.toString();
    _quantityController.text = data.maxQuantity.toString();
    _selectedCategory = data.category;
    _descriptionController.text = data.description;
    _sellingPriceController.text = data.newPrice.toString();
    _imageController.text = data.image;

    debugImageInfo();
    setState(() {});
  }

  Widget _buildImageDisplay() {
    // If user picked a new file, show that
    if (_file != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.deepPurple.shade50,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_file!.path),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      );
    }

    // If there's an image URL, show cached network image
    if (_imageController.text.isNotEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.deepPurple.shade50,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: _imageController.text,
            fit: BoxFit.cover,
            width: double.infinity,
            // CachedNetworkImage handles all the caching automatically
            placeholder: (context, url) => SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.red.shade400),
                  SizedBox(height: 8),
                  Text('Failed to load image',
                      style: TextStyle(color: Colors.red.shade600)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // No image selected
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 8),
          Text('No image selected',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text('Pick an image or enter URL below',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  void debugImageInfo() {
    print('=== IMAGE DEBUG INFO ===');
    print('Product ID: $productId');
    print('Image Controller Text: ${_imageController.text}');
    print('Selected File: ${_file?.path}');
    print('Product Data Image: ${_productData?.image}');
    print('Is Data Set: $_isDataSet');
    print('========================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productId != null ? 'Modify Product' : 'Add Product'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 15,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Product Name',
                    label: Text('Product Name'),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  controller: _nameController,
                  validator: (value) =>
                      value!.isEmpty ? 'This can\'t be empty' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Original price',
                    label: Text('Original price'),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                    prefixText: '\$ ',
                  ),
                  controller: _originalPriceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'This can\'t be empty';
                    if (double.tryParse(value) == null)
                      return 'Enter valid price';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sell price',
                    label: Text('Sell price'),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                    prefixText: '\$ ',
                  ),
                  controller: _sellingPriceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'This can\'t be empty';
                    if (double.tryParse(value) == null)
                      return 'Enter valid price';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Quantity left',
                    label: Text('Quantity'),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'This can\'t be empty';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter valid quantity!';
                    }
                    if (int.parse(value) < 0) {
                      return 'Quantity must be positive!';
                    }
                    return null;
                  },
                ),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Consumer<AdminProvider>(
                      builder: (context, provider, _) {
                        // Get unique categories
                        final uniqueCategories = provider.categories
                            .map((e) => e['name'] as String)
                            .where((name) => name.isNotEmpty)
                            .toSet()
                            .toList();

                        // Check if selected category exists in the list
                        String? validSelectedCategory = _selectedCategory;
                        if (_selectedCategory != null &&
                            !uniqueCategories.contains(_selectedCategory)) {
                          validSelectedCategory = null;
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: validSelectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Select category',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ...uniqueCategories
                                .map((category) => DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    )),
                          ],
                          validator: (value) =>
                              value == null ? 'Please select a category' : null,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                CustomTextfield(
                  validator: (value) => value == null || value.isEmpty
                      ? 'This can\'t be empty'
                      : null,
                  maxLines: 4,
                  controller: _descriptionController,
                  hintText: 'Product description...',
                  label: 'Description',
                  keyboardType: TextInputType.multiline,
                ),

                // Image Display Section
                _buildImageDisplay(),

                // Pick Image Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(13),
                      backgroundColor: Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      StorageServices().pickImage(context,
                          (pickedFile, imageUrl) {
                        setState(() {
                          _file = pickedFile;
                          _imageController.text = imageUrl;
                        });
                      });
                    },
                    icon: Icon(Icons.photo_camera),
                    label: Text(
                      'Pick Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Image URL Field
                TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/image.jpg',
                      label: Text('Image URL'),
                      fillColor: Colors.deepPurple.shade50,
                      filled: true,
                      prefixIcon: Icon(Icons.link),
                      suffixIcon: _imageController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                if (_imageController.text.isNotEmpty) {}
                              },
                            )
                          : null,
                    ),
                    controller: _imageController,
                    validator: (value) =>
                        value!.isEmpty ? 'Image URL can\'t be empty' : null,
                    onChanged: (value) {
                      setState(() {});
                    }),

                SizedBox(height: 10),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a category'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(productId != null
                                        ? 'Updating product...'
                                        : 'Adding product...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        Map<String, dynamic> data = {
                          'name': _nameController.text.trim(),
                          'oldPrice': int.parse(_originalPriceController.text),
                          'newPrice': int.parse(_sellingPriceController.text),
                          'maxQuantity': int.parse(_quantityController.text),
                          'category': _selectedCategory,
                          'description': _descriptionController.text.trim(),
                          'image': _imageController.text.trim(),
                        };

                        try {
                          if (productId != null) {
                            print('🟡 Updating product...');
                            await FirestoreDb().updateProducts(
                              id: productId!,
                              data: data,
                            );
                          } else {
                            print('🟡 Adding product...');
                            await FirestoreDb().addProducts(
                              data: data,
                            );
                          }

                          // Close loading dialog
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(productId != null
                                  ? 'Product updated successfully!'
                                  : 'Product added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate back
                          Navigator.pop(context);
                        } catch (e) {
                          // Close loading dialog
                          Navigator.pop(context);

                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      productId != null ? 'Update Product' : 'Add Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    _sellingPriceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}
