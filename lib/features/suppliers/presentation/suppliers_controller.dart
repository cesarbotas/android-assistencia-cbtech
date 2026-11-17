import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/supplier.dart';
import '../data/suppliers_repository.dart';

class SuppliersState {
  final List<Supplier> suppliers;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  SuppliersState({
    this.suppliers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  SuppliersState copyWith({
    List<Supplier>? suppliers,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return SuppliersState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Supplier> get filteredSuppliers {
    if (searchQuery.isEmpty) return suppliers;
    final q = searchQuery.toLowerCase();
    return suppliers.where((s) {
      return s.tradeName.toLowerCase().contains(q) ||
          s.legalName.toLowerCase().contains(q) ||
          (s.cnpj?.contains(q) ?? false);
    }).toList();
  }
}

final suppliersControllerProvider =
    StateNotifierProvider<SuppliersController, SuppliersState>((ref) {
  final repo = ref.watch(suppliersRepositoryProvider);
  return SuppliersController(repo);
});

class SuppliersController extends StateNotifier<SuppliersState> {
  final SuppliersRepository _repo;

  SuppliersController(this._repo) : super(SuppliersState()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getSuppliers();
      state = state.copyWith(suppliers: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  Future<bool> saveSupplier(Supplier supplier) async {
    try {
      final saved = await _repo.saveSupplier(supplier);
      final idx = state.suppliers.indexWhere((s) => s.id == saved.id);
      List<Supplier> updated;
      if (idx != -1) {
        updated = List.from(state.suppliers)..[idx] = saved;
      } else {
        updated = [saved, ...state.suppliers];
      }
      state = state.copyWith(suppliers: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _repo.deleteSupplier(id);
      state = state.copyWith(
        suppliers: state.suppliers.where((s) => s.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
