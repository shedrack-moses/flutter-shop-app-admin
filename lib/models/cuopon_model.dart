import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  int discount;
  String? id;
  String code, desc;

  CouponModel({
    required this.code,
    required this.desc,
    required this.discount,
    this.id,
  });

  factory CouponModel.fromJson(Map<String, dynamic> data, String id) {
    return CouponModel(
      code: data['code'] ?? '',
      desc: data['desc'] ?? '',
      discount: data['discount'] ?? 0,
      id: id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "desc": desc,
      "discount": discount, // ✅ FIXED: Changed "dicount" to "discount"
      "code": code,
    };
  }

  static List<CouponModel> jsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map(
            (e) => CouponModel.fromJson(e.data() as Map<String, dynamic>, e.id))
        .toList();
  }
}
