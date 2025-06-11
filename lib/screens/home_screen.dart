import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../components/loading_indicator.dart';
import '../components/error_message.dart';
import '../components/product_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    _productsFuture = ApiService().getAllProducts();
  }

  void _goToCreateProduct() {
    context.goNamed('product_create');
  }

  void _goToProductDetail(Product product) {
    context.goNamed('product_detail', pathParameters: {'id': product.id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _goToCreateProduct,
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorMessage(message: 'Erreur de chargement des produits');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit disponible'));
          } else {
            final products = snapshot.data!;
            return ProductListView(
              products: products,
              onProductTap: _goToProductDetail,
            );
          }
        },
      ),
    );
  }
}
