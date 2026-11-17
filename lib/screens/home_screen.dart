import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../stores/favorite_store.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  final List<Product> _products = [];
  int _currentPage = 1;
  bool _hasNext = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<String> _categories = [];
  String? _selectedCategory;
  String? _categoryError;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _fetchProducts(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingInitial && !_isLoadingMore && _hasNext) {
        _fetchProducts(loadMore: true);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_selectedCategory != null) {
      setState(() {
        _selectedCategory = null;
      });
    } else {
      setState(() {});
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchProducts(reset: true);
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoryError = null;
    });

    try {
      final categories = await ApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
        _categoryError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onCategoryChanged(String? category) {
    if (_selectedCategory == category) return;

    _debounceTimer?.cancel();
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
    _fetchProducts(reset: true);
  }

  List<String> get _visibleCategories => _categories;

  Future<void> _showCategories() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pilih kategori',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('All Categories'),
                      selected: _selectedCategory == null,
                      trailing: _selectedCategory == null
                          ? const Icon(Icons.check, color: AppColors.teal)
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _onCategoryChanged(null);
                      },
                    ),
                    ..._visibleCategories.map(
                      (category) => ListTile(
                        title: Text(category),
                        selected: _selectedCategory == category,
                        trailing: _selectedCategory == category
                            ? const Icon(Icons.check, color: AppColors.teal)
                            : null,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _onCategoryChanged(category);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchProducts({
    bool reset = false,
    bool loadMore = false,
  }) async {
    if (reset) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
        _currentPage = 1;
        _products.clear();
      });
    } else if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final pageToFetch = reset ? 1 : _currentPage;

    try {
      final response = await ApiService.getProducts(
        page: pageToFetch,
        query: _searchController.text,
        category: _selectedCategory,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          _products.clear();
        }
        _products.addAll(response.products);
        _hasNext = response.hasNext;
        _currentPage = pageToFetch + 1;
        _isLoadingInitial = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _isLoadingMore = false;
        if (reset) {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.gray,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: AppColors.navy),
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _selectedCategory = null;
                              _fetchProducts(reset: true);
                            },
                          )
                        : null,
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoadingCategories)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.teal,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Memuat kategori...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else if (_categoryError != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Gagal memuat kategori: $_categoryError',
                        style: const TextStyle(
                          color: AppColors.dead,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadCategories,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                )
              else
                OutlinedButton(
                  onPressed: _showCategories,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedCategory == null
                              ? 'All Categories'
                              : _selectedCategory!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.teal,
            onRefresh: () => _fetchProducts(reset: true),
            child: _buildBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () => _fetchProducts(reset: true),
      );
    }

    if (_products.isEmpty) {
      return const EmptyView(
        icon: Icons.search_off_rounded,
        title: 'Produk tidak ditemukan',
        subtitle: 'Coba kata kunci pencarian yang lain.',
      );
    }

    return ListenableBuilder(
      listenable: FavoriteStore.instance,
      builder: (context, _) {
        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _products.length + (_hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _products.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              );
            }

            final product = _products[index];
            final isFavorite = FavoriteStore.instance.isFavorite(product.id);

            return ProductCard(
              product: product,
              isFav: isFavorite,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(productId: product.id),
                  ),
                );
              },
              onFav: () async {
                final added = await FavoriteStore.instance.toggleFavorite(
                  product,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? '${product.title} ditambahkan ke whislist'
                            : '${product.title} dihapus dari whislist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
