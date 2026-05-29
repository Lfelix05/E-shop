import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class MockShopService {
  static final _apiUrl = Uri.parse('https://mock.shop/api');

  static const _productsQuery = r'''
    query Products($first: Int!) {
      products(first: $first) {
        edges {
          node {
            id
            title
            description
            vendor
            productType
            featuredImage {
              url
            }
            collections(first: 1) {
              nodes {
                title
              }
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            variants(first: 10) {
              nodes {
                id
                title
                price {
                  amount
                  currencyCode
                }
                image {
                  url
                }
              }
            }
          }
        }
      }
    }
  ''';

  static Future<List<Product>> fetchProducts({int first = 24}) async {
    final response = await http.post(
      _apiUrl,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': _productsQuery,
        'variables': {'first': first},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar produtos: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = decoded['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      throw Exception('MockShop retornou erro ao carregar produtos.');
    }

    final data = decoded['data'] as Map<String, dynamic>?;
    final products = data?['products'] as Map<String, dynamic>?;
    final edges = products?['edges'] as List<dynamic>? ?? <dynamic>[];

    return edges
        .map((edge) => edge as Map<String, dynamic>)
        .map((edge) => edge['node'] as Map<String, dynamic>)
        .map(Product.fromMockShopNode)
        .toList();
  }
}
