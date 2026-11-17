import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductResponse {
  final List<Product> products;
  final bool hasNext;

  const ProductResponse({required this.products, required this.hasNext});
}

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';
  static const int _pageSize = 20;
  static const Duration timeoutDuration = Duration(seconds: 10);

  static Future<ProductResponse> getProducts({
    int page = 1,
    String? query,
    String? category,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final skip = (safePage - 1) * _pageSize;
    final searchQuery = query?.trim() ?? '';
    final selectedCategory = category?.trim() ?? '';
    final endpoint = selectedCategory.isNotEmpty
        ? '$baseUrl/category/${Uri.encodeComponent(selectedCategory)}'
        : searchQuery.isEmpty
        ? baseUrl
        : '$baseUrl/search';
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'limit': _pageSize.toString(),
        'skip': skip.toString(),
        if (searchQuery.isNotEmpty) 'q': searchQuery,
      },
    );

    final data = await _getJson(uri);
    final rawProducts = data['products'];
    if (rawProducts is! List) {
      throw const FormatException(
        'Format daftar produk dari server tidak valid.',
      );
    }

    final products = rawProducts
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    final total = data['total'] is num ? (data['total'] as num).toInt() : 0;

    return ProductResponse(
      products: products,
      hasNext: skip + products.length < total,
    );
  }

  static Future<List<String>> getCategories() async {
    final decoded = await _getJsonValue(Uri.parse('$baseUrl/category-list'));
    if (decoded is! List) {
      throw const FormatException(
        'Format daftar kategori dari server tidak valid.',
      );
    }

    return decoded.map((category) {
      if (category is! String || category.trim().isEmpty) {
        throw const FormatException(
          'Server mengirim kategori dengan format tidak valid.',
        );
      }
      return category;
    }).toList();
  }

  static Future<Product> getProductDetail(int id) async {
    final data = await _getJson(
      Uri.parse('$baseUrl/$id'),
      notFoundMessage: 'Produk tidak ditemukan ($id).',
    );
    return Product.fromJson(data);
  }

  static Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    String? notFoundMessage,
  }) async {
    final decoded = await _getJsonValue(uri, notFoundMessage: notFoundMessage);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format data dari server tidak valid.');
    }
    return decoded;
  }

  static Future<dynamic> _getJsonValue(
    Uri uri, {
    String? notFoundMessage,
  }) async {
    try {
      final response = await http.get(uri).timeout(timeoutDuration);
      if (response.statusCode == 404 && notFoundMessage != null) {
        throw Exception(notFoundMessage);
      }
      if (response.statusCode != 200) {
        throw Exception(
          'Server mengembalikan kode status: ${response.statusCode}',
        );
      }

      return json.decode(response.body);
    } on http.ClientException {
      throw Exception(
        'Gagal terhubung ke jaringan. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      throw Exception('Koneksi timeout. Silakan coba beberapa saat lagi.');
    }
  }
}
