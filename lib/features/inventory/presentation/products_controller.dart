import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category.dart';
import '../data/models/product.dart';
import '../data/products_repository.dart';

class ProductsState {
  final List<Product> products;
  final List<Category> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory; // 'Todas' ou ID da Categoria
  final bool lowStockOnly;

  ProductsState({
    this.products = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.pageSize = 20,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'Todas',
    this.lowStockOnly = false,
  });

  ProductsState copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool? lowStockOnly,
  }) {
    return ProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
    );
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      if (selectedCategory != 'Todas' && p.categoryId != selectedCategory) {
        return false;
      }
      if (lowStockOnly && !p.isLowStock) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final mSku = p.sku.toLowerCase().contains(q);
        final mName = p.name.toLowerCase().contains(q);
        return mSku || mName;
      }
      return true;
    }).toList();
  }
}

final productsControllerProvider =
    StateNotifierProvider<ProductsController, ProductsState>((ref) {
  final repo = ref.watch(productsRepositoryProvider);
  return ProductsController(repo);
});

class ProductsController extends StateNotifier<ProductsState> {
  final ProductsRepository _repo;

  ProductsController(this._repo) : super(ProductsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null, currentPage: 1, hasMore: true);
    try {
      final categories = await _repo.getCategories();
      final products = await _repo.getProducts(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        categoriaId: state.selectedCategory != 'Todas' ? state.selectedCategory : null,
        pagina: 1,
        tamanho: state.pageSize,
      );
      state = state.copyWith(
        categories: categories,
        products: products,
        isLoading: false,
        hasMore: products.length >= state.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadProducts() async => loadAll();

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final list = await _repo.getProducts(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        categoriaId: state.selectedCategory != 'Todas' ? state.selectedCategory : null,
        pagina: nextPage,
        tamanho: state.pageSize,
      );
      state = state.copyWith(
        products: [...state.products, ...list],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: list.length >= state.pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
    loadAll();
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadAll();
  }

  void toggleLowStockOnly() {
    state = state.copyWith(lowStockOnly: !state.lowStockOnly);
  }

  Future<bool> saveProduct(Product product) async {
    try {
      await _repo.saveProduct(product);
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
      await loadAll();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
