import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_ui_helpers.dart';

class AdminEditorialsScreen extends StatelessWidget {
  const AdminEditorialsScreen({Key? key}) : super(key: key);

  void _showEditorialDialog(BuildContext context, {DocumentSnapshot? doc}) {
    final nameCtrl = TextEditingController(text: doc?['name'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Agregar Editorial" : "Editar Editorial"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Nombre de la Editorial"),
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
                  await FirebaseFirestore.instance.collection('editorials').add({'name': nameCtrl.text});
                } else {
                  await FirebaseFirestore.instance.collection('editorials').doc(doc.id).update({'name': nameCtrl.text});
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gestión de Editoriales", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text("Administre los sellos y casas editoriales", style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onPressed: () => _showEditorialDialog(context), 
                  icon: const Icon(Icons.add, size: 18), 
                  label: const Text("NUEVA")
                )
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('editorials').orderBy('name').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final editorials = snapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.transparent),
                              dividerThickness: 1,
                              dataRowMinHeight: 60,
                              dataRowMaxHeight: 60,
                              columns: const [
                                DataColumn(label: Text("Nombre de la Editorial", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                              ],
                              rows: editorials.map((doc) {
                                return DataRow(cells: [
                                  DataCell(Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                                  const DataCell(StatusBadge(text: "Activa", color: Colors.green)),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: () => _showEditorialDialog(context, doc: doc)),
                                      IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () {
                                        FirebaseFirestore.instance.collection('editorials').doc(doc.id).delete();
                                      }),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Total: ${editorials.length} editoriales registradas", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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