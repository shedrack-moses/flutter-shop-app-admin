import 'package:cached_network_image/cached_network_image.dart';
import 'package:eccomerce_app/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/firestore_db.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, ref, child) {
          if (ref.isProductLoading) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          // ✅ Fix: Use the correct data source for products
          // Your Product.fromJsonList expects List<QueryDocumentSnapshot> directly
          List<Product> productsList = [];

          if (ref.products != null && ref.products!.isNotEmpty) {
            productsList = Product.fromJsonList(ref.products!);
          }

          // Debug: Print what we have
          print('Products from Firestore: ${ref.products?.length ?? 0}');
          print('Converted products: ${productsList.length}');

          // Debug: Print first product if available
          if (productsList.isNotEmpty) {
            print('First product: ${productsList.first.name}');
          }

          return productsList.isEmpty
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
                        'No Products Found!',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_product');
                        },
                        child: Text('Add First Product'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: productsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = productsList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, '/view_product',
                              arguments: product);
                        },
                        leading: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                11), // Slightly smaller to account for border
                            child: CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_outlined,
                                        size: 30, color: Colors.grey[400]),
                                    SizedBox(height: 4),
                                    Text('Loading...',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined,
                                        size: 30, color: Colors.red[300]),
                                    SizedBox(height: 4),
                                    Text('Error',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red[400])),
                                  ],
                                ),
                              ),
                              fadeInDuration: Duration(milliseconds: 300),
                              fadeOutDuration: Duration(milliseconds: 100),
                            ),
                          ),
                        ),
                        title: Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "₦${product.newPrice.toString()}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (product.oldPrice != product.newPrice)
                                  Text(
                                    "₦${product.oldPrice.toString()}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Qty: ${product.maxQuantity}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // ✅ Debug: Print the product data being passed
                              print('Editing product: ${product.name}');
                              print('Product ID: ${product.id}');

                              Navigator.pushNamed(
                                context,
                                '/add_product', // Make sure this route exists
                                arguments: product,
                              ).then((_) {
                                // Refresh the page when returning from edit
                                setState(() {});
                              });
                            } else if (value == 'delete') {
                              _showDeleteDialog(
                                context,
                                product,
                              );
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text('Delete'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_product').then((_) {
            // Refresh the page when returning from add
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirestoreDb().deleteProducts(id: product.id);
                // Add your delete logic here
                // provider.deleteProduct(product.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product deleted successfully')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
