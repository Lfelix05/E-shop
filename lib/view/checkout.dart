import 'package:flutter/material.dart';

import '../models/adress.dart';
import '../models/cart.dart';
import '../models/database.dart';
import 'profile.dart';
import 'widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final String userId;
  final String userName;

  /// Troca a aba da barra inferior (0 = Home, 3 = Cliente).
  final void Function(int) onSelectTab;

  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.onSelectTab,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<Adress?> _addressFuture;
  Adress? _address;
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  void _loadAddress() {
    _addressFuture = Database.getAddress(widget.userId).then((address) {
      _address = address;
      return address;
    });
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfileScreen(userId: widget.userId, userName: widget.userName),
      ),
    );
    if (!mounted) return;
    setState(_loadAddress);
  }

  Future<void> _placeOrder() async {
    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um endereço de entrega.')),
      );
      return;
    }

    setState(() => _placingOrder = true);
    // Simula o processamento do pedido (sem pagamento real).
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    CartController.instance.clear();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Pedido confirmado!'),
        content: const Text(
          'Seu pedido foi realizado com sucesso. Obrigado pela compra!',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar à loja'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _placingOrder = false);
    widget.onSelectTab(0); // Volta para a Home.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          final cart = CartController.instance;
          if (cart.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Seu carrinho está vazio.\nAdicione produtos antes de finalizar.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(context, 'Resumo do pedido'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final item in cart.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x  ${item.product.title}'
                                  '${item.variantTitle.isEmpty ? '' : ' (${item.variantTitle})'}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatMoney(item.lineTotal, item.currencyCode),
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatMoney(cart.total, cart.currencyCode),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Endereço de entrega'),
              const SizedBox(height: 8),
              _buildAddress(),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _placingOrder ? null : _placeOrder,
                child: _placingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Finalizar pedido'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddress() {
    return FutureBuilder<Adress?>(
      future: _addressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final address = snapshot.data;
        if (address == null) {
          return _AddressCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nenhum endereço cadastrado.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openProfile,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Cadastrar endereço'),
                ),
              ],
            ),
          );
        }
        return _AddressCard(
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.street,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${address.city} - ${address.state}, ${address.zipCode}',
                    ),
                    Text(address.country),
                  ],
                ),
              ),
              TextButton(onPressed: _openProfile, child: const Text('Alterar')),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Widget child;

  const _AddressCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
