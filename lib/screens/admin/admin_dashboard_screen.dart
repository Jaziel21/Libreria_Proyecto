import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

// Importamos las pantallas de administración que ya construimos
import 'admin_books_screen.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_authors_screen.dart';
import 'admin_editorials_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Protección de ruta: Si no hay usuario o no es admin, lo mandamos al Login.
    // Usamos addPostFrameCallback para evitar errores de redibujado mientras se construye la pantalla.
    if (authProvider.firebaseUser == null || !authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      });
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFEAB308))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              authProvider.signOut(context);
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen()), 
                (route) => false
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenido al panel",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Gestiona tu inventario, ventas y clientes desde aquí.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Imagen decorativa del panel
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=1000&auto=format&fit=crop', 
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150, 
                  color: Colors.grey[200], 
                  child: const Center(child: CircularProgressIndicator())
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150, 
                  color: Colors.grey[300], 
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Grid de accesos directos
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1, // Ajuste para que las tarjetas se vean más proporcionadas
              children: [
                _buildDashboardCard(
                  context, 
                  "Libros", 
                  Icons.menu_book, 
                  Colors.green, 
                  const AdminBooksScreen()
                ),
                _buildDashboardCard(
                  context, 
                  "Ventas", 
                  Icons.shopping_cart, 
                  Colors.orange, 
                  const AdminOrdersScreen()
                ),
                _buildDashboardCard(
                  context, 
                  "Categorías", 
                  Icons.category, 
                  Colors.purple, 
                  const AdminCategoriesScreen()
                ),
                _buildDashboardCard(
                  context, 
                  "Clientes", 
                  Icons.group, 
                  Colors.teal, 
                  const AdminUsersScreen()
                ),
                // Nota: Para Autores y Editoriales, puedes duplicar el archivo 
                // AdminCategoriesScreen cambiando la colección a 'authors' y 'editorials'
                _buildDashboardCard(
                  context, 
                  "Autores", 
                  Icons.person, 
                  Colors.blue, 
                  const AdminAuthorsScreen()
                ),
                _buildDashboardCard(
                  context, 
                  "Editoriales", 
                  Icons.domain, 
                  Colors.red, 
                  const AdminEditorialsScreen()
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Widget reutilizable para crear las tarjetas del menú
  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, Widget? destination) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (destination != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('La sección de $title está en construcción'))
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.05), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Color(0xFF0F172A)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}