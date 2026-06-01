import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Inicia sesión para ver tus favoritos.")));

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Favoritos"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!userSnapshot.data!.exists) return const Center(child: Text("No se encontraron datos del usuario."));

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> favoriteIds = userData['favorites'] ?? [];

          if (favoriteIds.isEmpty) {
            return const Center(child: Text("Aún no tienes libros guardados en tus favoritos."));
          }

          // Consultamos los libros cuyos IDs estén en la lista de favoritos del usuario
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').where(FieldPath.documentId, whereIn: favoriteIds).snapshots(),
            builder: (context, booksSnapshot) {
              if (!booksSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              final favoriteBooks = booksSnapshot.data!.docs.map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = favoriteBooks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(book.imageUrl, width: 50, fit: BoxFit.cover),
                      title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(book.author),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}