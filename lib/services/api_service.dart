import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String baseUrl =
      'https://eemi-886dbcc67fb5.herokuapp.com/products';

  /// Récupère une liste paginée de produits, avec support de recherche
  Future<Map<String, dynamic>> fetchProducts({
    String? searchQuery,
    int page = 1,
  }) async {
    final int limit = 30;

    final queryParameters = <String, String>{'page': page.toString()};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParameters['search'] = searchQuery;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('rows') &&
          decoded['rows'] is List) {
        final List<Product> products =
            (decoded['rows'] as List)
                .map((data) => Product.fromJson(data))
                .toList();
        final int count = decoded['count'] ?? products.length;
        return {
          'products': products,
          'count': count,
          'hasMore': (page * limit) < count,
        };
      } else if (decoded is List) {
        final List<Product> products =
            decoded.map((data) => Product.fromJson(data)).toList();
        return {
          'products': products,
          'count': products.length,
          'hasMore': false,
        };
      } else {
        throw Exception('Réponse inattendue: ${response.body}');
      }
    } else {
      throw Exception(
        'Erreur ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  /// Récupère un produit par son ID
  Future<Product> getProductById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is Map && jsonData.containsKey('data')) {
        return Product.fromJson(jsonData['data']);
      } else {
        return Product.fromJson(jsonData);
      }
    } else {
      throw Exception('Échec de chargement du produit: ${response.statusCode}');
    }
  }

  /// Crée un nouveau produit
  Future<bool> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'image': product.image,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  /// Met à jour un produit existant
  Future<bool> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'image': product.image,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }

  /// Supprime un produit par son ID
  Future<bool> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }

  /// Récupère tous les produits (non paginés)
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map<Product>((e) => Product.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('rows')) {
        return (data['rows'] as List)
            .map<Product>((e) => Product.fromJson(e))
            .toList();
      } else {
        throw Exception('Format de réponse inattendu');
      }
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  // Chercher un produit
  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://eemi-886dbcc67fb5.herokuapp.com/products?search=$query',
      ),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la recherche des produits');
    }
  }
}
