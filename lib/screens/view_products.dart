import 'package:cached_network_image/cached_network_image.dart';
import 'package:eccomerce_app/components/disscount_functions.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({super.key});

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  Product? _productData;
  bool _isDataSet = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Product) {
      _productData = arguments;
      _isDataSet = true;
      setState(() {});

      // Set flag to prevent re-setting
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            //controller: controller,
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: _productData!.image,
                  fit: BoxFit.cover,
                  height: size.height * 0.45,
                  width: size.width,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _productData!.name,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          // SizedBox(width: 8),
                          if (_productData!.oldPrice != _productData!.newPrice)
                            Text(
                              "₦${_productData!.oldPrice.toString()}",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "₦${_productData!.newPrice.toString()}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              decoration: TextDecoration.none,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.green,
                            size: 20,
                          ),
                          Text(
                            "${calculateDiscount(oldPrice: _productData!.oldPrice, newPrice: _productData!.newPrice).split('.')[0]} %",
                            style: TextStyle(color: Colors.green, fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _productData!.maxQuantity == 0
                          ? Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              "Only ${_productData!.maxQuantity} items left in Stock ",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_productData!.description)
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  )))
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: Theme.of(context).cardColor,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: Text(
                  'Add to cart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {},
                child: Text(
                  'Buy Now',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
