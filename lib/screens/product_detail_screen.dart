import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../components/loading_indicator.dart';
import '../components/error_message.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ApiService().getProductById(widget.productId);
  }

  void _navigateToEdit() {
    context.goNamed('product_edit', pathParameters: {'id': widget.productId});
  }

  void _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Voulez-vous supprimer ce produit ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await ApiService().deleteProduct(widget.productId);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit supprimé')),
          );
          context.goNamed('home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la suppression')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
        title: const Text('Détail du produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorMessage(message: 'Erreur de chargement');
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Produit introuvable'));
          }

          final product = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Image.network(
                  product.image,
                  height: 200,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                ),
                const SizedBox(height: 20),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                if (product.description != null)
                  Text(
                    product.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
