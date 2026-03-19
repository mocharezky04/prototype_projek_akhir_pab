import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/clay_button.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_fade_slide.dart';
import '../../theme/clay_colors.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  static const List<String> _categoryOptions = [
    'Aneka Ayam',
    'Aneka Nasi Goreng',
    'Aneka Indomie',
    'Minuman',
    'Lainnya',
  ];

  List<String> _orderedCategories(Iterable<String> keys) {
    final ordered = <String>[];
    for (final key in _categoryOptions) {
      if (keys.contains(key)) ordered.add(key);
    }
    final extras = keys.where((k) => !_categoryOptions.contains(k)).toList()..sort();
    ordered.addAll(extras);
    return ordered;
  }

  Map<String, List<Product>> _groupProducts(List<Product> items) {
    final map = <String, List<Product>>{};
    for (final product in items) {
      final raw = product.category?.trim();
      final key = (raw == null || raw.isEmpty) ? 'Lainnya' : raw;
      map.putIfAbsent(key, () => []).add(product);
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.name.compareTo(b.name));
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(onlyActive: true);
    });
  }

  Future<void> _checkout(CartProvider cart) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final items = cart.itemsList.map((item) {
        return {
          'product_id': item.product.id,
          'qty': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      final total = cart.totalPrice;
      await context.read<TransactionProvider>().createTransaction(
            cashierId: user.id,
            total: total,
            items: items,
          );

      cart.clear();
      await LocalNotificationService.showTransactionSuccess(total);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();

    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.error != null) {
      return Center(child: Text('Gagal memuat menu: ${productProvider.error}'));
    }

    final products = productProvider.products;
    final grouped = _groupProducts(products);
    final categories = _orderedCategories(grouped.keys);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: () {
              final widgets = <Widget>[];
              var itemIndex = 0;
              for (final category in categories) {
                final items = grouped[category] ?? [];
                if (items.isEmpty) continue;
                widgets.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                );
                widgets.addAll(
                  items.map((product) {
                    final currentIndex = itemIndex++;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClayFadeSlide(
                        index: currentIndex,
                        child: ClayCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(formatRupiah(product.price)),
                                  ],
                                ),
                              ),
                              ClayButton(
                                label: 'Tambah',
                                onPressed: () {
                                  context.read<CartProvider>().addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('${product.name} ditambahkan ke pesanan'),
                                      duration: const Duration(milliseconds: 700),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }
              return widgets;
            }(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClayCard(
            padding: const EdgeInsets.all(16),
            elevation: ClayElevation.surface,
            child: SizedBox(
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Pesanan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      if (cart.totalItems > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ClayColors.primary.withAlpha(38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${cart.totalItems} item'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(child: Text('Belum ada pesanan'))
                        : ListView.builder(
                            itemCount: cart.itemsList.length,
                            itemBuilder: (context, index) {
                              final item = cart.itemsList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClayCard(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  elevation: ClayElevation.surface,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(formatRupiah(item.total)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: () =>
                                                cart.decrease(item.product.id),
                                          ),
                                          Text(item.quantity.toString()),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: () =>
                                                cart.increase(item.product.id),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => cart.remove(item.product.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total'),
                          Text(
                            formatRupiah(cart.totalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: cart.isEmpty ? null : () => cart.clear(),
                            child: const Text('Clear'),
                          ),
                          const SizedBox(width: 8),
                          ClayButton(
                            label: 'Checkout',
                            onPressed: cart.isEmpty ? null : () => _checkout(cart),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
