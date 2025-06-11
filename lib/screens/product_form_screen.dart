import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../components/app_submit_button.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final bool isEditing;

  const ProductFormScreen({
    super.key,
    this.productId,
    this.isEditing = false,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.productId != null) {
      _loadProductData(widget.productId!);
    }
  }

  void _loadProductData(String id) async {
    setState(() => _isLoading = true);
    final product = await ApiService().getProductById(id);
    _nameController.text = product.name;
    _descController.text = product.description ?? '';
    _priceController.text = product.price.toString();
    _imageController.text = product.image;
    setState(() => _isLoading = false);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final product = Product(
      id: widget.productId ?? '',
      name: _nameController.text.trim(),
      description:
          _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      image: _imageController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (widget.isEditing) {
      success = await ApiService().updateProduct(widget.productId!, product);
    } else {
      success = await ApiService().createProduct(product);
    }

    if (context.mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Produit modifié' : 'Produit ajouté',
            ),
          ),
        );
        context.goNamed('home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l’envoi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Modifier produit' : 'Nouveau produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Champ requis'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Prix'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champ requis';
                          }
                          // Remplace la virgule par un point pour le parsing
                          final priceText = value.trim().replaceAll(',', '.');
                          final price = double.tryParse(priceText);
                          if (price == null) {
                            return 'Le prix doit être un nombre (ex: 10, 10.5 ou 10,5)';
                          }
                          if (price < 0) {
                            return 'Le prix doit être positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL de l’image',
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Champ requis'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      AppSubmitButton(
                        text: widget.isEditing ? 'Modifier' : 'Ajouter',
                        isLoading: _isLoading,
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
