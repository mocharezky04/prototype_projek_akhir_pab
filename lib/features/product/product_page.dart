import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/emoji_filter.dart';
import '../../core/utils/input_validators.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/clay_button.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_input.dart';
import '../../widgets/clay_fade_slide.dart';
import '../../widgets/clay_fab.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
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
      context.read<ProductProvider>().loadProducts(onlyActive: false);
    });
  }

  Future<void> _openProductForm({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    final imageController = TextEditingController(text: product?.imageUrl ?? '');
    String selectedCategory = product?.category?.trim().isNotEmpty == true
        ? product!.category!.trim()
        : _categoryOptions.first;
    if (!_categoryOptions.contains(selectedCategory)) {
      selectedCategory = 'Lainnya';
    }
    bool isActive = product?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClayInput(
                        controller: nameController,
                        label: 'Nama Produk',
                        inputFormatters: [EmojiFilter.denyEmoji],
                        validator: (v) => InputValidators.requiredField(v, 'Nama produk'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: _categoryOptions
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setStateDialog(() => selectedCategory = val);
                        },
                        validator: (v) => InputValidators.requiredField(v, 'Kategori'),
                      ),
                      const SizedBox(height: 10),
                      ClayInput(
                        controller: priceController,
                        label: 'Harga',
                        keyboardType: TextInputType.number,
                        inputFormatters: [EmojiFilter.denyEmoji],
                        validator: InputValidators.price,
                      ),
                      const SizedBox(height: 10),
                      ClayInput(
                        controller: imageController,
                        label: 'Image URL (opsional)',
                        inputFormatters: [EmojiFilter.denyEmoji],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Aktif'),
                          Switch(
                            value: isActive,
                            onChanged: (val) => setStateDialog(() => isActive = val),
                          ),
                        ],
                      ),
                    ],
                  ),
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
      },
    );

    if (result != true) return;
    if (!mounted) return;

    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final newProduct = Product(
      id: product?.id ?? '',
      name: nameController.text.trim(),
      category: selectedCategory.trim().isEmpty ? 'Lainnya' : selectedCategory.trim(),
      price: price,
      imageUrl: imageController.text.trim().isEmpty
          ? null
          : imageController.text.trim(),
      isActive: isActive,
      createdAt: product?.createdAt,
    );

    try {
      final provider = context.read<ProductProvider>();
      if (product == null) {
        await provider.addProduct(newProduct);
      } else {
        await provider.updateProduct(newProduct);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await context.read<ProductProvider>().deleteProduct(product.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus produk: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Gagal memuat produk: ${provider.error}'));
    }

    final products = provider.products;
    final grouped = _groupProducts(products);
    final categories = _orderedCategories(grouped.keys);

    return Scaffold(
      floatingActionButton: ClayFab(
        icon: Icons.add,
        onPressed: () => _openProductForm(),
      ),
      body: products.isEmpty
          ? const Center(child: Text('Belum ada produk.'))
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: () {
                final widgets = <Widget>[];
                var itemIndex = 0;
                for (final category in categories) {
                  final items = grouped[category] ?? [];
                  if (items.isEmpty) continue;
                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ClayFadeSlide(
                          index: currentIndex,
                          child: ClayCard(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name),
                                      const SizedBox(height: 6),
                                      Text(formatRupiah(product.price)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openProductForm(product: product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(product),
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
    );
  }
}
