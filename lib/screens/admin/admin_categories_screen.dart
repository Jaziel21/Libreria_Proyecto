import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_ui_helpers.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);

  // MODAL PARA CREAR Y EDITAR CATEGORÍAS
  void _showCategoryDialog(BuildContext context, {DocumentSnapshot? doc}) {
    final nameCtrl = TextEditingController(text: doc?['name'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Nueva Categoría" : "Editar Categoría"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Nombre de la Categoría"),
            validator: (v) => v!.isEmpty ? "Requerido" : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (doc == null) {
                  await FirebaseFirestore.instance.collection('categories').add({'name': nameCtrl.text});
                } else {
                  await FirebaseFirestore.instance.collection('categories').doc(doc.id).update({'name': nameCtrl.text});
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding ajustado para móviles
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO RESPONSIVO (Wrap acomoda los elementos si no caben)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Categorías Literarias", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text("Organice los libros por géneros", style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  onPressed: () => _showCategoryDialog(context), 
                  icon: const Icon(Icons.add, size: 18), 
                  label: const Text("NUEVA")
                )
              ],
            ),
            const SizedBox(height: 24),

            // TABLA SCROLLEABLE EN AMBAS DIRECCIONES
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final categories = snapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          // Doble Scroll para dispositivos móviles
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                dividerThickness: 1,
                                columns: const [
                                  DataColumn(label: Text("Nombre de Categoría", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                ],
                                rows: categories.map((doc) {
                                  return DataRow(cells: [
                                    DataCell(Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                                    const DataCell(StatusBadge(text: "Activa", color: Colors.green)),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: () => _showCategoryDialog(context, doc: doc)),
                                        IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => FirebaseFirestore.instance.collection('categories').doc(doc.id).delete()),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Total: ${categories.length} categorías", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        )
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