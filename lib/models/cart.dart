import 'package:flutter/foundation.dart';

import 'product.dart';

/// Um item do carrinho: produto, variante escolhida (opcional) e quantidade.
class CartItem {
  final Product product;
  final ProductVariant? variant;
  int quantity;

  CartItem({required this.product, this.variant, this.quantity = 1});

  double get unitPrice => variant?.price ?? product.price;
  String get currencyCode => variant?.currencyCode ?? product.currencyCode;
  String get image => (variant != null && variant!.image.isNotEmpty)
      ? variant!.image
      : product.image;
  String get variantTitle => variant?.title ?? '';
  double get lineTotal => unitPrice * quantity;

  /// Identifica de forma única o par produto + variante no carrinho.
  String get key => '${product.id}|${variant?.id ?? ''}';
}

/// Carrinho em memória compartilhado pelo app.
///
/// Usa [ChangeNotifier] (nativo do Flutter) para que qualquer tela possa
/// reagir a mudanças via [ListenableBuilder], sem dependências extras.
class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  String get currencyCode => _items.isEmpty ? '' : _items.first.currencyCode;

  void add(Product product, {ProductVariant? variant, int quantity = 1}) {
    final newItem = CartItem(
      product: product,
      variant: variant,
      quantity: quantity,
    );
    final existing = _items
        .where((item) => item.key == newItem.key)
        .firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrement(CartItem item) {
    item.quantity--;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
