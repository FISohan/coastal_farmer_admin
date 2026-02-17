import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'product_form.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditProductDialogWrapper(product: product),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await Provider.of<ProductProvider>(
                context,
                listen: false,
              ).deleteProduct(product.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Product deleted' : 'Failed to delete product',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Image with badges ───
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
              ),
              // Visibility badge
              Positioned(
                top: 8,
                left: 8,
                child: _Badge(
                  label: product.isPublic ? 'Public' : 'Private',
                  color: product.isPublic
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[700]!,
                  icon: product.isPublic
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
              // Discount badge
              if (product.discount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _Badge(
                    label:
                        '-${product.discount.toStringAsFixed(product.discount.truncateToDouble() == product.discount ? 0 : 1)}%',
                    color: Colors.red[700]!,
                    icon: Icons.local_offer,
                  ),
                ),
              // Action buttons
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delete button
                    Material(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showDeleteConfirmation(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Delete',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Edit button
                    Material(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showEditDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Content Section ───
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'No description',
                    style: textTheme.bodySmall?.copyWith(
                      color: product.description.isNotEmpty
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontStyle: product.description.isEmpty
                          ? FontStyle.italic
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),
                  // ─── Info Grid ───
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Price row
                        _InfoRow(
                          icon: Icons.sell_outlined,
                          label: 'Price',
                          valueWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '৳${product.price}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                              if (product.originalPrice > 0 &&
                                  product.originalPrice != product.price) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '৳${product.originalPrice}',
                                  style: textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          colorScheme: colorScheme,
                        ),
                        _infoDivider(colorScheme),
                        // Discount row
                        _InfoRow(
                          icon: Icons.discount_outlined,
                          label: 'Discount',
                          value: product.discount > 0
                              ? '${product.discount}%'
                              : 'None',
                          colorScheme: colorScheme,
                        ),
                        _infoDivider(colorScheme),
                        // Stock row
                        _InfoRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Stock',
                          value: '${product.stock}',
                          colorScheme: colorScheme,
                        ),
                        _infoDivider(colorScheme),
                        // Unit row
                        _InfoRow(
                          icon: Icons.straighten_outlined,
                          label: 'Unit',
                          value: product.unit,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}

// ─── Reusable Badge Widget ───
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Info Row ───
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final ColorScheme colorScheme;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Edit Dialog Wrapper ───
class _EditProductDialogWrapper extends StatefulWidget {
  final Product product;

  const _EditProductDialogWrapper({required this.product});

  @override
  State<_EditProductDialogWrapper> createState() =>
      _EditProductDialogWrapperState();
}

class _EditProductDialogWrapperState extends State<_EditProductDialogWrapper> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.95;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Product',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ProductForm(
                product: widget.product,
                isLoading: _isLoading,
                onSubmit: (updatedProduct, imageFile) async {
                  setState(() => _isLoading = true);

                  final productToUpdate = Product(
                    id: widget.product.id,
                    name: updatedProduct.name,
                    description: updatedProduct.description,
                    price: updatedProduct.price,
                    category: updatedProduct.category,
                    stock: updatedProduct.stock,
                    unit: updatedProduct.unit,
                    image: widget.product.image,
                    discount: updatedProduct.discount,
                    originalPrice: updatedProduct.originalPrice,
                    isPublic: updatedProduct.isPublic,
                  );

                  final success =
                      await Provider.of<ProductProvider>(
                        context,
                        listen: false,
                      ).updateProduct(
                        widget.product.id!,
                        productToUpdate,
                        imageFile,
                      );

                  if (mounted) {
                    setState(() => _isLoading = false);

                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product updated successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update product'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
