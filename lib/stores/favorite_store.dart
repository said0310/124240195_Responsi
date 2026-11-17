import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class FavoriteStore extends ChangeNotifier {
  static final FavoriteStore instance = FavoriteStore._internal();
  FavoriteStore._internal();

  int? _userId;
  final List<Product> _favorites = [];

  List<Product> get favorites => List.unmodifiable(_favorites);

  String get _storageKey => _userId != null
      ? 'product_favorites_$_userId'
      : 'product_favorites_default';

  Future<void> init(int? userId) async {
    _userId = userId;
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];

    for (final item in list) {
      try {
        final map = json.decode(item) as Map<String, dynamic>;
        _favorites.add(Product.fromJson(map));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    notifyListeners();
  }

  bool isFavorite(int productId) {
    return _favorites.any((product) => product.id == productId);
  }

  Future<bool> toggleFavorite(Product product) async {
    final index = _favorites.indexWhere((item) => item.id == product.id);
    final bool added;

    if (index >= 0) {
      _favorites.removeAt(index);
      added = false;
    } else {
      _favorites.add(product);
      added = true;
    }

    await _persist();
    notifyListeners();
    return added;
  }

  Future<void> removeFavorite(int productId) async {
    _favorites.removeWhere((product) => product.id == productId);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = _favorites.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_storageKey, stringList);
  }
}
