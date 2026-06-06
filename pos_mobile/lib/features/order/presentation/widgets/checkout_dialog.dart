import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// --- นำเข้า Core & Shared ---
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

// --- นำเข้า POS Modules ---
import '../../../../features/pos/presentation/providers/cart_provider.dart';

// --- นำเข้า Order Modules ---
import '../../domain/models/order_model.dart';
import '../providers/checkout_provider.dart';
import '../providers/order_provider.dart';

class CheckoutDialog extends ConsumerWidget {
  const CheckoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    
    // ดึงข้อมูลตะกร้าสินค้าปัจจุบัน
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartProvider.notifier).totalAmount;
    
    // ดึงวิธีชำระเงินที่ถูกเลือก
    final selectedPayment = ref.watch(paymentMethodNotifierProvider);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 24,
      child: Container(
        width: 480, // ล็อกความกว้างไว้ให้หน้าต่างดูพรีเมียม ไม่ยืดเต็มจอ
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header ของ Dialog
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complete Order',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colors.textSecondary,
                  tooltip: 'Cancel',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 2. กล่องแสดงยอดรวมสุทธิ (Total Amount)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.divider),
              ),
              child: Column(
                children: [
                  Text('Total Amount', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '฿${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(color: colors.primary, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. ตัวเลือกช่องทางการชำระเงิน
            Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _PaymentMethodCard(
                  title: 'Cash',
                  icon: Icons.payments_outlined,
                  isSelected: selectedPayment == PaymentMethod.cash,
                  onTap: () => ref.read(paymentMethodNotifierProvider.notifier).selectMethod(PaymentMethod.cash),
                )),
                const SizedBox(width: 12),
                Expanded(child: _PaymentMethodCard(
                  title: 'Credit',
                  icon: Icons.credit_card_outlined,
                  isSelected: selectedPayment == PaymentMethod.creditCard,
                  onTap: () => ref.read(paymentMethodNotifierProvider.notifier).selectMethod(PaymentMethod.creditCard),
                )),
                const SizedBox(width: 12),
                Expanded(child: _PaymentMethodCard(
                  title: 'PromptPay',
                  icon: Icons.qr_code_2,
                  isSelected: selectedPayment == PaymentMethod.promptPay,
                  onTap: () => ref.read(paymentMethodNotifierProvider.notifier).selectMethod(PaymentMethod.promptPay),
                )),
              ],
            ),
            const SizedBox(height: 40),

            // 4. ปุ่มยืนยันชำระเงิน (เรียกใช้ AppButton จาก Shared Widgets)
            AppButton(
              text: 'Confirm Payment',
              icon: Icons.check_circle_outline,
              onPressed: () {
                // เซฟ ScaffoldMessenger ไว้ก่อนเพื่อป้องกัน Error ตอน Pop Context
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // A: สร้างออเดอร์ใหม่และบันทึกลงใน History Provider
                final newOrder = OrderModel(
                  id: const Uuid().v4(), // สร้างรหัสบิลสุ่มแบบสากล
                  items: cartItems,
                  totalAmount: totalAmount,
                  paymentMethod: selectedPayment.name,
                  createdAt: DateTime.now(),
                );
                ref.read(orderHistoryProvider.notifier).addOrder(newOrder);

                // B: ล้างตะกร้าสินค้า
                ref.read(cartProvider.notifier).clearCart();
                
                // C: ปิดหน้าต่าง Checkout
                Navigator.of(context).pop();
                
                // D: แสดงข้อความแจ้งเตือนความสำเร็จ
                scaffoldMessenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Payment Successful (฿${totalAmount.toStringAsFixed(2)})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      backgroundColor: colors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(24),
                      duration: const Duration(seconds: 4),
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

// Widget ปุ่มเลือกวิธีชำระเงินที่มีแอนิเมชันตอนกดเปลี่ยนสี
class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.1) : colors.surface,
          border: Border.all(
            color: isSelected ? colors.primary : colors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? colors.primary : colors.textSecondary, 
              size: 32
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? colors.primary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}