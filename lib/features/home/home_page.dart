import 'package:flutter/material.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import '../dashboard/dashboard_page.dart';
import '../kasir/kasir_page.dart';
import '../product/product_page.dart';
import '../stock/stock_page.dart';
import '../settings/settings_page.dart';
import '../../theme/clay_colors.dart';
import '../../widgets/clay_card.dart';

class HomePage extends StatelessWidget {
  final Profile profile;
  const HomePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final role = profile.role.toLowerCase();
    if (role == 'admin') {
      return const AdminHomePage();
    }
    return const KasirHomePage();
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const KasirPage(),
      const ProductPage(),
      const StockPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BANGJUN SPOT - ADMIN'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _ClayPillNav(
        currentIndex: _index,
        onChanged: (value) {
          setState(() => _index = value);
          if (value == 0) {
            context.read<TransactionProvider>().loadTransactions();
          }
        },
        items: const [
          _ClayNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          _ClayNavItem(icon: Icons.shopping_cart, label: 'Kasir'),
          _ClayNavItem(icon: Icons.restaurant_menu, label: 'Produk'),
          _ClayNavItem(icon: Icons.inventory, label: 'Stok'),
          _ClayNavItem(icon: Icons.settings, label: 'User'),
        ],
      ),
    );
  }
}

class KasirHomePage extends StatelessWidget {
  const KasirHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir BANGJUN SPOT'),
        actions: [
          Selector<CartProvider, int>(
            selector: (_, cart) => cart.totalItems,
            builder: (context, totalItems, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ClayColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            totalItems.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const KasirPage(),
    );
  }
}

class _ClayPillNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<_ClayNavItem> items;

  const _ClayPillNav({
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ClayCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: ClayElevation.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = index == currentIndex;
              return InkWell(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? ClayColors.primary.withAlpha(31) : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon,
                          color: active
                              ? ClayColors.primary
                              : ClayColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? ClayColors.primary
                              : ClayColors.textMuted,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ClayNavItem {
  final IconData icon;
  final String label;

  const _ClayNavItem({required this.icon, required this.label});
}
