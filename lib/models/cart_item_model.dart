import 'book_model.dart';

class CartItemModel {
  final BookModel book;
  int quantity;

  CartItemModel({
    required this.book,
    this.quantity = 1,
  });
}