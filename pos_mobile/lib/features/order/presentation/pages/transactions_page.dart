import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pos_mobile/core/theme/app_colors.dart';
import 'package:pos_mobile/features/order/domain/models/order_model.dart';
import 'package:pos_mobile/features/order/presentation/providers/order_provider.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final List<String> _filters = ['All', 'Cash', 'CreditCard', 'PromptPay'];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final List<OrderModel> allOrders = ref.watch(orderHistoryProvider);

    final filteredOrders = allOrders.where((order) {
      final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || order.paymentMethod.toLowerCase() == _selectedFilter.toLowerCase();
      return matchesSearch && matchesFilter;
    }).toList();

    final totalPages = (filteredOrders.length / _itemsPerPage).ceil() == 0 ? 1 : (filteredOrders.length / _itemsPerPage).ceil();
    final paginatedOrders = filteredOrders.skip((_currentPage - 1) * _itemsPerPage).take(_itemsPerPage).toList();

    final totalRevenue = filteredOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final avgOrderValue = filteredOrders.isEmpty ? 0.0 : totalRevenue / filteredOrders.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Title
            Text('Sales Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Track revenue, monitor performance, and manage invoices.', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
            const SizedBox(height: 32),

            // 2. KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                if (isDesktop) {
                  return Row(
                    children: [
                      Expanded(child: _buildKPICard('Total Revenue', '฿${totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, colors)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICard('Total Orders', '${filteredOrders.length}', Icons.shopping_bag_outlined, colors)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICard('Avg. Order Value', '฿${avgOrderValue.toStringAsFixed(2)}', Icons.analytics_outlined, colors)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildKPICard('Total Revenue', '฿${totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, colors),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildKPICard('Total Orders', '${filteredOrders.length}', Icons.shopping_bag_outlined, colors)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildKPICard('Avg. Value', '฿${avgOrderValue.toStringAsFixed(2)}', Icons.analytics_outlined, colors)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // 🔥 3. Grid-3 Layout (Chart [2] + Payment [1] + Top Sellers [1])
            if (filteredOrders.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1000;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildMockRevenueChart(colors)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildPaymentBreakdown(filteredOrders, colors)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildTopSellers(filteredOrders, colors)),
                      ],
                    );
                  }
                  // สำหรับจอแท็บเล็ต/มือถือ
                  return Column(
                    children: [
                      _buildMockRevenueChart(colors),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildPaymentBreakdown(filteredOrders, colors)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTopSellers(filteredOrders, colors)),
                        ],
                      )
                    ],
                  );
                },
              ),
            if (filteredOrders.isNotEmpty) const SizedBox(height: 32),

            // 4. Search Bar & Filter Chips
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by Order ID...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) => setState(() {
                      _searchQuery = value;
                      _currentPage = 1; 
                    }),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        selectedColor: colors.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter ? colors.primary : colors.textSecondary,
                          fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                              _currentPage = 1;
                            });
                          }
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Transaction Table
            if (filteredOrders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 80, color: colors.divider),
                      const SizedBox(height: 16),
                      Text('No transactions match your criteria.', style: TextStyle(color: colors.textSecondary, fontSize: 18)),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 700) {
                          return _buildDataTable(paginatedOrders, colors);
                        }
                        return _buildMobileList(paginatedOrders, colors);
                      },
                    ),
                    
                    const Divider(height: 1),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Showing ${( _currentPage - 1) * _itemsPerPage + 1} to ${( _currentPage * _itemsPerPage).clamp(0, filteredOrders.length)} of ${filteredOrders.length} entries', 
                            style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                              ),
                              Text('Page $_currentPage of $totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Components Helpers ---

  Widget _buildKPICard(String title, String value, IconData icon, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: colors.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildMockRevenueChart(AppColors colors) {
    return Container(
      height: 280, // เพิ่มความสูงให้พอดีกับ 3 กล่อง
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Overview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final heights = [40.0, 60.0, 30.0, 80.0, 50.0, 90.0, 70.0];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24, // เล็กลงนิดนึงเพื่อให้พอดีกับ Grid 3
                height: heights[index],
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown(List<OrderModel> orders, AppColors colors) {
    final total = orders.length;
    final cash = orders.where((o) => o.paymentMethod.toLowerCase() == 'cash').length;
    final credit = orders.where((o) => o.paymentMethod.toLowerCase() == 'creditcard').length;
    final qr = orders.where((o) => o.paymentMethod.toLowerCase() == 'promptpay').length;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payments', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProgressRow('Cash', cash, total, colors.success, colors),
                _buildProgressRow('Credit', credit, total, colors.primary, colors),
                _buildProgressRow('PromptPay', qr, total, Colors.orangeAccent, colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Component ใหม่เอี่ยม: สินค้าขายดี (Top Sellers) จัดอันดับอัตโนมัติตามยอดที่ขายได้จริง
  Widget _buildTopSellers(List<OrderModel> orders, AppColors colors) {
    // 1. ลอจิกนับจำนวนสินค้าที่ขายได้ทั้งหมด
    final Map<String, int> itemCounts = {};
    for (final order in orders) {
      for (final item in order.items) {
        itemCounts[item.product.name] = (itemCounts[item.product.name] ?? 0) + item.quantity;
      }
    }

    // 2. เรียงลำดับจากมากไปน้อย และดึงมาแค่ 3 อันดับแรก
    final sortedItems = itemCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topSellers = sortedItems.take(3).toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 20),
              const SizedBox(width: 8),
              Text('Top Sellers', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: topSellers.isEmpty
                ? Center(child: Text('No data yet', style: TextStyle(color: colors.textSecondary)))
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topSellers.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = topSellers[index];
                      return Row(
                        children: [
                          // ป้ายอันดับ 1, 2, 3
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: index == 0 ? Colors.amber.shade100 : colors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${index + 1}', style: TextStyle(
                              color: index == 0 ? Colors.amber.shade900 : colors.textSecondary,
                              fontWeight: FontWeight.bold,
                            )),
                          ),
                          const SizedBox(width: 12),
                          // ชื่อสินค้า
                          Expanded(
                            child: Text(
                              item.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          // ยอดที่ขายได้
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                            child: Text('${item.value}x', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int count, int total, Color barColor, AppColors colors) {
    final percentage = total == 0 ? 0.0 : (count / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(4))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 6,
              // ใช้ FractionallySizedBox ในอนาคตได้ แต่แบบนี้เนียนกว่าสำหรับ Stack
              width: percentage * 150, // กะขนาดให้พอดี
              decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTable(List<OrderModel> orders, AppColors colors) {
    return DataTable(
      showCheckboxColumn: false,
      headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: colors.textSecondary),
      horizontalMargin: 24,
      columns: const [
        DataColumn(label: Text('Order ID')),
        DataColumn(label: Text('Date & Time')),
        DataColumn(label: Text('Payment')),
        DataColumn(label: Text('Total')),
      ],
      rows: orders.map((order) {
        return DataRow(
          onSelectChanged: (_) => _openOrderDrawer(order, colors),
          cells: [
            DataCell(Text('#${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt))),
            DataCell(_buildPaymentBadge(order.paymentMethod, colors)),
            DataCell(Text('฿${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold))),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMobileList(List<OrderModel> orders, AppColors colors) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          onTap: () => _openOrderDrawer(order, colors),
          title: Text('#${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('฿${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              _buildPaymentBadge(order.paymentMethod, colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentBadge(String method, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.divider)),
      child: Text(method, style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _openOrderDrawer(OrderModel order, AppColors colors) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 16,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
            child: Container(
              width: 400,
              height: double.infinity,
              color: colors.surface,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: colors.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildDetailRow('Order ID', '#${order.id.toUpperCase()}', colors),
                        _buildDetailRow('Date', DateFormat('MMM dd, yyyy HH:mm:ss').format(order.createdAt), colors),
                        _buildDetailRow('Payment Method', order.paymentMethod, colors),
                        const Divider(height: 32),
                        const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity}x ${item.product.name}'),
                              Text('฿${item.totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.divider))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('฿${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}