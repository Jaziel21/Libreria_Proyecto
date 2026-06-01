import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book_model.dart';
import 'book_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategoryId = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Libros", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Column(
        children: [
          // Barra horizontal de categorías dinámicas
          SizedBox(
            height: 50,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                
                final categories = snapshot.data!.docs;
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final String catId = isAll ? 'Todas' : categories[index - 1].id;
                    final String catName = isAll ? 'Todas' : categories[index - 1]['name'];
                    final isSelected = _selectedCategoryId == catId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(catName),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0F172A),
                        
                        backgroundColor: Colors.grey[200],
                        onSelected: (_) => setState(() => _selectedCategoryId = catId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Grilla de Libros Filtrados
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategoryId == 'Todas'
                  ? FirebaseFirestore.instance.collection('books').snapshots()
                  : FirebaseFirestore.instance.collection('books').where('categoryId', isEqualTo: _selectedCategoryId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay libros disponibles en esta categoría."));
                }

                final books = snapshot.data!.docs.map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                child: CachedNetworkImage(
                                  imageUrl: book.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.book)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(book.author, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1),
                                  const SizedBox(height: 4),
                                  Text("\$${book.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}