import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Agregado para la consulta directa
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(user.phone),
            Text(user.address, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Aquí iría la lógica para abrir un modal y editar información
              },
              icon: const Icon(Icons.edit, color: Color(0xFF0F172A)),
              label: const Text("Editar Información", style: TextStyle(color: Color(0xFF0F172A))),
            ),
            const Divider(height: 48, thickness: 1),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Mis Pedidos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            // --- STREAM BUILDER ACTUALIZADO ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid) // Filtro directo a Firebase
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No has realizado ningún pedido aún.");

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderData = order.data() as Map<String, dynamic>;

                    // Lectura segura de datos para evitar errores de tipo
                    final status = orderData['status'] ?? 'Pendiente';
                    final total = orderData['total']?.toString() ?? '0.00';
                    
                    // Lectura segura de la fecha
                    DateTime orderDate = DateTime.now();
                    if (orderData['date'] is Timestamp) {
                      orderDate = (orderData['date'] as Timestamp).toDate();
                    } else if (orderData['date'] is String) {
                      orderDate = DateTime.tryParse(orderData['date']) ?? DateTime.now();
                    }

                    return Card(
                      child: ListTile(
                        title: Text("Pedido #${order.id.substring(order.id.length - 5).toUpperCase()}"),
                        subtitle: Text("Total: \$$total - ${orderDate.day}/${orderDate.month}/${orderDate.year}"),
                        trailing: Chip(
                          label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: status == 'Entregado' ? Colors.green : Colors.orange,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // --- FIN STREAM BUILDER ---

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  authProvider.signOut(context);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                },
                child: const Text("CERRAR SESIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}