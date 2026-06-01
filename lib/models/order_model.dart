class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items; // Lista de libros y cantidades
  final double total;
  final String status; // 'En proceso', 'En camino', 'Entregado'
  final DateTime date;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.date,
    required this.paymentMethod,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'En proceso',
      date: data['date']?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'] ?? 'Efectivo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'total': total,
      'status': status,
      'date': date,
      'paymentMethod': paymentMethod,
    };
  }
}