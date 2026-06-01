class BookModel {
  final String id;
  final String title;
  final String author;
  final String editorial;
  final double price;
  final int stock;
  final String imageUrl;
  final String categoryId;
  final int year;
  final String isbn;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.editorial,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
    required this.year,
    required this.isbn,
  });

  factory BookModel.fromMap(Map<String, dynamic> data, String documentId) {
    return BookModel(
      id: documentId,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      editorial: data['editorial'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      year: data['year'] ?? 0,
      isbn: data['isbn'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'editorial': editorial,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'year': year,
      'isbn': isbn,
    };
  }
}