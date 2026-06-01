import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../widgets/admin_ui_helpers.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  // MODAL PARA EDITAR ROL Y DATOS DEL USUARIO
  void _showEditUserDialog(BuildContext context, UserModel user) {
    bool isAdmin = user.isAdmin;
    final nameCtrl = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Editar Permisos de Cliente"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre Completo"),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Es Administrador"),
                    subtitle: const Text("Otorga acceso al panel de control"),
                    value: isAdmin,
                    onChanged: (val) => setState(() => isAdmin = val),
                    activeColor: const Color(0xFFEAB308),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'name': nameCtrl.text,
                      'isAdmin': isAdmin,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Guardar"),
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
                    const Text("Directorio de Clientes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text("Gestione los usuarios y permisos", style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // KPIs SCROLLEABLES HORIZONTALMENTE
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                int admins = snapshot.hasData ? snapshot.data!.docs.where((doc) => doc['isAdmin'] == true).length : 0;
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      KpiCard(title: "Total Registrados", value: total.toString(), subtitle: "Usuarios en BD"),
                      KpiCard(title: "Administradores", value: admins.toString(), subtitle: "Con acceso al panel", valueColor: Colors.blue.shade700),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 16),

            // TABLA SCROLLEABLE
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final users = snapshot.data!.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal, // Habilita deslizar tabla en celular
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                dividerThickness: 1,
                                columns: const [
                                  DataColumn(label: Text("Nombre", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Correo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Rol", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                ],
                                rows: users.map((user) {
                                  return DataRow(cells: [
                                    DataCell(Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(user.email)),
                                    DataCell(StatusBadge(text: user.isAdmin ? 'Admin' : 'Cliente', color: user.isAdmin ? Colors.blue : Colors.green)),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: () => _showEditUserDialog(context, user)),
                                        IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => FirebaseFirestore.instance.collection('users').doc(user.uid).delete()),
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