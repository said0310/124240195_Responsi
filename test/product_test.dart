import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/models/product.dart';

void main() {
  test('parses a DummyJSON product payload', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'The product description',
      'category': 'beauty',
      'brand': 'Essence',
      'thumbnail': 'https://example.com/product.webp',
      'price': 9.99,
      'discountPercentage': 10.48,
      'rating': 2.56,
      'stock': 99,
    });

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.category, 'beauty');
    expect(product.price, 9.99);
    expect(product.stock, 99);
    expect(product.toJson()['title'], product.title);
  });

  test('uses safe defaults for missing optional product fields', () {
    final product = Product.fromJson({'id': '2'});

    expect(product.id, 2);
    expect(product.title, 'Produk tanpa nama');
    expect(product.thumbnail, isEmpty);
    expect(product.price, 0);
    expect(product.stock, 0);
  });
}
