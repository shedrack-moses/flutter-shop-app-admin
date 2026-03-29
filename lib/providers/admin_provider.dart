import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eccomerce_app/controllers/firestore_db.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider() {
    getCategories();
    getProducts();
  }

  StreamSubscription<QuerySnapshot>? _streamSubscription;
  List<QueryDocumentSnapshot> categories = [];
  int totalCategories = 0;
  bool isLoading = true; // Add loading state
//Orders
  int totalOrders = 0;
  int totalOrderDelivered = 0;
  int orderCancelled = 0;
  int ordersOnWay = 0;

//products

  StreamSubscription<QuerySnapshot>? _productsSubscription;
  List<QueryDocumentSnapshot>? products = [];
  int totalProducts = 0;
  bool isProductLoading = true; // Add loading state

  getCategories() {
    print('Getting categories...');
    _streamSubscription?.cancel();

    _streamSubscription = FirestoreDb().readCategory().listen((data) {
      print('Received ${data.docs.length} categories from Firestore');
      categories = data.docs;
      totalCategories = data.docs.length;
      isLoading = false;

      // Print category data for debugging
      for (var doc in data.docs) {
        print('Category: ${doc.data()}');
      }

      notifyListeners(); // Move this INSIDE the listener
    }, onError: (error) {
      print('Error getting categories: $error');
      isLoading = false;
      notifyListeners();
    });
  }

  getProducts() {
    //cancel the stream first
    _productsSubscription?.cancel();
    _productsSubscription = FirestoreDb().readProducts().listen((data) {
      products = data.docs;
      totalProducts = data.docs.length;
      isProductLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error getting categories: $error');
      isProductLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
