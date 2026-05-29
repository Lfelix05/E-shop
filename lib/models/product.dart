class ProductVariant {
  final String id;
  final String title;
  final double price;
  final String currencyCode;
  final String image;

  ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    required this.currencyCode,
    required this.image,
  });

  factory ProductVariant.fromMockShopNode(Map<String, dynamic> json) {
    final price = json['price'] as Map<String, dynamic>?;
    final image = json['image'] as Map<String, dynamic>?;
    return ProductVariant(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Padrão',
      price: double.tryParse(price?['amount']?.toString() ?? '') ?? 0,
      currencyCode: price?['currencyCode'] as String? ?? 'CAD',
      image: image?['url'] as String? ?? '',
    );
  }
}

class Product {
  final String id;
  final String title;
  final double price;
  final String currencyCode;
  final String description;
  final String category;
  final String image;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.currencyCode,
    required this.description,
    required this.category,
    required this.image,
    this.variants = const [],
  });

  factory Product.fromMockShopNode(Map<String, dynamic> json) {
    final featuredImage = json['featuredImage'] as Map<String, dynamic>?;
    final priceRange = json['priceRange'] as Map<String, dynamic>?;
    final minVariantPrice =
        priceRange?['minVariantPrice'] as Map<String, dynamic>?;
    final collections = json['collections'] as Map<String, dynamic>?;
    final collectionNodes = collections?['nodes'] as List<dynamic>?;
    final firstCollection = collectionNodes?.firstOrNull;
    final collectionTitle = firstCollection is Map<String, dynamic>
        ? firstCollection['title'] as String?
        : null;
    final productType = (json['productType'] as String?)?.trim();
    final vendor = (json['vendor'] as String?)?.trim();

    final variantsField = json['variants'] as Map<String, dynamic>?;
    final variantNodes = variantsField?['nodes'] as List<dynamic>? ?? [];
    final variants = variantNodes
        .whereType<Map<String, dynamic>>()
        .map(ProductVariant.fromMockShopNode)
        .toList();

    return Product(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Produto sem nome',
      price: double.tryParse(minVariantPrice?['amount']?.toString() ?? '') ?? 0,
      currencyCode: minVariantPrice?['currencyCode'] as String? ?? 'CAD',
      description: json['description'] as String? ?? '',
      category: _firstNonEmpty([collectionTitle, productType, vendor]),
      image: featuredImage?['url'] as String? ?? '',
      variants: variants,
    );
  }

  /// Há variações reais para o usuário escolher (mais de uma).
  bool get hasVariants => variants.length > 1;
}

String _firstNonEmpty(List<String?> values) {
  return values.firstWhere(
    (value) => value != null && value.isNotEmpty,
    orElse: () => 'MockShop',
  )!;
}
