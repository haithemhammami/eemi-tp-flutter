import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card_item.dart';

class ProductListView extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const ProductListView({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) {
        return ProductCardItem(
          product: products[index],
          onTap: () => onProductTap(products[index]),
        );
      },
    );
  }
}
