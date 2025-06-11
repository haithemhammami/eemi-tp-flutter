import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCardItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        leading: Image.network(
          product.image,
          width: 50,
          height: 50,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
        ),
        title: Text(product.name),
        subtitle: Text('${product.price.toStringAsFixed(2)} €'),
      ),
    );
  }
}
