import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book_model.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;
  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (user != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Icon(Icons.favorite_border, color: Colors.grey);
                }
                
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> favorites = userData['favorites'] ?? [];
                final bool isFavorite = favorites.contains(book.id);

                return IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: isFavorite ? Colors.red : Colors.grey,
                  onPressed: () async {
                    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                    if (isFavorite) {
                      await userRef.update({'favorites': FieldValue.arrayRemove([book.id])});
                    } else {
                      await userRef.update({'favorites': FieldValue.arrayUnion([book.id])});
                    }
                  },
                );
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: book.imageUrl, height: 300, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              Text("por ${book.author}", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [const Text("Editorial"), Text(book.editorial, style: const TextStyle(fontWeight: FontWeight.bold))]),
                      Column(children: [const Text("Precio"), Text("\$${book.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                      Column(children: [const Text("Stock"), Text("${book.stock} unids", style: const TextStyle(fontWeight: FontWeight.bold))]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEAB308)),
                  icon: const Icon(Icons.shopping_cart, color: Colors.black),
                  label: const Text("AGREGAR AL CARRITO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addItem(book);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Libro agregado al carrito')));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}