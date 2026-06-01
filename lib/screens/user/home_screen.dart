import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/book_model.dart';
import '../../widgets/book_card.dart';
import 'catalog_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import '../auth/login_screen.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreService = FirestoreService();

    // Protección de ruta
    if (authProvider.firebaseUser == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LibroApp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        // Drawer mejorado con icono de libro en el header y iconos en los items
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0F172A)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xFFEAB308),
                child: Icon(Icons.menu_book, size: 32, color: Color(0xFF0F172A)),
              ),
              accountName: const Text('LibroApp', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text('Bienvenido'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Catálogo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Carrito'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal de librería desde Github (ejemplo de URL)
            CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=1000&auto=format&fit=crop', 
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                height: 200, color: Colors.grey[300], child: const Center(child: Icon(Icons.image, size: 50)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bienvenido a LibroApp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Encuentra tu próxima gran aventura literaria.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Nuevos Libros", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            
            // Sección de los 3 últimos libros + card de ver todo
            SizedBox(
              height: 250,
              child: FutureBuilder<List<BookModel>>(
                future: firestoreService.getLatestBooks(limit: 3),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay libros disponibles"));
                  }
                  
                  List<BookModel> books = snapshot.data!;
                  
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      ...books.map((book) => Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        child: BookCard(
                          book: book,
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(book: book)
                              )
                            );
                          },
                        ),
                      )).toList(),
                      // Card "Ver catálogo completo"
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen())),
                        child: Container(
                          width: 160,
                          child: Card(
                            color: const Color(0xFF0F172A),
                            child: const Center(
                              child: Text(
                                "Ver catálogo\ncompleto",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}