import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/emoji_filter.dart';
import '../../core/utils/input_validators.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/clay_button.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_input.dart';
import '../../widgets/clay_fade_slide.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(onlyActive: false);
      context.read<StockProvider>().loadMovements();
    });
  }

  Future<void> _openStockDialog(Product product, String type) async {
    final qtyController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(type == 'in' ? 'Tambah Stok' : 'Kurangi Stok'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClayInput(
                  controller: qtyController,
                  label: 'Qty',
                  keyboardType: TextInputType.number,
                  inputFormatters: [EmojiFilter.denyEmoji],
                  validator: InputValidators.qty,
                ),
                const SizedBox(height: 10),
                ClayInput(
                  controller: noteController,
                  label: 'Catatan',
                  inputFormatters: [EmojiFilter.denyEmoji],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ClayButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              label: 'Simpan',
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final qty = int.tryParse(qtyController.text.trim()) ?? 0;
    if (qty <= 0) return;
    if (!mounted) return;

    try {
      await context.read<StockProvider>().addMovement(
            productId: product.id,
            qty: qty,
            type: type,
            note: noteController.text.trim().isEmpty
                ? null
                : noteController.text.trim(),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan stok: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final stockProvider = context.watch<StockProvider>();

    if (productProvider.isLoading || stockProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.error != null) {
      return Center(child: Text('Gagal memuat produk: ${productProvider.error}'));
    }

    if (stockProvider.error != null) {
      return Center(child: Text('Gagal memuat stok: ${stockProvider.error}'));
    }

    final products = productProvider.products;
    final movements = stockProvider.movements;

    final stockMap = <String, int>{};
    for (final product in products) {
      stockMap[product.id] = 0;
    }
    for (final movement in movements) {
      final current = stockMap[movement.productId] ?? 0;
      final delta = movement.type == 'out' ? -movement.qty : movement.qty;
      stockMap[movement.productId] = current + delta;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Stok Produk',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final qty = stockMap[product.id] ?? 0;
                return ClayFadeSlide(
                  index: index,
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name),
                              const SizedBox(height: 4),
                              Text('Stok: $qty'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _openStockDialog(product, 'out'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _openStockDialog(product, 'in'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Riwayat Stok',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];
                final product = products.firstWhere(
                  (p) => p.id == movement.productId,
                  orElse: () => Product(
                    id: movement.productId,
                    name: 'Produk',
                    category: null,
                    price: 0,
                    imageUrl: null,
                    isActive: true,
                    createdAt: null,
                  ),
                );
                return ClayFadeSlide(
                  index: index,
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${product.name} (${movement.type})'),
                        const SizedBox(height: 4),
                        Text('Qty: ${movement.qty} | ${movement.note ?? '-'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
