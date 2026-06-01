import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  final double shippingCost = 100.0;

  Map<String, CartItemModel> get items => _items;

  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.book.price * cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    if (_items.isEmpty) return 0.0;
    return subtotal + shippingCost;
  }

  void addItem(BookModel book) {
    if (_items.containsKey(book.id)) {
      // Si ya existe, incrementar cantidad
      _items.update(
        book.id,
        (existingCartItem) => CartItemModel(
          book: existingCartItem.book,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Si no existe, añadir nuevo
      _items.putIfAbsent(
        book.id,
        () => CartItemModel(book: book, quantity: 1),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String bookId, int newQuantity) {
    if (!_items.containsKey(bookId)) return;
    
    if (newQuantity <= 0) {
      removeItem(bookId);
    } else {
      _items.update(
        bookId,
        (existingItem) => CartItemModel(
          book: existingItem.book,
          quantity: newQuantity,
        ),
      );
      notifyListeners();
    }
  }

  void removeItem(String bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}