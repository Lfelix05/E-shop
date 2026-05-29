import 'package:flutter/material.dart';

/// Formata um valor monetário com o símbolo da moeda quando conhecido.
String formatMoney(double amount, String currencyCode) {
  final value = amount.toStringAsFixed(2);
  switch (currencyCode) {
    case 'BRL':
      return 'R\$ $value';
    case 'USD':
      return 'US\$ $value';
    case 'CAD':
      return 'CA\$ $value';
    case 'EUR':
      return '€ $value';
    case '':
      return value;
    default:
      return '$currencyCode $value';
  }
}

/// Imagem de produto vinda da rede, com indicador de carregamento e fallback.
class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFEDEAF6),
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      );
    }
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFEDEAF6),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0xFFEDEAF6),
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
