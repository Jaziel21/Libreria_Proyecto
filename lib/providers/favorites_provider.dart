import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BookModel> _favoriteBooks = [];
  bool _isLoading = false;

  List<BookModel> get favoriteBooks => _favoriteBooks;
  bool get isLoading => _isLoading;

  /// Carga los favoritos desde Firestore al iniciar sesión.
  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      // Mapeamos los documentos de Firestore a objetos BookModel
      _favoriteBooks = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error al obtener favoritos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agrega o elimina un libro de los favoritos del usuario en Firestore.
  Future<void> toggleFavorite(BookModel book, String userId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(book.id);

    if (isFavorite(book.id)) {
      // Si ya es favorito, lo eliminamos localmente y en Firestore
      _favoriteBooks.removeWhere((b) => b.id == book.id);
      notifyListeners(); // Actualiza la UI inmediatamente
      await docRef.delete();
    } else {
      // Si no es favorito, lo agregamos localmente y en Firestore
      _favoriteBooks.add(book);
      notifyListeners(); // Actualiza la UI inmediatamente
      await docRef.set(book.toMap());
    }
  }

  /// Verifica si un libro específico está en la lista de favoritos.
  bool isFavorite(String bookId) {
    return _favoriteBooks.any((b) => b.id == bookId);
  }

  /// Limpia los favoritos al cerrar sesión.
  void clearFavorites() {
    _favoriteBooks.clear();
    notifyListeners();
  }
}