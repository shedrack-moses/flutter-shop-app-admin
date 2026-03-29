import 'package:cloud_firestore/cloud_firestore.dart';

// Single item in an order
class OrderItem {
  final String productId;
  final String name;
  final double price; // Price at time of purchase
  final int quantity;
  final String imageUrl;
  final double subtotal; // price * quantity

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  }) : subtotal = price * quantity;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'subtotal': subtotal,
    };
  }

  // Create from Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

// Order status enum
enum OrderStatus {
  pending, // Just created, payment not confirmed
  processing, // Payment confirmed, preparing order
  shipped, // Order dispatched
  delivered, // Order received by customer
  cancelled, // Order cancelled
  refunded; // Order refunded

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  // Convert enum to string for Firestore
  String toFirestore() => name;

  // Convert string from Firestore to enum
  static OrderStatus fromFirestore(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
}

// Payment status enum
enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String toFirestore() => name;

  static PaymentStatus fromFirestore(String status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PaymentStatus.pending,
    );
  }
}

// Shipping address
class ShippingAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required String email,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
      email: map['email'] ?? '',
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      city,
      state,
      zipCode,
      country,
    ];
    return parts.join(', ');
  }
}

// Main Order Model
class Order {
  final String? id; // Document ID from Firestore
  final String userId; // Who placed the order
  final String
      orderNumber; // Human-readable order number (e.g., "ORD-2024-00123")
  final List<OrderItem> items; // Products in the order
  final ShippingAddress shippingAddress;

  // Pricing
  final double subtotal; // Sum of all items
  final double shippingFee; // Delivery cost
  final double tax; // Sales tax
  final double discount; // Coupon discount
  final double total; // Final amount

  // Status
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String? paymentMethod; // 'card', 'cash_on_delivery', etc.

  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  // Additional info
  final String? notes; // Special instructions
  final String? trackingNumber; // Shipping tracking
  final String? cancellationReason;

  Order({
    this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.orderStatus = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.notes,
    this.trackingNumber,
    this.cancellationReason,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'shippingAddress': shippingAddress.toMap(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'orderStatus': orderStatus.toFirestore(),
      'paymentStatus': paymentStatus.toFirestore(),
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'notes': notes,
      'trackingNumber': trackingNumber,
      'cancellationReason': cancellationReason,
    };
  }

  // Create from Firestore document
  factory Order.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      shippingAddress: ShippingAddress.fromMap(
        data['shippingAddress'] as Map<String, dynamic>,
      ),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingFee: (data['shippingFee'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      orderStatus: OrderStatus.fromFirestore(data['orderStatus'] ?? 'pending'),
      paymentStatus:
          PaymentStatus.fromFirestore(data['paymentStatus'] ?? 'pending'),
      paymentMethod: data['paymentMethod'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      trackingNumber: data['trackingNumber'],
      cancellationReason: data['cancellationReason'],
    );
  }

  // Helper: Get total items count
  int get totalItems {
    return items.fold(0, (sum1, item) => sum1 + item.quantity);
  }

  // Helper: Check if order can be cancelled
  bool get canBeCancelled {
    return orderStatus == OrderStatus.pending ||
        orderStatus == OrderStatus.processing;
  }

  // Helper: Check if order is completed
  bool get isCompleted {
    return orderStatus == OrderStatus.delivered;
  }

  // Copy with method for updates
  Order copyWith({
    String? id,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    String? trackingNumber,
    String? cancellationReason,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId,
      orderNumber: orderNumber,
      items: items,
      shippingAddress: shippingAddress,
      subtotal: subtotal,
      shippingFee: shippingFee,
      tax: tax,
      discount: discount,
      total: total,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
