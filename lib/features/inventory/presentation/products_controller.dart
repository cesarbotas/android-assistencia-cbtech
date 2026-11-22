import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../data/products_repository.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory; // 'Todas', 'Telas', 'Baterias', 'Conectores', etc.
  final bool lowStockOnly;

  ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'Todas',
    this.lowStockOnly = false,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool? lowStockOnly,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
    );
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      if (selectedCategory != 'Todas' && p.category != selectedCategory) {
        return false;
      }
      if (lowStockOnly && !p.isLowStock) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final mSku = p.sku.toLowerCase().contains(q);
        final mName = p.name.toLowerCase().contains(q);
        final mCompat = p.compatibleModels.toLowerCase().contains(q);
        return mSku || mName || mCompat;
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
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getProducts();
      state = state.copyWith(products: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleLowStockOnly() {
    state = state.copyWith(lowStockOnly: !state.lowStockOnly);
  }

  Future<bool> saveProduct(Product product) async {
    try {
      final saved = await _repo.saveProduct(product);
      final idx = state.products.indexWhere((p) => p.id == saved.id);
      List<Product> updated;
      if (idx != -1) {
        updated = List.from(state.products)..[idx] = saved;
      } else {
        updated = [saved, ...state.products];
      }
      state = state.copyWith(products: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
