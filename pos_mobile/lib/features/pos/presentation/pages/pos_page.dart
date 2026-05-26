import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_mobile/core/theme/app_colors.dart';
import 'package:pos_mobile/features/pos/domain/models/pos_models.dart';
import 'package:pos_mobile/features/pos/presentation/providers/cart_provider.dart';
import 'package:pos_mobile/features/pos/presentation/providers/product_provider.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final cartItems = ref.watch(cartProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: colors.background,
          // ใช้ Row แบ่งฝั่งเฉพาะบน Desktop
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ฝั่งซ้าย: รายการสินค้า (แสดงเต็มจอทั้ง Mobile และ Desktop)
              Expanded(
                flex: 7,
                child: _buildProductGrid(context, ref, colors, isDesktop),
              ),
              
              // ฝั่งขวา: แผงตะกร้าสินค้า (แสดงเฉพาะบน Desktop ตามเดิม)
              if (isDesktop) ...[
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  flex: 3,
                  child: _buildCartPanel(context, ref, colors, isModal: false),
                ),
              ]
            ],
          ),
          
          // 🔥 MOBILE UX: ปุ่มตะกร้าลอยตัว แสดงเฉพาะบนมือถือเมื่อมีสินค้าในตะกร้า
          floatingActionButton: !isDesktop && cartItems.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _showMobileCart(context, ref, colors),
                  backgroundColor: colors.primary,
                  icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                  label: Text(
                    'View Order (${cartItems.fold(0, (sum, item) => sum + item.quantity)})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        );
      },
    );
  }

  // ฟังก์ชันสไลด์ตะกร้าสินค้าขึ้นมาจากด้านล่าง (สำหรับ Mobile)
  void _showMobileCart(BuildContext context, WidgetRef ref, AppColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ทำให้ปรับความสูงตามเนื้อหาได้
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85, // เปิดขึ้นมาให้สูง 85% ของหน้าจอ
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // แถบจับด้านบนสุดของ Bottom Sheet (UX Indicator)
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)),
                ),
                
                // เรียกใช้ Cart Panel ตัวเดิม (Reusable Widget Pattern)
                Expanded(
                  child: _buildCartPanel(context, ref, colors, isModal: true),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Grid รายการสินค้า
  Widget _buildProductGrid(BuildContext context, WidgetRef ref, AppColors colors, bool isDesktop) {
    final productsAsync = ref.watch(productsProvider);

    return Container(
      color: colors.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: productsAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: colors.error, size: 64),
                    const SizedBox(height: 16),
                    Text('Failed to load menu.', style: TextStyle(color: colors.textSecondary, fontSize: 18)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(productsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return Center(child: Text('No products available.', style: TextStyle(color: colors.textSecondary)));
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : 2, 
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _ProductCard(product: products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // แผงตะกร้าสินค้าแบบแชร์ลอจิกร่วมกัน (Desktop Panel / Mobile Modal)
  Widget _buildCartPanel(BuildContext context, WidgetRef ref, AppColors colors, {required bool isModal}) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).totalAmount;

    return Container(
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Order',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                if (cartItems.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colors.error,
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                      if (isModal) Navigator.pop(context); // ปิดหน้าต่างโมดอลบนมือถืออัตโนมัติเมื่อเคลียร์ตะกร้า
                    },
                    tooltip: 'Clear Cart',
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: colors.divider),
                        const SizedBox(height: 16),
                        Text('No items in cart', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('฿${item.product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: colors.textSecondary,
                              onPressed: () {
                                ref.read(cartProvider.notifier).removeProduct(item.product);
                                // ปรับ UX: ถ้าชิ้นสุดท้ายถูกลบจนตะกร้าว่าง ให้ปิด Bottom Sheet บนมือถือทันที
                                if (isModal && cartItems.length == 1 && item.quantity == 1) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            SizedBox(
                              width: 32,
                              child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: colors.primary,
                              onPressed: () => ref.read(cartProvider.notifier).addProduct(item.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ฟุตเตอร์สรุปยอดและปุ่มชำระเงิน
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 18, color: colors.textSecondary)),
                    Text('฿${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.primary)),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () {
                          if (isModal) Navigator.pop(context); // ล้างโมดอลก่อนสลับไปหน้าจ่ายเงิน
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: const Text('Processing Payment... ✅'),
                                backgroundColor: colors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colors.success,
                    disabledBackgroundColor: colors.textSecondary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Center(
                    child: Text('Charge Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Product Card Widget (คงเดิมแต่เพิ่มประสิทธิภาพการเรนเดอร์)
class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: () => ref.read(cartProvider.notifier).addProduct(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Icon(Icons.fastfood_outlined, size: 48, color: colors.primary.withValues(alpha: 0.5)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('฿${product.price.toStringAsFixed(2)}', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}