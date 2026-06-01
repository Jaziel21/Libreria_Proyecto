import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- MÉTODOS DE LIBROS ---
  Stream<List<BookModel>> streamBooks() {
    return _db.collection('books').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => BookModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<List<BookModel>> getLatestBooks({int limit = 3}) async {
    final snapshot = await _db
        .collection('books')
        .orderBy('year', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => BookModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- MÉTODOS DE PEDIDOS (VENTAS) ---
  Future<void> placeOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toMap());
    
    // Aquí deberíamos descontar el stock de los libros en un batch de Firestore
    WriteBatch batch = _db.batch();
    for (var item in order.items) {
      DocumentReference bookRef = _db.collection('books').doc(item['bookId']);
      batch.update(bookRef, {'stock': FieldValue.increment(-item['quantity'])});
    }
    await batch.commit();
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}