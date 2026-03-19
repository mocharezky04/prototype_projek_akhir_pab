import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../kasir/kasir_page.dart';
import '../product/product_page.dart';
import '../stock/stock_page.dart';
import '../settings/settings_page.dart';
import '../../theme/clay_colors.dart';
import '../../widgets/clay_card.dart';

const double _kSidebarBreakpoint = 720;

class HomePage extends StatelessWidget {
  final Profile profile;
  const HomePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final role = profile.role.toLowerCase();
    if (role == 'admin') return const AdminHomePage();
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

  static const _pages = [
    DashboardPage(),
    KasirPage(),
    ProductPage(),
    StockPage(),
    SettingsPage(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.shopping_cart_rounded, label: 'Kasir'),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Produk'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Stok'),
    _NavItem(icon: Icons.manage_accounts_rounded, label: 'User'),
  ];

  void _onTabChanged(int value) {
    setState(() => _index = value);
    if (value == 0) {
      context.read<TransactionProvider>().loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useSidebar = width >= _kSidebarBreakpoint;

    if (useSidebar) {
      return _AdminSidebarLayout(
        index: _index,
        pages: _pages,
        navItems: _navItems,
        onChanged: _onTabChanged,
      );
    }

    return _AdminBottomNavLayout(
      index: _index,
      pages: _pages,
      navItems: _navItems,
      onChanged: _onTabChanged,
    );
  }
}

class _AdminBottomNavLayout extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  final List<_NavItem> navItems;
  final ValueChanged<int> onChanged;

  const _AdminBottomNavLayout({
    required this.index,
    required this.pages,
    required this.navItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, 'BANGJUN SPOT'),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: _ClayPillBottomNav(
        currentIndex: index,
        onChanged: onChanged,
        items: navItems,
      ),
    );
  }
}

class _AdminSidebarLayout extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  final List<_NavItem> navItems;
  final ValueChanged<int> onChanged;

  const _AdminSidebarLayout({
    required this.index,
    required this.pages,
    required this.navItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final extended = width >= 1100;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: extended ? 200 : 72,
            color: ClayColors.canvas,
            child: Column(
              children: [
                const SizedBox(height: 24),
                extended
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _logoIcon(),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'BangJun\nSpot',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ClayColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(child: _logoIcon()),
                const SizedBox(height: 20),
                Divider(
                  indent: 12,
                  endIndent: 12,
                  color: Colors.black.withAlpha(15),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: navItems.length,
                    itemBuilder: (context, i) {
                      final item = navItems[i];
                      final active = i == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => onChanged(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: EdgeInsets.symmetric(
                                horizontal: extended ? 12 : 0,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? ClayColors.primary.withAlpha(28)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: extended
                                  ? Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Icon(
                                          item.icon,
                                          size: 20,
                                          color: active
                                              ? ClayColors.primary
                                              : ClayColors.textMuted,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: active
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: active
                                                ? ClayColors.primary
                                                : ClayColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Tooltip(
                                        message: item.label,
                                        child: Icon(
                                          item.icon,
                                          size: 22,
                                          color: active
                                              ? ClayColors.primary
                                              : ClayColors.textMuted,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.read<AuthProvider>().logout(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: extended ? 12 : 0,
                          vertical: 11,
                        ),
                        child: extended
                            ? Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 20,
                                    color: Colors.red.shade400,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Tooltip(
                                  message: 'Logout',
                                  child: Icon(
                                    Icons.logout_rounded,
                                    size: 22,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.black.withAlpha(15),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: ClayColors.canvas,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        navItems[index].label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (index == 1)
                        Selector<CartProvider, int>(
                          selector: (_, cart) => cart.totalItems,
                          builder: (context, total, _) => total > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ClayColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$total item di keranjang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ClayColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withAlpha(15),
                ),
                Expanded(
                  child: IndexedStack(index: index, children: pages),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoIcon() => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ClayColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.storefront_rounded,
          color: Colors.white,
          size: 18,
        ),
      );
}

class KasirHomePage extends StatelessWidget {
  const KasirHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= _kSidebarBreakpoint;

    return Scaffold(
      appBar: _buildAppBar(
        context,
        'Kasir BANGJUN SPOT',
        extra: Selector<CartProvider, int>(
          selector: (_, cart) => cart.totalItems,
          builder: (context, total, _) => total > 0
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ClayColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$total item',
                    style: TextStyle(
                      fontSize: 12,
                      color: ClayColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const KasirPage(),
              ),
            )
          : const KasirPage(),
    );
  }
}

AppBar _buildAppBar(BuildContext context, String title, {Widget? extra}) {
  return AppBar(
    title: Text(title),
    actions: [
      if (extra != null) ...[extra],
      IconButton(
        onPressed: () => context.read<AuthProvider>().logout(),
        icon: const Icon(Icons.logout_rounded),
        tooltip: 'Logout',
      ),
    ],
  );
}

class _ClayPillBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<_NavItem> items;

  const _ClayPillBottomNav({
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: ClayCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          elevation: ClayElevation.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              return Flexible(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: active ? 10 : 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? ClayColors.primary.withAlpha(30)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: active
                              ? ClayColors.primary
                              : ClayColors.textMuted,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.horizontal,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: active
                              ? Padding(
                                  key: ValueKey<String>(item.label),
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: ClayColors.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      ],
                    ),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
