import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_form_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    /// Page d’accueil : Liste des produits
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    /// Formulaire pour créer un nouveau produit
    GoRoute(
      path: '/product/create',
      name: 'product_create',
      builder: (context, state) => const ProductFormScreen(),
    ),

    /// Détail d’un produit existant
    GoRoute(
      path: '/product/:id',
      name: 'product_detail',
      builder: (context, state) {
        final productId = state.pathParameters['id'];
        if (productId == null) {
          return const Scaffold(
            body: Center(child: Text('Produit introuvable')),
          );
        }
        return ProductDetailScreen(productId: productId);
      },
    ),

    /// Formulaire d’édition d’un produit existant
    GoRoute(
      path: '/product/:id/edit',
      name: 'product_edit',
      builder: (context, state) {
        final productId = state.pathParameters['id'];
        if (productId == null) {
          return const Scaffold(
            body: Center(child: Text('Produit introuvable')),
          );
        }
        return ProductFormScreen(
          productId: productId,
          isEditing: true,
        );
      },
    ),
  ],
);
