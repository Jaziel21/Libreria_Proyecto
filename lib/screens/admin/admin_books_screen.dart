import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book_model.dart';
import '../../widgets/admin_ui_helpers.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({Key? key}) : super(key: key);

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  // --- VARIABLES DE ESTADO PARA FILTROS Y BÚSQUEDA ---
  String _searchQuery = '';
  String _filterStatus = 'Todos'; // Todos, Disponibles, Stock bajo, Agotados
  String _sortBy = 'titulo_asc'; // Criterio de ordenamiento

  // Controlador de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // --- MODAL DE FILTROS ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtros y Orden", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Filtro por Estado
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Estado del Inventario", border: OutlineInputBorder()),
                    value: _filterStatus,
                    items: ['Todos', 'Disponibles', 'Stock bajo', 'Agotados']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      setModalState(() => _filterStatus = val!);
                      setState(() => _filterStatus = val!); // Actualiza la pantalla principal
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filtro de Ordenamiento
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Ordenar por", border: OutlineInputBorder()),
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'titulo_asc', child: Text("Título (A-Z)")),
                      DropdownMenuItem(value: 'titulo_desc', child: Text("Título (Z-A)")),
                      DropdownMenuItem(value: 'autor_asc', child: Text("Autor (A-Z)")),
                      DropdownMenuItem(value: 'precio_asc', child: Text("Precio (Menor a Mayor)")),
                      DropdownMenuItem(value: 'precio_desc', child: Text("Precio (Mayor a Menor)")),
                      DropdownMenuItem(value: 'stock_asc', child: Text("Stock (Menor a Mayor)")),
                      DropdownMenuItem(value: 'stock_desc', child: Text("Stock (Mayor a Menor)")),
                    ],
                    onChanged: (val) {
                      setModalState(() => _sortBy = val!);
                      setState(() => _sortBy = val!);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("APLICAR FILTROS"),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  // --- MODAL PARA VER DETALLES (EL OJO) ---
  void _showBookDetails(BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detalles del Libro"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(imageUrl: book.imageUrl, height: 150, fit: BoxFit.cover, errorWidget: (c, u, e) => const Icon(Icons.book, size: 50)),
              ),
              const SizedBox(height: 16),
              Text(book.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              Text(book.author, style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 30),
              _detailRow("ISBN:", book.toMap()['isbn']?.toString() ?? 'N/A'), // Acceso seguro en caso de que no lo hayas agregado al modelo aún
              _detailRow("Editorial:", book.editorial),
              _detailRow("Precio:", "\$${book.price.toStringAsFixed(2)}"),
              _detailRow("Stock:", "${book.stock} unidades"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
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
            // --- ENCABEZADO ---
            const Text("Inventario de Libros", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text("Gestione el catálogo completo de su librería", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),

            // --- BUSCADOR Y BOTONES (Adaptable a móviles) ---
            Wrap(
              spacing: 8,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Buscador
                SizedBox(
                  width: MediaQuery.of(context).size.width > 600 ? 300 : double.infinity,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Buscar por título, ISBN o autor...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ),
                // Botón Filtros
                Container(
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(icon: const Icon(Icons.filter_alt_outlined), onPressed: _showFilterModal, tooltip: 'Filtros'),
                ),
                // Botón Nuevo
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  onPressed: () => showDialog(context: context, builder: (_) => const _BookFormDialog()), 
                  icon: const Icon(Icons.add, size: 18), 
                  label: const Text("NUEVO LIBRO")
                )
              ],
            ),
            const SizedBox(height: 20),

            // --- TABLA Y KPIS ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  // Mapear libros
                  List<BookModel> books = snapshot.data!.docs.map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                  // 1. LÓGICA DE FILTRADO
                  books = books.where((book) {
                    // Filtro de Búsqueda de texto
                    final query = _searchQuery.toLowerCase();
                    final isbnStr = (book.toMap()['isbn'] ?? '').toLowerCase();
                    final matchSearch = book.title.toLowerCase().contains(query) || book.author.toLowerCase().contains(query) || isbnStr.contains(query);

                    // Filtro de Estado
                    bool matchStatus = true;
                    if (_filterStatus == 'Disponibles') matchStatus = book.stock > 10;
                    if (_filterStatus == 'Stock bajo') matchStatus = book.stock > 0 && book.stock <= 10;
                    if (_filterStatus == 'Agotados') matchStatus = book.stock == 0;

                    return matchSearch && matchStatus;
                  }).toList();

                  // 2. LÓGICA DE ORDENAMIENTO
                  books.sort((a, b) {
                    switch (_sortBy) {
                      case 'titulo_asc': return a.title.toLowerCase().compareTo(b.title.toLowerCase());
                      case 'titulo_desc': return b.title.toLowerCase().compareTo(a.title.toLowerCase());
                      case 'autor_asc': return a.author.toLowerCase().compareTo(b.author.toLowerCase());
                      case 'precio_asc': return a.price.compareTo(b.price);
                      case 'precio_desc': return b.price.compareTo(a.price);
                      case 'stock_asc': return a.stock.compareTo(b.stock);
                      case 'stock_desc': return b.stock.compareTo(a.stock);
                      default: return 0;
                    }
                  });

                  // Cálculos para KPIs sobre la lista FILTRADA (o puedes hacerlo sobre la total si prefieres)
                  int totalBooks = books.length;
                  int totalStock = books.fold(0, (sum, item) => sum + item.stock);
                  int lowStockCount = books.where((b) => b.stock > 0 && b.stock <= 10).length;
                  double inventoryValue = books.fold(0.0, (sum, item) => sum + (item.price * item.stock));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- TARJETAS KPI (ESTILO DISEÑO) ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            KpiCard(title: "Total Libros", value: totalBooks.toString(), subtitle: "Activos"),
                            KpiCard(title: "Stock Total", value: totalStock.toString(), subtitle: "Unidades"),
                            KpiCard(title: "Stock Bajo", value: lowStockCount.toString(), subtitle: "Libros", valueColor: Colors.red),
                            KpiCard(title: "Valor Inventario", value: "\$${inventoryValue.toStringAsFixed(2)}", subtitle: "MXN"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- TABLA DE DATOS ---
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(
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
                                      dataRowMinHeight: 70,
                                      dataRowMaxHeight: 70,
                                      columns: const [
                                        DataColumn(label: Text("Portada", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Título", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("ISBN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Autor Principal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Editorial", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Precio", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Stock", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                        DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                      ],
                                      rows: books.map((book) {
                                        // Lógica de Estado
                                        String statusText = "Disponible";
                                        Color statusColor = Colors.green;
                                        if (book.stock == 0) {
                                          statusText = "Agotado";
                                          statusColor = Colors.red;
                                        } else if (book.stock <= 10) {
                                          statusText = "Stock bajo";
                                          statusColor = Colors.orange;
                                        }

                                        // Extracción segura del ISBN
                                        String isbnDisplay = book.toMap()['isbn']?.toString() ?? 'N/A';

                                        return DataRow(cells: [
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: CachedNetworkImage(
                                                  imageUrl: book.imageUrl, width: 40, height: 60, fit: BoxFit.cover,
                                                  errorWidget: (context, url, error) => Container(width: 40, color: Colors.grey[300], child: const Icon(Icons.book, size: 20)),
                                                ),
                                              ),
                                            )
                                          ),
                                          DataCell(Text(book.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                          DataCell(Text(isbnDisplay)),
                                          DataCell(Text(book.author)),
                                          DataCell(Text(book.editorial)),
                                          DataCell(Text("\$${book.price.toStringAsFixed(2)}")),
                                          DataCell(Text(book.stock.toString())),
                                          DataCell(StatusBadge(text: statusText, color: statusColor)),
                                          DataCell(Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // ICONO DEL OJO (VER)
                                              IconButton(
                                                icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.grey), 
                                                onPressed: () => _showBookDetails(book)
                                              ),
                                              // ICONO DE LÁPIZ (EDITAR)
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), 
                                                onPressed: () => showDialog(context: context, builder: (_) => _BookFormDialog(book: book))
                                              ),
                                              // ICONO DE BORRAR
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey), 
                                                onPressed: () => FirebaseFirestore.instance.collection('books').doc(book.id).delete()
                                              ),
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
                                child: Text("Mostrando ${books.length} libros", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MODAL DE FORMULARIO (Agregado campo ISBN)
class _BookFormDialog extends StatefulWidget {
  final BookModel? book;
  const _BookFormDialog({Key? key, this.book}) : super(key: key);

  @override
  __BookFormDialogState createState() => __BookFormDialogState();
}

class __BookFormDialogState extends State<_BookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingData = true;

  late TextEditingController _titleCtrl;
  late TextEditingController _isbnCtrl; // <-- Controlador ISBN
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imageCtrl;

  List<String> _authors = [];
  List<Map<String, String>> _categories = []; 
  List<String> _editorials = [];

  String? _selectedAuthor;
  String? _selectedCategoryId;
  String? _selectedEditorial;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.book?.title ?? '');
    // Extraemos el ISBN si existe
    String currentIsbn = '';
    if (widget.book != null) {
      currentIsbn = widget.book!.toMap()['isbn']?.toString() ?? '';
    }
    _isbnCtrl = TextEditingController(text: currentIsbn);
    
    _priceCtrl = TextEditingController(text: widget.book?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: widget.book?.stock.toString() ?? '');
    _imageCtrl = TextEditingController(text: widget.book?.imageUrl ?? '');
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final authSnap = await FirebaseFirestore.instance.collection('authors').orderBy('name').get();
      final catSnap = await FirebaseFirestore.instance.collection('categories').orderBy('name').get();
      final editSnap = await FirebaseFirestore.instance.collection('editorials').orderBy('name').get();

      setState(() {
        _authors = authSnap.docs.map((doc) => doc['name'].toString()).toList();
        _editorials = editSnap.docs.map((doc) => doc['name'].toString()).toList();
        _categories = catSnap.docs.map((doc) => {'id': doc.id, 'name': doc['name'].toString()}).toList();

        if (widget.book != null) {
          if (_authors.contains(widget.book!.author)) _selectedAuthor = widget.book!.author;
          if (_editorials.contains(widget.book!.editorial)) _selectedEditorial = widget.book!.editorial;
          
          final catExists = _categories.any((c) => c['id'] == widget.book!.categoryId || c['name'] == widget.book!.categoryId);
          if (catExists) {
            _selectedCategoryId = _categories.firstWhere((c) => c['id'] == widget.book!.categoryId || c['name'] == widget.book!.categoryId)['id'];
          }
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));

    return AlertDialog(
      title: Text(widget.book == null ? "Nuevo Libro" : "Editar Libro"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Título del libro"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              
              // --- CAMPO ISBN ---
              TextFormField(
                controller: _isbnCtrl,
                decoration: const InputDecoration(labelText: "ISBN"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _selectedAuthor,
                decoration: const InputDecoration(labelText: "Autor Principal"),
                items: _authors.map((author) => DropdownMenuItem(value: author, child: Text(author))).toList(),
                onChanged: (val) => setState(() => _selectedAuthor = val),
                validator: (v) => v == null ? "Seleccione un autor" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: "Categoría Literaria"),
                items: _categories.map((cat) => DropdownMenuItem(value: cat['id'], child: Text(cat['name']!))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (v) => v == null ? "Seleccione una categoría" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedEditorial,
                decoration: const InputDecoration(labelText: "Editorial"),
                items: _editorials.map((edit) => DropdownMenuItem(value: edit, child: Text(edit))).toList(),
                onChanged: (val) => setState(() => _selectedEditorial = val),
                validator: (v) => v == null ? "Seleccione una editorial" : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: "Precio (MXN)"),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: "Stock"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: "URL Imagen de Portada"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final data = {
                'title': _titleCtrl.text.trim(),
                'author': _selectedAuthor,
                'editorial': _selectedEditorial,
                'categoryId': _selectedCategoryId,
                'price': double.tryParse(_priceCtrl.text) ?? 0.0,
                'stock': int.tryParse(_stockCtrl.text) ?? 0,
                'imageUrl': _imageCtrl.text.trim(),
                'year': widget.book?.year ?? DateTime.now().year, 
                'isbn': _isbnCtrl.text.trim(), // Guardamos el ISBN
              };
              
              if (widget.book == null) {
                await FirebaseFirestore.instance.collection('books').add(data);
              } else {
                await FirebaseFirestore.instance.collection('books').doc(widget.book!.id).update(data);
              }
              Navigator.pop(context);
            }
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}