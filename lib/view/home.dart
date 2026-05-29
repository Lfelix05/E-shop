import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/mock_shop_service.dart';
import 'product_detail.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final void Function(int) onSelectTab;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.onSelectTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Categorias de gênero que a MockShop já traz no campo `category`.
  static const _categories = ['Men', 'Women', 'Unisex'];

  late Future<List<Product>> _productsFuture;

  /// Categoria selecionada (null = mostrar todos).
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _productsFuture = MockShopService.fetchProducts();
  }

  void _reload() {
    setState(() {
      _productsFuture = MockShopService.fetchProducts();
    });
  }

  /// Filtra a lista já carregada, sem novas chamadas à API.
  List<Product> _applyFilter(List<Product> products) {
    if (_selectedCategory == null) return products;
    return products
        .where(
          (p) => p.category.toLowerCase() == _selectedCategory!.toLowerCase(),
        )
        .toList();
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          onGoToCart: () => widget.onSelectTab(1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Shop')),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Erro ao carregar produtos.'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: _reload,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Nenhum produto disponível.'));
          }

          final visible = _applyFilter(products);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${widget.userName}!',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Encontre os produtos perfeitos para você',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      _CategoryFilter(
                        categories: _categories,
                        selected: _selectedCategory,
                        onSelected: (category) =>
                            setState(() => _selectedCategory = category),
                      ),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Nenhum produto nesta categoria.'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ProductCard(
                        product: visible[index],
                        onTap: () => _openProduct(visible[index]),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Linha de chips horizontais para filtrar produtos por categoria.
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(category.toUpperCase()),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ProductImage(url: product.image)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(product.price, product.currencyCode),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
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
}
