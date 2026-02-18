import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  final List<_OrderItemEntry> _items = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    for (final item in _items) {
      item.priceController.dispose();
      item.quantityController.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _items.fold(
    0.0,
    (sum, item) =>
        sum +
        (double.tryParse(item.priceController.text) ?? 0) *
            (double.tryParse(item.quantityController.text) ?? 0),
  );

  void _showProductPicker() {
    final products = context.read<ProductProvider>().products;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = products
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Select Product',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() => searchQuery = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final product = filtered[index];
                                return _ProductTile(
                                  product: product,
                                  onTap: () {
                                    _addProduct(product);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _addProduct(Product product) {
    setState(() {
      _items.add(
        _OrderItemEntry(
          product: product,
          priceController: TextEditingController(
            text: product.price.toStringAsFixed(0),
          ),
          quantityController: TextEditingController(text: '1'),
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].priceController.dispose();
      _items[index].quantityController.dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final order = CustomerOrder()
      ..customerName = _nameController.text.trim()
      ..customerPhone = _phoneController.text.trim()
      ..customerAddress = _addressController.text.trim()
      ..notes = _notesController.text.trim()
      ..orderDate = DateTime.now()
      ..status = OrderStatus.pending
      ..items = _items.map((entry) {
        final item = OrderItem()
          ..productId = entry.product.id ?? ''
          ..productName = entry.product.name
          ..unitPrice = double.tryParse(entry.priceController.text) ?? 0
          ..quantity = double.tryParse(entry.quantityController.text) ?? 0;
        return item;
      }).toList()
      ..totalAmount = _subtotal;

    final provider = context.read<OrderProvider>();
    final success = await provider.addOrder(order);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to create order')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveOrder,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isSaving ? 'Saving...' : 'Create Order',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final content = Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                vertical: 20,
              ),
              children: [
                // ── Customer Info Section ──
                _SectionHeader(
                  icon: Icons.person_outline,
                  title: 'Customer Information',
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isWide
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Customer Name *',
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number *',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Delivery Address *',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                                maxLines: 2,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Customer Name *',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number *',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Delivery Address *',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                                maxLines: 2,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Products Section ──
                _SectionHeader(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Order Items',
                  color: colorScheme.primary,
                  trailing: FilledButton.tonalIcon(
                    onPressed: _showProductPicker,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Product'),
                  ),
                ),
                const SizedBox(height: 12),

                if (_items.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 48,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No products added yet',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add Product" to select from your product list',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(_items.length, (index) {
                    final entry = _items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.product.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: colorScheme.error,
                                  ),
                                  onPressed: () => _removeItem(index),
                                  tooltip: 'Remove',
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: entry.priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Price (৳)',
                                      isDense: true,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (_) => setState(() {}),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(v) == null) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: entry.quantityController,
                                    decoration: InputDecoration(
                                      labelText: 'Qty (${entry.product.unit})',
                                      isDense: true,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (_) => setState(() {}),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(v) == null) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '৳${((double.tryParse(entry.priceController.text) ?? 0) * (double.tryParse(entry.quantityController.text) ?? 0)).toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.primary,
                                        ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // ── Notes Section ──
                _SectionHeader(
                  icon: Icons.notes_outlined,
                  title: 'Notes (Optional)',
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add any special instructions...',
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Order Summary ──
                Card(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_items.length} item${_items.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '৳${_subtotal.toStringAsFixed(0)}',
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

                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
          return content;
        },
      ),
    );
  }
}

// ── Helper Widgets ──

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          product.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${product.category} · ${product.unit}'),
      trailing: Text(
        '৳${product.price.toStringAsFixed(0)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _OrderItemEntry {
  final Product product;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  _OrderItemEntry({
    required this.product,
    required this.priceController,
    required this.quantityController,
  });
}
