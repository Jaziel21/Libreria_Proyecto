import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_ui_helpers.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  void _showOrderStatusDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String currentStatus = data['status'] ?? 'Pendiente';
    final List<String> statusOptions = ['Pendiente', 'Entregado', 'Cancelado'];

    // PROTECCIÓN: Si el estado guardado no coincide exactamente con las opciones
    // (por ejemplo, si está en minúsculas), lo forzamos a uno válido para no romper la UI.
    if (!statusOptions.contains(currentStatus)) {
      currentStatus = 'Pendiente'; 
    }

    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Actualizar Estado del Pedido"),
              content: DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: "Estado"),
                items: statusOptions.map((String status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => selectedStatus = newValue);
                },
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () async {
                    // Solo actualizamos el estado, nada más
                    await FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
                      'status': selectedStatus,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Actualizar"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16, runSpacing: 8, alignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Historial de Ventas", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text("Gestione los pedidos de su librería", style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: StreamBuilder<QuerySnapshot>(
                  // Eliminado el orderBy para evitar requerir índices compuestos en Firebase si no los has creado
                  stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                dividerThickness: 1,
                                columns: const [
                                  DataColumn(label: Text("Ticket ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                ],
                                rows: docs.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final String status = data['status'] ?? 'Pendiente';
                                  
                                  // Parseo seguro de total
                                  final double total = double.tryParse(data['total']?.toString() ?? '0') ?? 0.0;
                                  
                                  // Parseo seguro de fecha
                                  DateTime date = DateTime.now();
                                  if (data['date'] != null) {
                                    if (data['date'] is Timestamp) {
                                      date = (data['date'] as Timestamp).toDate();
                                    } else if (data['date'] is String) {
                                      date = DateTime.tryParse(data['date']) ?? DateTime.now();
                                    }
                                  }

                                  Color statusColor = Colors.orange;
                                  if (status == 'Entregado') statusColor = Colors.green;
                                  if (status == 'Cancelado') statusColor = Colors.red;

                                  return DataRow(cells: [
                                    DataCell(Text("#${doc.id.substring(doc.id.length - 5).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text("${date.day}/${date.month}/${date.year}")),
                                    DataCell(Text("\$${total.toStringAsFixed(2)}")),
                                    DataCell(StatusBadge(text: status, color: statusColor)),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), 
                                          onPressed: () => _showOrderStatusDialog(context, doc)
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}