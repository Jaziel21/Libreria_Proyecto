import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import 'checkout_simulator_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Carrito"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: cart.items.isEmpty
        ? const Center(child: Text("Tu carrito está vacío"))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items.values.toList()[index];
                    final bookId = cart.items.keys.toList()[index];
                    return ListTile(
                      leading: CachedNetworkImage(imageUrl: cartItem.book.imageUrl, width: 50, fit: BoxFit.cover),
                      title: Text(cartItem.book.title, maxLines: 1),
                      subtitle: Text("\$${cartItem.book.price} x ${cartItem.quantity}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cart.updateQuantity(bookId, cartItem.quantity - 1),
                          ),
                          Text(cartItem.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cart.updateQuantity(bookId, cartItem.quantity + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Subtotal"), Text("\$${cart.subtotal.toStringAsFixed(2)}")]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Envío"), Text("\$${cart.shippingCost.toStringAsFixed(2)}")]),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text("\$${cart.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutSimulatorScreen()));
                          },
                          child: const Text("COMPRAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
    );
  }
}