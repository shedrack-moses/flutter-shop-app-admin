import 'dart:core';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eccomerce_app/models/category_model.dart';
import 'package:eccomerce_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/firestore_db.dart';
import '../controllers/storage_sercices.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FirestoreDb _db = FirestoreDb();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('categories'),
      ),
      body: Consumer<AdminProvider>(builder: (context, value, child) {
        // Add loading state check
        if (value.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<CategoryModel> categories =
            CategoryModel.fromJsonList(value.categories);

        return categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Text(
                      'Categories is Empty!!',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.deepPurple,
                      ),
                    )
                  ],
                ),
              )
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  var category = categories[index];
                  return Card(
                    child: ListTile(
                      leading: SizedBox(
                        height: 60,
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: category.image.isEmpty
                              ? Icon(Icons.image_not_supported,
                                  size: 30, color: Colors.grey)
                              : CachedNetworkImage(
                                  imageUrl: category.image,
                                  fit: BoxFit.cover,
                                  //height: 100,
                                  // width: 80,
                                  placeholder: (context, url) => SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    print(
                                        '❌ CachedNetworkImage error for ${category.name}: $error');
                                    print('❌ Failed URL: $url');
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Priority: ${category.priority}'),
                          SizedBox(height: 4),
                          if (category.image.isNotEmpty)
                            Text(
                              'Image: ${category.image.length > 40 ? "${category.image.substring(0, 40)}..." : category.image}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ModifyCategory(
                                      isUpdating: true,
                                      priority: category.priority,
                                      categoryId: category.id,
                                      image: category.image,
                                      name: category.name,
                                    );
                                  });
                            } else if (value == 'delete') {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Delete Category'),
                                      content: Text(
                                          'Are you sure you want to delete category "${category.name}?"'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {},
                                            child: Text('Cancel')),
                                        TextButton(
                                            onPressed: () {
                                              _db.deleteCategories(
                                                  docId: category.id);
                                              if (mounted) {
                                                Navigator.pop(context);
                                              }
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Category deleted')),
                                              );
                                            },
                                            child: Text('Delete'))
                                      ],
                                    );
                                  });
                            }
                          },
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                    title: Text(
                                      'Edit',
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    title: Text(
                                      'Delete',
                                    ),
                                  ),
                                ),
                              ]),
                    ),
                  );
                },
              );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ModifyCategory(
                    isUpdating: false, priority: 0, categoryId: '');
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ModifyCategory extends StatefulWidget {
  final bool isUpdating;
  final String? name;
  final String? image;
  final int priority;
  final String categoryId;
  const ModifyCategory(
      {super.key,
      required this.isUpdating,
      this.name,
      this.image,
      required this.priority,
      required this.categoryId});

  @override
  State<ModifyCategory> createState() => _ModifyCategoryState();
}

class _ModifyCategoryState extends State<ModifyCategory> {
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  XFile? _file;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  @override
  void dispose() {
    _priorityController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.isUpdating && widget.name != null) {
      _categoryController.text = widget.name!;
      _imageController.text = widget.image!;
      _priorityController.text = widget.priority.toString();
    }
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: Text(widget.isUpdating ? 'update category' : 'Add category'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // This is crucial!
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All will be converted to lowercase'),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'category name',
                    label: Text('Category name'),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  controller: _categoryController,
                  validator: (value) =>
                      value!.isEmpty ? 'This can\'t be empty' : null,
                ),
                SizedBox(height: 10),
                Text('Priority'),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'priority',
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  controller: _priorityController,
                  validator: (value) =>
                      value!.isEmpty ? 'This can\'t be empty' : null,
                ),
                SizedBox(height: 10),
                // Image preview container
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: double.infinity,
                  ),
                  child: _file == null
                      ? _imageController.text.isNotEmpty
                          ? Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.deepPurple.shade50,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: _imageController.text,
                                height: 200,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.red.shade50,
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 48, color: Colors.red.shade400),
                                      SizedBox(height: 8),
                                      Text('Failed to load image',
                                          style: TextStyle(
                                              color: Colors.red.shade600)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink()
                      : Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.deepPurple.shade50,
                          ),
                          child: Image.file(
                            File(_file!.path),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(13),
                      backgroundColor: Theme.of(context).primaryColor,
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
                    child: Text(
                      'Pick image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'image link',
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                  ),
                  controller: _imageController,
                  validator: (value) =>
                      value!.isEmpty ? 'This can\'t be empty' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (widget.isUpdating) {
                FirestoreDb().updateCategories(docId: widget.categoryId, data: {
                  'name': _categoryController.text.trim().toLowerCase(),
                  'priority': int.tryParse(_priorityController.text.trim()),
                  'image': _imageController.text.trim(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Category updated successfully!!')),
                );
              } else {
                FirestoreDb().createCategories(data: {
                  'name': _categoryController.text.trim().toLowerCase(),
                  'priority': int.tryParse(_priorityController.text.trim()),
                  'image': _imageController.text.trim(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Category added successfully!!')),
                );
              }
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.isUpdating ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
