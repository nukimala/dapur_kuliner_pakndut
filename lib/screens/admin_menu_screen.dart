import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final CollectionReference _menusCollection = FirebaseFirestore.instance.collection('menus');

  Future<void> _deleteMenu(String id) async {
    await _menusCollection.doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu deleted successfully')),
      );
    }
  }

  void _showMenuForm({MenuModel? menu}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MenuFormWidget(
          menu: menu,
          onSaved: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menus'),
        backgroundColor: const Color(0xFFff7e5f),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _menusCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return const Center(child: Text('No menus available, add some!'));
          }

          final menus = snapshot.data!.docs.map((doc) => MenuModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

          return ListView.builder(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: menu.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              menu.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.fastfood),
                            ),
                          )
                        : const Icon(Icons.fastfood),
                  ),
                  title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${menu.price.toStringAsFixed(0)} - ${menu.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showMenuForm(menu: menu),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(menu),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFff7e5f),
        onPressed: () => _showMenuForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${menu.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              if (menu.id != null) {
                _deleteMenu(menu.id!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class MenuFormWidget extends StatefulWidget {
  final MenuModel? menu;
  final VoidCallback onSaved;

  const MenuFormWidget({super.key, this.menu, required this.onSaved});

  @override
  State<MenuFormWidget> createState() => _MenuFormWidgetState();
}

class _MenuFormWidgetState extends State<MenuFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference _menusCollection = FirebaseFirestore.instance.collection('menus');

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  String _selectedCategory = 'Food';

  final List<String> _categories = ['Food', 'Drink', 'Snack', 'Dessert'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?.name ?? '');
    _descController = TextEditingController(text: widget.menu?.description ?? '');
    _priceController = TextEditingController(
        text: widget.menu?.price != null ? widget.menu!.price.toStringAsFixed(0) : '');
    _imageController = TextEditingController(text: widget.menu?.imageUrl ?? '');
    if (widget.menu != null && _categories.contains(widget.menu!.category)) {
      _selectedCategory = widget.menu!.category;
    }
  }

  void _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      final menuData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'imageUrl': _imageController.text.trim(),
        'category': _selectedCategory,
      };

      try {
        if (widget.menu == null || widget.menu!.id == null) {
          await _menusCollection.add(menuData);
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu added successfully')));
          }
        } else {
          await _menusCollection.doc(widget.menu!.id).update(menuData);
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu updated successfully')));
          }
        }
        widget.onSaved();
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.menu == null ? 'Add New Menu' : 'Edit Menu',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Menu Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (Rp)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Please enter a price';
                if (double.tryParse(v) == null) return 'Must be a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL (Optional)',
                border: OutlineInputBorder(),
                hintText: 'https://example.com/image.jpg',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFff7e5f)),
                onPressed: _saveMenu,
                child: const Text('Save Menu', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}

