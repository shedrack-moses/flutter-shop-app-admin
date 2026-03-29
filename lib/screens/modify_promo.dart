import 'dart:io';

import 'package:eccomerce_app/controllers/firestore_db.dart';
import 'package:eccomerce_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/storage_sercices.dart';
import '../models/promo_banner_model.dart';

class ModifyPromo extends StatefulWidget {
  const ModifyPromo({super.key});

  @override
  State<ModifyPromo> createState() => _ModifyPromoState();
}

class _ModifyPromoState extends State<ModifyPromo> {
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  XFile? _file;
  String? productId;
  PromoBannerModel? _productData;
  bool _isDataSet = false;
  bool _isPromo = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set data once
    if (!_isDataSet) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        if (arguments['details'] is PromoBannerModel) {
          _productData = arguments['details'] as PromoBannerModel;
          setData(_productData!);
        }
        _isPromo = arguments['promo'] ?? true;
        _isDataSet = true;
      }
    }
  }

  void setData(PromoBannerModel data) {
    productId = data.id;
    _titleController.text = data.title;

    _selectedCategory = data.category;

    _imageController.text = data.image;

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
          Text(
            'No image selected',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            'Pick an image or enter URL below',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productId != null
            ? _isPromo
                ? 'Update Promos'
                : 'Update Banners'
            : _isPromo
                ? 'Add Promos'
                : 'Add Banners'),
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
                    hintText: 'Title',
                    label: Text('Title'),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  controller: _titleController,
                  validator: (value) =>
                      value!.isEmpty ? 'This can\'t be empty' : null,
                ),
                // SizedBox(
                //   height: 10,
                // ),
                //categories
                Material(
                  // elevation: 2,
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
                          value: validSelectedCategory,
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
                      // setState(() {});
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
                    onPressed: () {
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

                        try {
                          if (productId != null) {
                            // ✅ Create updated model with current form data
                            FirestoreDb().upDatePromos(
                                PromoBannerModel(
                                    id: productId!,
                                    title: _titleController.text.trim(),
                                    image: _imageController.text.trim(),
                                    category: _selectedCategory!),
                                _isPromo,
                                productId!);
                          } else {
                            FirestoreDb().createPromos(
                                PromoBannerModel(
                                    id: "",
                                    title: _titleController.text.trim(),
                                    image: _imageController.text.trim(),
                                    category: _selectedCategory!),
                                _isPromo);
                          }

                          // Close loading dialog
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(productId != null
                                  ? '${_isPromo ? 'Promos' : 'Banners'} updated successfully!'
                                  : '${_isPromo ? 'Promos' : 'Banners'} added successfully!'),
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
                      productId != null
                          ? _isPromo
                              ? 'Update Promos'
                              : 'Update Banners'
                          : _isPromo
                              ? 'Add Promos'
                              : 'Add Banners',
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
    _titleController.dispose();

    _imageController.dispose();
    super.dispose();
  }
}
