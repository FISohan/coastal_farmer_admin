import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/invoice_service.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final CustomerOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _printerAvailable = false;
  bool _checkingPrinter = true;

  CustomerOrder get order => widget.order;

  @override
  void initState() {
    super.initState();
    _checkPrinterStatus();
  }

  Future<void> _checkPrinterStatus() async {
    try {
      final info = await Printing.info();
      if (mounted) {
        setState(() {
          _printerAvailable = info.canPrint;
          _checkingPrinter = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _printerAvailable = false;
          _checkingPrinter = false;
        });
      }
    }
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

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.delivered:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(order.status, colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Invoice',
            onPressed: () => InvoiceService.printInvoice(order),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Order'),
                    content: const Text(
                      'Are you sure you want to delete this order? This cannot be undone.',
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
                if (confirm == true && context.mounted) {
                  await context.read<OrderProvider>().deleteOrder(order.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Printer status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _checkingPrinter
                      ? colorScheme.surfaceContainerHighest
                      : _printerAvailable
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _checkingPrinter
                        ? colorScheme.outlineVariant
                        : _printerAvailable
                        ? const Color(0xFF2E7D32).withOpacity(0.3)
                        : colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_checkingPrinter)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _printerAvailable
                              ? const Color(0xFF2E7D32)
                              : colorScheme.error,
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      _checkingPrinter
                          ? 'Checking...'
                          : _printerAvailable
                          ? 'Printer ready'
                          : 'No printer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _checkingPrinter
                            ? colorScheme.onSurfaceVariant
                            : _printerAvailable
                            ? const Color(0xFF2E7D32)
                            : colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Print button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => InvoiceService.printInvoice(order),
                    icon: const Icon(Icons.print),
                    label: const Text(
                      'Print Invoice',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status & Date ──
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _statusIcon(order.status),
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(order.orderDate),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Status change
                        PopupMenuButton<OrderStatus>(
                          tooltip: 'Change status',
                          onSelected: (newStatus) {
                            context.read<OrderProvider>().updateOrderStatus(
                              order.id,
                              newStatus,
                            );
                            // Pop and let the list refresh
                            Navigator.of(context).pop();
                          },
                          itemBuilder: (_) => OrderStatus.values
                              .map(
                                (s) => PopupMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _statusIcon(s),
                                        size: 18,
                                        color: _statusColor(s, colorScheme),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        s.name[0].toUpperCase() +
                                            s.name.substring(1),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          child: Chip(
                            label: const Text('Change'),
                            avatar: const Icon(Icons.swap_horiz, size: 16),
                            visualDensity: VisualDensity.compact,
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Customer Info ──
                _DetailSection(
                  icon: Icons.person_outline,
                  title: 'Customer',
                  children: [
                    _DetailRow(label: 'Name', value: order.customerName),
                    _DetailRow(label: 'Phone', value: order.customerPhone),
                    _DetailRow(label: 'Address', value: order.customerAddress),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Items ──
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Items (${order.items.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          item.productName.isNotEmpty
                              ? item.productName.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '৳${item.unitPrice.toStringAsFixed(0)} × ${item.quantity.toStringAsFixed(0)}',
                      ),
                      trailing: Text(
                        '৳${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Total ──
                Card(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '৳${order.totalAmount.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Notes ──
                if (order.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailSection(
                    icon: Icons.notes_outlined,
                    title: 'Notes',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(order.notes),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helper Widgets ──

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
