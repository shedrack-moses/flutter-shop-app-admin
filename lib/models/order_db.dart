import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QuerySnapshot, FieldValue;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../models/order_model.dart'
    show Order, ShippingAddress, OrderItem, OrderStatus, PaymentStatus;

class OrderDb {
  // ... existing code ...

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ORDER OPERATIONS
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //current user
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // /// Generate unique order number
  // Future<String> _generateOrderNumber() async {
  //   // Format: ORD-YYYY-XXXXX
  //   final year = DateTime.now().year;

  //   // Get count of orders this year
  //   final ordersThisYear = await _firestore
  //       .collection('shop_orders')
  //       .where('createdAt',
  //           isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(year, 1, 1)))
  //       .get();

  //   final orderCount = ordersThisYear.docs.length + 1;
  //   final orderNumber = 'ORD-$year-${orderCount.toString().padLeft(5, '0')}';

  //   return orderNumber;
  // }

  // /// CREATE ORDER
  // /// This is the main method - creates order from cart items
  // Future<String> createOrder({
  //   required List<Cart> cartItems,
  //   required ShippingAddress shippingAddress,
  //   required String paymentMethod,
  //   double shippingFee = 0.0,
  //   double taxRate = 0.0, // e.g., 0.08 for 8% tax
  //   double discountAmount = 0.0,
  //   String? notes,
  // }) async {
  //   try {
  //     if (user == null) {
  //       throw Exception('User not logged in');
  //     }

  //     if (cartItems.isEmpty) {
  //       throw Exception('Cart is empty');
  //     }

  //     // Step 1: Convert cart items to order items
  //     final orderItems = cartItems.map((cartItem) {
  //       return OrderItem(
  //         productId: cartItem.productId,
  //         name: cartItem.name,
  //         price: cartItem.price,
  //         quantity: cartItem.quantity,
  //         imageUrl: cartItem.imageUrl,
  //       );
  //     }).toList();

  //     // Step 2: Calculate totals
  //     final subtotal = orderItems.fold<double>(
  //       0.0,
  //       (sum, item) => sum + item.subtotal,
  //     );

  //     final tax = subtotal * taxRate;
  //     final total = subtotal + shippingFee + tax - discountAmount;

  //     // Step 3: Generate order number
  //     final orderNumber = await _generateOrderNumber();

  //     // Step 4: Create order object
  //     final order = Order(
  //       userId: user!.uid,
  //       orderNumber: orderNumber,
  //       items: orderItems,
  //       shippingAddress: shippingAddress,
  //       subtotal: subtotal,
  //       shippingFee: shippingFee,
  //       tax: tax,
  //       discount: discountAmount,
  //       total: total,
  //       orderStatus: OrderStatus.pending,
  //       paymentStatus: PaymentStatus.pending,
  //       paymentMethod: paymentMethod,
  //       createdAt: DateTime.now(),
  //       notes: notes,
  //     );

  //     // Step 5: Use batch write for atomic operation
  //     final batch = _firestore.batch();

  //     // 5a. Add to main orders collection
  //     final mainOrderRef = _firestore.collection('shop_orders').doc();
  //     batch.set(mainOrderRef, order.toMap());

  //     // 5b. Add to user's orders subcollection
  //     final userOrderRef = _firestore
  //         .collection('shop_users')
  //         .doc(user!.uid)
  //         .collection('orders')
  //         .doc(mainOrderRef.id);
  //     batch.set(userOrderRef, order.toMap());

  //     // Step 6: Commit batch
  //     await batch.commit();

  //     print('✅ Order created successfully: $orderNumber');
  //     return mainOrderRef.id;
  //   } catch (e) {
  //     print('❌ Error creating order: $e');
  //     throw Exception('Failed to create order: $e');
  //   }
  // }

  /// READ USER'S ORDERS (Real-time stream)
  Stream<QuerySnapshot> readUserOrders() {
    if (user == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('shop_orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// GET SINGLE ORDER
  Future<Order?> getOrder(String orderId) async {
    try {
      if (user == null) {
        throw Exception('User not logged in');
      }

      final doc = await _firestore
          .collection('shop_users')
          .doc(user!.uid)
          .collection('orders')
          .doc(orderId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Order.fromDocument(doc);
    } catch (e) {
      print('❌ Error getting order: $e');
      return null;
    }
  }

  /// UPDATE ORDER STATUS
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    required PaymentStatus paymentStatus,
    String? trackingNumber,
    String? cancellationReason,
  }) async {
    try {
      if (user == null) {
        throw Exception('User not logged in');
      }

      final updateData = {
        'orderStatus': newStatus.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields
      if (trackingNumber != null) {
        updateData['trackingNumber'] = trackingNumber;
      }

      if (cancellationReason != null) {
        updateData['cancellationReason'] = cancellationReason;
      }

      // If status is delivered, set deliveredAt
      if (newStatus == OrderStatus.delivered) {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      // Use batch to update both locations
      final batch = _firestore.batch();

      // Update main collection
      final mainOrderRef = _firestore.collection('shop_orders').doc(orderId);
      batch.update(mainOrderRef, updateData);

      // Update user subcollection
      final userOrderRef = _firestore
          .collection('shop_users')
          .doc(user!.uid)
          .collection('orders')
          .doc(orderId);
      batch.update(userOrderRef, updateData);

      await batch.commit();

      print('✅ Order status updated to: ${newStatus.displayName}');
    } catch (e) {
      print('❌ Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  /// UPDATE PAYMENT STATUS
  Future<void> updatePaymentStatus({
    required String orderId,
    required PaymentStatus newStatus,
  }) async {
    try {
      if (user == null) {
        throw Exception('User not logged in');
      }

      final updateData = {
        'paymentStatus': newStatus.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If payment completed, update order status to processing
      if (newStatus == PaymentStatus.completed) {
        updateData['orderStatus'] = OrderStatus.processing.toFirestore();
      }

      final batch = _firestore.batch();

      final mainOrderRef = _firestore.collection('shop_orders').doc(orderId);
      batch.update(mainOrderRef, updateData);

      final userOrderRef = _firestore
          .collection('shop_users')
          .doc(user!.uid)
          .collection('orders')
          .doc(orderId);
      batch.update(userOrderRef, updateData);

      await batch.commit();

      print('✅ Payment status updated to: ${newStatus.displayName}');
    } catch (e) {
      print('❌ Error updating payment status: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// CANCEL ORDER
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      // First check if order can be cancelled
      final order = await getOrder(orderId);

      if (order == null) {
        throw Exception('Order not found');
      }

      if (!order.canBeCancelled) {
        throw Exception('Order cannot be cancelled at this stage');
      }

      await updateOrderStatus(
        orderId: orderId,
        newStatus: OrderStatus.cancelled,
        cancellationReason: reason,
        paymentStatus: PaymentStatus.failed,
      );

      print('✅ Order cancelled successfully');
    } catch (e) {
      print('❌ Error cancelling order: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// GET ORDER COUNT FOR USER
  Future<int> getUserOrderCount() async {
    try {
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('shop_users')
          .doc(user!.uid)
          .collection('orders')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting order count: $e');
      return 0;
    }
  }

  /// GET ORDERS BY STATUS
  Stream<QuerySnapshot> getOrdersByStatus(OrderStatus status) {
    if (user == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('shop_users')
        .doc(user!.uid)
        .collection('orders')
        .where('orderStatus', isEqualTo: status.toFirestore())
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
