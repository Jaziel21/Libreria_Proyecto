import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';
import 'home_screen.dart';

class CheckoutSimulatorScreen extends StatefulWidget {
  const CheckoutSimulatorScreen({Key? key}) : super(key: key);

  @override
  _CheckoutSimulatorScreenState createState() => _CheckoutSimulatorScreenState();
}

class _CheckoutSimulatorScreenState extends State<CheckoutSimulatorScreen> {
  String _paymentMethod = 'Efectivo';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Compra"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Método de Pago", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text("Efectivo"),
              value: 'Efectivo',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            RadioListTile<String>(
              title: const Text("Tarjeta de Crédito/Débito"),
              value: 'Tarjeta',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            if (_paymentMethod == 'Tarjeta') ...[
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Número de Tarjeta (16 dígitos)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      validator: (value) => value != null && value.length == 16 ? null : "Ingrese 16 dígitos",
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: "Vencimiento (MM/AA)", border: OutlineInputBorder()),
                            validator: (value) => value != null && value.isNotEmpty ? null : "Requerido",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: "CVV", border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            validator: (value) => value != null && value.length == 3 ? null : "3 dígitos",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308)),
                onPressed: () async {
                  if (_paymentMethod == 'Tarjeta' && !_formKey.currentState!.validate()) {
                    return;
                  }

                  // Crear pedido
                  final order = OrderModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: auth.firebaseUser!.uid,
                    items: cart.items.values.map((item) => {
                      'bookId': item.book.id,
                      'title': item.book.title,
                      'quantity': item.quantity,
                      'price': item.book.price,
                    }).toList(),
                    total: cart.totalAmount,
                    status: 'En proceso',
                    date: DateTime.now(),
                    paymentMethod: _paymentMethod,
                  );

                  await FirestoreService().placeOrder(order);
                  cart.clearCart();

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Pedido registrado con éxito!')));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                },
                child: const Text("PAGAR Y REGISTRAR PEDIDO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}