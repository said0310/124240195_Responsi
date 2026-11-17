class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final String thumbnail;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.thumbnail,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return Product(
      id: parseInt(json['id']),
      title: json['title']?.toString() ?? 'Produk tanpa nama',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Lainnya',
      brand: json['brand']?.toString() ?? 'Tidak diketahui',
      thumbnail: json['thumbnail']?.toString() ?? '',
      price: parseDouble(json['price']),
      discountPercentage: parseDouble(json['discountPercentage']),
      rating: parseDouble(json['rating']),
      stock: parseInt(json['stock']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'brand': brand,
    'thumbnail': thumbnail,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
  };
}
