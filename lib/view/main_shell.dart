import 'package:flutter/material.dart';

import '../models/cart.dart';
import 'cart.dart';
import 'checkout.dart';
import 'home.dart';
import 'profile.dart';

/// Casca principal do app: mantém as quatro telas em um [IndexedStack] e troca
/// entre elas com a barra inferior. Como o estado de cada aba é preservado, a
/// Home não recarrega os produtos toda vez que o usuário volta para ela.
class MainShell extends StatefulWidget {
  final String userId;
  final String userName;
  final int initialIndex;

  const MainShell({
    super.key,
    required this.userId,
    required this.userName,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        userId: widget.userId,
        userName: widget.userName,
        onSelectTab: _select,
      ),
      CartScreen(onSelectTab: _select),
      CheckoutScreen(
        userId: widget.userId,
        userName: widget.userName,
        onSelectTab: _select,
      ),
      ProfileScreen(userId: widget.userId, userName: widget.userName),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          final count = CartController.instance.totalQuantity;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge.count(
                  count: count,
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge.count(
                  count: count,
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Carrinho',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Checkout',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Cliente',
              ),
            ],
          );
        },
      ),
    );
  }
}
