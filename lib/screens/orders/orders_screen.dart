import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import 'order_form_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(OrderStatus status, ColorScheme cs) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFE65100);
      case OrderStatus.confirmed:
        return const Color(0xFF0277BD);
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
        return cs.error;
    }
  }

  void _openOrderForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrderFormScreen()));
  }

  void _openOrderDetail(BuildContext context, CustomerOrder order) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return Row(
              children: [
                const Text('Orders'),
                if (provider.orders.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.orders.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 72,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first order to get started.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _openOrderForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Order'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadOrders,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? constraints.maxWidth * 0.08 : 12,
                    vertical: 12,
                  ),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return _OrderCard(
                      order: order,
                      statusColor: _statusColor(order.status, colorScheme),
                      onTap: () => _openOrderDetail(context, order),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Order'),
                            content: const Text(
                              'Are you sure you want to delete this order?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          provider.deleteOrder(order.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return FloatingActionButton.extended(
              onPressed: () => _openOrderForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Order'),
            );
          }
          return FloatingActionButton(
            onPressed: () => _openOrderForm(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CustomerOrder order;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Customer name + status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.customerPhone,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.name[0].toUpperCase() +
                          order.status.name.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              // Bottom Row: Items count, date, total
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(order.orderDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '৳${order.totalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
