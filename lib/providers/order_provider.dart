import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:eccomerce_app/models/order_db.dart';
import 'package:flutter/material.dart';

import '../models/order_model.dart'
    show Order, OrderStatus, PaymentStatus, ShippingAddress;

class OrderProvider extends ChangeNotifier {
  OrderProvider() {
    initialize();
  }
  final OrderDb _db = OrderDb();

  StreamSubscription<QuerySnapshot>? _ordersSubscription;
//state of the app.

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  final bool _isCreatingOrder = false;

  // Getters
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;
  int get orderCount => _orders.length;

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.orderStatus == status).toList();
  }

  // Get pending orders
  List<Order> get pendingOrders => getOrdersByStatus(OrderStatus.pending);

  // Get processing orders
  List<Order> get processingOrders => getOrdersByStatus(OrderStatus.processing);

  // Get shipped orders
  List<Order> get shippedOrders => getOrdersByStatus(OrderStatus.shipped);

  // Get delivered orders
  List<Order> get deliveredOrders => getOrdersByStatus(OrderStatus.delivered);

  /// INITIALIZE - Start listening to orders
  void initialize() {
    listenToOrders();
  }

  /// START LISTENING TO ORDERS
  void listenToOrders() {
    _ordersSubscription?.cancel;
    print('📦 Starting orders listener...');
    _isLoading = true;
    notifyListeners();

    _ordersSubscription = _db.readUserOrders().listen(
      (snapshot) {
        print('📦 Received ${snapshot.docs.length} orders from Firestore');
        _orders = snapshot.docs.map((doc) => Order.fromDocument(doc)).toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Orders error: $error');
        _error = 'Failed to load orders: ${error.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// UPDATE ORDER STATUS
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    required PaymentStatus paymentStatus,
    String? trackingNumber,
    String? cancellationReason,
  }) async {
    try {
      await _db.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        trackingNumber: trackingNumber,
        cancellationReason: cancellationReason,
        paymentStatus: paymentStatus,
      );

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// CANCEL ORDER
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _db.cancelOrder(orderId: orderId, reason: reason);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// GET SPECIFIC ORDER
  Future<Order?> getOrder(String orderId) async {
    try {
      return await _db.getOrder(orderId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// FIND ORDER IN LOCAL LIST
  Order? findOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// CLEAR ERROR
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}

/// Result class for order creation
class OrderCreationResult {
  final bool success;
  final String? orderId;
  final String? message;

  OrderCreationResult.success({required this.orderId})
      : success = true,
        message = null;

  OrderCreationResult.failure(this.message)
      : success = false,
        orderId = null;
}
