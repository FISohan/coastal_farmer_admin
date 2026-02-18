import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import 'order_form_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Reset filter date when switching tabs
          if (_tabController.index == 0) _filterDate = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<CustomerOrder> _todayOrders(List<CustomerOrder> orders) {
    final now = DateTime.now();
    return orders.where((o) => _isSameDay(o.orderDate, now)).toList();
  }

  List<CustomerOrder> _filteredOrders(List<CustomerOrder> orders) {
    if (_filterDate == null) return orders;
    return orders.where((o) => _isSameDay(o.orderDate, _filterDate!)).toList();
  }

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

  Future<void> _confirmDelete(
    BuildContext context,
    OrderProvider provider,
    CustomerOrder order,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Delete order for "${order.customerName}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final success = await provider.deleteOrder(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Order deleted' : 'Failed to delete order'),
          ),
        );
      }
    }
  }

  Future<void> _pickFilterDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
    }
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All Orders'),
          ],
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // ── Today Tab ──
              _buildOrderList(
                context: context,
                provider: provider,
                orders: _todayOrders(provider.orders),
                emptyIcon: Icons.today_outlined,
                emptyTitle: 'No orders today',
                emptySubtitle: 'Orders placed today will appear here.',
              ),

              // ── All Orders Tab ──
              Column(
                children: [
                  // Date filter bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter by date:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _pickFilterDate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _filterDate != null
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _filterDate != null
                                    ? colorScheme.primary.withOpacity(0.5)
                                    : colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: _filterDate != null
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _filterDate != null
                                      ? DateFormat(
                                          'dd MMM yyyy',
                                        ).format(_filterDate!)
                                      : 'All dates',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _filterDate != null
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_filterDate != null) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _filterDate = null),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${_filteredOrders(provider.orders).length} order${_filteredOrders(provider.orders).length != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Order list
                  Expanded(
                    child: _buildOrderList(
                      context: context,
                      provider: provider,
                      orders: _filteredOrders(provider.orders),
                      emptyIcon: Icons.search_off_outlined,
                      emptyTitle: _filterDate != null
                          ? 'No orders on ${DateFormat('dd MMM yyyy').format(_filterDate!)}'
                          : 'No orders yet',
                      emptySubtitle: _filterDate != null
                          ? 'Try selecting a different date.'
                          : 'Create your first order to get started.',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openOrderForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Order'),
      ),
    );
  }

  Widget _buildOrderList({
    required BuildContext context,
    required OrderProvider provider,
    required List<CustomerOrder> orders,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                emptyIcon,
                size: 72,
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
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
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                statusColor: _statusColor(order.status, colorScheme),
                onTap: () => _openOrderDetail(context, order),
                onDelete: () => _confirmDelete(context, provider, order),
              );
            },
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
              // Top Row: Customer name + type + status + delete
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: order.orderType == OrderType.online
                          ? const Color(0xFF0277BD).withOpacity(0.1)
                          : colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      order.orderType == OrderType.online
                          ? Icons.language
                          : Icons.storefront_outlined,
                      size: 20,
                      color: order.orderType == OrderType.online
                          ? const Color(0xFF0277BD)
                          : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName.isNotEmpty
                              ? order.customerName
                              : 'Walk-in Customer',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: order.orderType == OrderType.online
                                    ? const Color(0xFF0277BD).withOpacity(0.1)
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.orderType == OrderType.online
                                    ? 'Online'
                                    : 'Offline',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: order.orderType == OrderType.online
                                      ? const Color(0xFF0277BD)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (order.customerPhone.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  order.customerPhone,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
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
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete order',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
