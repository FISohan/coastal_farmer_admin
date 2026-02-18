import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome back 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s an overview of your store.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            Consumer2<ProductProvider, OrderProvider>(
              builder: (context, productProvider, orderProvider, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800
                        ? 4
                        : constraints.maxWidth > 500
                        ? 2
                        : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.6,
                      children: [
                        _StatCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Total Products',
                          value: '${productProvider.products.length}',
                          color: colorScheme.primary,
                          bgColor: colorScheme.primaryContainer,
                          onTap: () => context.go('/products'),
                        ),
                        _StatCard(
                          icon: Icons.public,
                          label: 'Public Products',
                          value:
                              '${productProvider.products.where((p) => p.isPublic).length}',
                          color: const Color(0xFF0277BD),
                          bgColor: const Color(0xFFB3E5FC),
                          onTap: () => context.go('/products'),
                        ),
                        _StatCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Orders',
                          value: '${orderProvider.totalOrders}',
                          color: const Color(0xFFE65100),
                          bgColor: const Color(0xFFFFE0B2),
                          onTap: () => context.go('/orders'),
                        ),
                        _StatCard(
                          icon: Icons.trending_up,
                          label: 'Revenue',
                          value:
                              '৳${orderProvider.totalRevenue.toStringAsFixed(0)}',
                          color: const Color(0xFF2E7D32),
                          bgColor: const Color(0xFFC8E6C9),
                          onTap: () => context.go('/orders'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Recent Orders
            Text(
              'Recent Orders',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.orders.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No orders yet',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final recentOrders = orderProvider.orders.take(5).toList();
                return Card(
                  child: Column(
                    children: recentOrders.map((order) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            order.customerName.isNotEmpty
                                ? order.customerName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          order.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${order.items.length} items',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: Text(
                          '৳${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        onTap: () => context.go('/orders'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
