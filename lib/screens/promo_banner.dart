import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eccomerce_app/controllers/firestore_db.dart';
import 'package:eccomerce_app/models/promo_banner_model.dart';
import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  bool isInitialized = false;
  bool isPromo = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //if it's not initialize then we have to initialize it.
      if (!isInitialized) {
        final arguments = ModalRoute.of(context)!.settings.arguments;
        //check
        if (arguments is Map<String, dynamic>) {
          isPromo = arguments['promo'] ?? true;
        }
        print('promo $isPromo');
        isInitialized = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isPromo ? "Promos" : 'Banners'),
      ),
      body: isInitialized
          ? StreamBuilder(
              stream: FirestoreDb().readPromos(isPromo),
              //initialData: [],
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  var promos =
                      PromoBannerModel.fromJsonList(snapshot.data!.docs);
                  if (promos.isEmpty) {
                    Center(
                      child: Text(
                          isPromo ? 'No Promos found' : 'No Banners found'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: promos.length,
                      itemBuilder: (BuildContext context, int index) {
                        var promo = promos[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/modify_promos',
                                  arguments: {
                                    'promo': isPromo,
                                    'details': promo,
                                  });
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
                                  imageUrl: promo.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              promo.title,
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
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    promo.category.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  // ✅ Debug: Print the product data being passed
                                  print('Editing product: ${promo.title}');

                                  Navigator.pushNamed(context,
                                      '/modify_promos', // Make sure this route exists
                                      arguments: {
                                        'promo': isPromo,
                                        'details': promo,
                                      }).then((_) {
                                    // Refresh the page when returning from edit
                                    setState(() {});
                                  });
                                } else if (value == 'delete') {
                                  _showDeleteDialog(
                                    isPromo,
                                    context,
                                    promo,
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
                  }
                }
                return Center(child: CircularProgressIndicator.adaptive());
              },
            )
          : SizedBox.shrink(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/modify_promos', arguments: {
            'promo': isPromo,
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
    bool isPromo,
    BuildContext context,
    PromoBannerModel product,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${isPromo ? 'Promos' : 'Banners'}'),
          content: Text(
              'Are you sure you want to delete "${product.title}${isPromo ? 'Promo' : 'Banner'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirestoreDb().deletePromos(product.id, isPromo);
                // Add your delete logic here
                // provider.deleteProduct(product.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '"${product.title}${isPromo ? 'Promo' : 'Banner'}"deleted successfully'),
                  ),
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
