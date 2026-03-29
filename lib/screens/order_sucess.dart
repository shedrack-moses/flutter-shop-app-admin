import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart' show OrderStatus, Order, PaymentStatus;
import '../providers/order_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize order provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          // indicator: BoxDecoration(

          //     color: Colors.grey,
          //     shape: BoxShape.rectangle,
          //     borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.only(left: 0),
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.error!,
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProvider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(orderProvider.orders),
              _buildOrdersList(orderProvider.processingOrders),
              _buildOrdersList(orderProvider.shippedOrders),
              _buildOrdersList(orderProvider.deliveredOrders),
              _buildOrdersList(
                orderProvider.pendingOrders,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(order.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status chips
              Row(
                children: [
                  _buildStatusChip(order.orderStatus),
                  const SizedBox(width: 8),
                  _buildPaymentStatusChip(order.paymentStatus),
                ],
              ),

              const SizedBox(height: 12),

              // Items preview
              Text(
                '${order.totalItems} ${order.totalItems == 1 ? 'item' : 'items'}',
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 12),

              // Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              if (order.trackingNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Tracking: ${order.trackingNumber}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
      case OrderStatus.refunded:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaymentStatusChip(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.pending:
        color = Colors.orange;
        break;
      case PaymentStatus.completed:
        color = Colors.green;
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        break;
      case PaymentStatus.refunded:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        'Payment: ${status.displayName}',
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderNumber),
        actions: [
          if (order.canBeCancelled)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () =>
                  _showCancelDialog(context, orderId: order.id ?? ''),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          _buildStatusCard(context),

          const SizedBox(height: 16),

          // Order Items
          _buildSectionTitle(context, 'Order Items'),
          ..._buildOrderItems(),

          const SizedBox(height: 16),

          // Shipping Address
          _buildSectionTitle(context, 'Shipping Address'),
          _buildShippingAddress(),

          const SizedBox(height: 16),

          // Payment Details
          _buildSectionTitle(context, 'Payment Details'),
          // _buildPaymentDetails(),

          if (order.notes != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Order Notes'),
            // _buildNotesCard(),
          ],

          if (order.trackingNumber != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Tracking Information'),
            // _buildTrackingCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Chip(
                label: Text(
                  order.orderStatus.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(order.orderStatus),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Status'),
              Chip(
                label: Text(
                  order.paymentStatus.displayName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: _getPaymentStatusColor(
                  order.paymentStatus,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          //   _buildInfoRow('Order Date', DateFormat('MMM d, yyyy • hh:mm a').format(order.createdAt)),
          //   if (order.deliveredAt != null)
          //     _buildInfoRow('Delivered On', DateFormat('MMM d, yyyy • hh:mm a').format(order.deliveredAt!)),
          //   if (order.cancellationReason != null)
          //     _buildInfoRow('Cancellation Reason', order.cancellationReason!, isError: true),
          // ],
        ]),
      ),
    );
  }

  List<Widget> _buildOrderItems() {
    return order.items.map((item) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: item.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
          title: Text(item.name),
          subtitle: Text(
              'Quantity: ${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
          trailing: Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildShippingAddress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name : ${order.shippingAddress.fullName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Phone Number:${order.shippingAddress.phone}'),
            const SizedBox(height: 8),
            Text('Address:${order.shippingAddress.fullAddress}'),
          ],
        ),
      ),
    );
  }

  Color? _getStatusColor(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  Color? _getPaymentStatusColor(PaymentStatus paymentStatus) {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.grey;
    }
  }

  // Widget _buildPaymentDetails() {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           _buildPriceRow('Subtotal', order.subtotal),
  //           const SizedBox(height: 8),
  //           _buildPriceRow('Shipping Fee', order.shippingFee),
  //           const SizedBox(height: 8),
  //           _buildPriceRow('Tax', order.tax),
  //           if (order.discount > 0) ...[
  //             const SizedBox(height: 8),
  //             _buildPriceRow('Discount', -order.discount, isDiscount: true),
  //           ],
  //           const Divider(height: 24),
  //           _buildPriceRow('Total', order.total, isTotal: true),
  //           const SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text('Payment Method'),
  //               Text(
  //                 order.paymentMethod?.toUpperCase().replaceAll('_', ' ') ?? 'N/A',
  //                 style: const TextStyle(fontWeight: FontWeight.w500),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNotesCard() {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Text(order.notes!),
  //     ),
  //   );
  // }

  // Widget _buildTrackingCard() {
  //   return Card(
  //     child: ListTile(
  //       leading: const Icon(Icons.local_shipping, color: Colors.blue),
  //       title: const Text('Tracking Number'),
  //       subtitle: Text(order.trackingNumber!),
  //       trailing: IconButton(
  //         icon: const Icon(Icons.copy),
  //         onPressed: () {
  //           // Copy to clipboard
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoRow(String label, String value, {bool isError = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label, style: TextStyle(color: Colors.grey.shade700)),
  //         Expanded(
  //           child: Text(
  //             value,
  //             textAlign: TextAlign.right,
  //             style: TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: isError ? Colors.red : null,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPriceRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: isTotal ? 18 : 14,
  //           fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
  //         ),
  //       ),
  //       Text(
  //         '\$${amount.abs().toStringAsFixed(2)}',
  //         style: TextStyle(
  //           fontSize: isTotal ? 20 : 14,
  //           fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
  //           color:
}

void _showCancelDialog(BuildContext context,
    {String reason = 'Customer Requested', required String orderId}) {
  showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: const Text('Cancel Order'),
      content: const Text('Are you sure you want to cancel this order?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () {
            OrderProvider orderProvider =
                Provider.of<OrderProvider>(context, listen: false);
            orderProvider.cancelOrder(orderId: orderId, reason: reason);
            // Call cancel order method
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const OrdersPage()),
              (route) => route.isFirst,
            );
          },
          child: const Text('Yes, Cancel'),
        ),
      ],
    ),
  );
}
