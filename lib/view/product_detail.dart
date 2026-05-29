import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/product.dart';
import 'widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  /// Chamado quando o usuário quer ir ao carrinho (troca para a aba Carrinho).
  final VoidCallback? onGoToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onGoToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    final variants = widget.product.variants;
    _selectedVariant = variants.isNotEmpty ? variants.first : null;
  }

  double get _price => _selectedVariant?.price ?? widget.product.price;
  String get _currency =>
      _selectedVariant?.currencyCode ?? widget.product.currencyCode;
  String get _image => (_selectedVariant?.image.isNotEmpty ?? false)
      ? _selectedVariant!.image
      : widget.product.image;

  void _addToCart() {
    CartController.instance.add(
      widget.product,
      variant: widget.product.hasVariants ? _selectedVariant : null,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Produto adicionado ao carrinho.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: widget.onGoToCart == null
              ? null
              : SnackBarAction(
                  label: 'VER CARRINHO',
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onGoToCart!();
                  },
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.white,
              child: ProductImage(url: _image, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(product.category),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  side: BorderSide.none,
                ),
                const SizedBox(height: 12),
                Text(
                  product.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatMoney(_price, _currency),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.hasVariants) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Variações',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.variants.map((variant) {
                      return ChoiceChip(
                        label: Text(variant.title),
                        selected: _selectedVariant?.id == variant.id,
                        onSelected: (_) =>
                            setState(() => _selectedVariant = variant),
                      );
                    }).toList(),
                  ),
                ],
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Adicionar ao carrinho'),
          ),
        ),
      ),
    );
  }
}
