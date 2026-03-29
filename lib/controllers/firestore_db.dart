import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cuopon_model.dart';
import '../models/promo_banner_model.dart';

class FirestoreDb {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //read category from database
  Stream<QuerySnapshot> readCategory() {
    return _firestore
        .collection('shop_categories')
        .orderBy('priority', descending: true)
        .snapshots();
  }

  //create categories
  Future<void> createCategories({required Map<String, dynamic> data}) async {
    await _firestore.collection('shop_categories').add(data);
  }

  //update categories
  Future<void> updateCategories(
      {required String docId, required Map<String, dynamic> data}) async {
    await _firestore.collection('shop_categories').doc(docId).update(data);
  }

  //deleting categories
  Future<void> deleteCategories({
    required String docId,
  }) async {
    await _firestore.collection('shop_categories').doc(docId).delete();
  }

  //Products crud opoerations

  //read products from database
  Stream<QuerySnapshot> readProducts() {
    return _firestore.collection('shop_products').orderBy('name').snapshots();
  }

//add products to firestore
  Future<void> addProducts({required Map<String, dynamic> data}) async {
    await _firestore.collection('shop_products').add(data);
  }

  //update products
  Future<void> updateProducts(
      {required String id, required Map<String, dynamic> data}) async {
    await _firestore.collection('shop_products').doc(id).update(data);
  }

//delete products
  Future<void> deleteProducts({required String id}) async {
    await _firestore.collection('shop_products').doc(id).delete();
  }

  //PROMOBANNER CODE
  //read PROMO FROM FIREBASE,
  Stream<QuerySnapshot> readPromos(bool isPromo) {
    return _firestore
        .collection(isPromo ? 'shop_promos' : 'shop_banners')
        .snapshots();
  }

  //create promos
  Future<void> createPromos(PromoBannerModel data, bool isPromo) async {
    await _firestore
        .collection(isPromo ? 'shop_promos' : 'shop_banners')
        .add(data.toJson());
  }

  //update promos
  Future<void> upDatePromos(
    PromoBannerModel data,
    bool isPromo,
    String id,
  ) async {
    await _firestore
        .collection(isPromo ? 'shop_promos' : 'shop_banners')
        .doc(id)
        .update(data.toJson());
  }

  //delete promos
  Future<void> deletePromos(String id, bool isPromo) async {
    await _firestore
        .collection(isPromo ? 'shop_promos' : 'shop_banners')
        .doc(id)
        .delete();
  }

  //CRUD FOR COUPONS
  //read
  Stream<QuerySnapshot> readCoupons() =>
      _firestore.collection('shop_coupons').snapshots();
  //update
  Future<void> updateCoupons({
    required CouponModel data,
    required String id,
  }) async {
    await _firestore.collection('shop_coupons').doc(id).update(
          data.toJson(),
        );
  }

  //crerate coupons
  Future<void> createCoupons({required CouponModel data}) async {
    await _firestore.collection('shop_coupons').add(
          data.toJson(),
        );
  }

  //delete
  Future<void> deleteCuopons({required String id}) async {
    await _firestore.collection('shop_coupons').doc(id).delete();
  }
}
