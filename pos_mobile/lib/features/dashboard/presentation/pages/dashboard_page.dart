import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_mobile/core/theme/app_colors.dart';
import 'package:pos_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_mobile/features/pos/presentation/pages/pos_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final currentIndex = ref.watch(dashboardNavProvider);

    // เมนูทั้งหมดในระบบ POS ของเรา
    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale_rounded),
        label: Text('Point of Sale'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long_rounded),
        label: Text('Transactions'), // รองรับระบบ Billing/Quotation ในอนาคต
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2_rounded),
        label: Text('Inventory'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: Text('Settings'),
      ),
    ];

    // เนื้อหาที่จะแสดงตาม Index
    final views = [
      const PosPage(),
      const _DummyBody(title: 'Financial Transactions', icon: Icons.receipt_long),
      const _DummyBody(title: 'Inventory Management', icon: Icons.inventory_2),
      const _DummyBody(title: 'System Settings', icon: Icons.settings),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      // ใช้ LayoutBuilder เพื่อตรวจสอบขนาดหน้าจอแบบ Real-time
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ถ้าความกว้างน้อยกว่า 800 ถือว่าเป็น Mobile/Small Tablet
          final isMobile = constraints.maxWidth < 800;

          if (isMobile) {
            return Column(
              children: [
                _buildMobileAppBar(context, ref, colors, theme),
                Expanded(child: views[currentIndex]),
              ],
            );
          }

          // สำหรับ Web/Windows/Large Tablet
          return Row(
            children: [
              // เมนูด้านข้าง (Navigation Rail)
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  ref.read(dashboardNavProvider.notifier).setIndex(index);
                },
                extended: constraints.maxWidth > 1200, // ขยายเมนูถ้าจอกว้างมาก
                backgroundColor: colors.surface,
                indicatorColor: colors.primary.withValues(alpha: 0.1),
                selectedIconTheme: IconThemeData(color: colors.primary),
                selectedLabelTextStyle: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: TextStyle(color: colors.textSecondary),
                unselectedIconTheme: IconThemeData(color: colors.textSecondary),
                leading: _buildRailHeader(colors, constraints.maxWidth > 1200),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: 'Sign Out',
                        color: colors.error,
                        onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
                      ),
                    ),
                  ),
                ),
                destinations: destinations,
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // พื้นที่แสดงเนื้อหาหลัก
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: views[currentIndex],
                ),
              ),
            ],
          );
        },
      ),
      // แสดง Bottom Menu เฉพาะบน Mobile
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                ref.read(dashboardNavProvider.notifier).setIndex(index);
              },
              backgroundColor: colors.surface,
              indicatorColor: colors.primary.withValues(alpha: 0.1),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'POS'),
                NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Txn'),
                NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Stock'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            )
          : null,
    );
  }

  // Header โลโก้สำหรับแถบเมนูด้านข้าง
  Widget _buildRailHeader(AppColors colors, bool isExtended) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: isExtended
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.point_of_sale, color: colors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Enterprise POS',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          : Icon(Icons.point_of_sale, color: colors.primary, size: 32),
    );
  }

  // AppBar สำหรับ Mobile
  Widget _buildMobileAppBar(BuildContext context, WidgetRef ref, AppColors colors, ThemeData theme) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: colors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.point_of_sale, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Enterprise POS',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: colors.error,
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget จำลองสำหรับใช้ทดสอบการเปลี่ยนหน้า
class _DummyBody extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DummyBody({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Container(
      // ต้องระบุ Key เพื่อให้ AnimatedSwitcher ทำงานได้ถูกต้องเมื่อเปลี่ยนหน้า
      key: ValueKey(title), 
      width: double.infinity,
      color: colors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: colors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Module is under construction.'),
        ],
      ),
    );
  }
}