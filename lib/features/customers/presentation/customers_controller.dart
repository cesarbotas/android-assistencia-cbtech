import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customers_repository.dart';
import '../data/models/customer.dart';

class CustomersState {
  final List<Customer> customers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final String? errorMessage;
  final String searchQuery;
  final String filter; // 'Todos', 'Ativos', 'Inativos'

  CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.pageSize = 10,
    this.errorMessage,
    this.searchQuery = '',
    this.filter = 'Todos',
  });

  CustomersState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    String? errorMessage,
    String? searchQuery,
    String? filter,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  List<Customer> get filteredCustomers {
    return customers.where((c) {
      if (filter == 'Ativos' && !c.isActive) return false;
      if (filter == 'Inativos' && c.isActive) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchPhone = c.phone.contains(q);
        final matchCpf = c.cpfCnpj?.contains(q) ?? false;
        return matchName || matchPhone || matchCpf;
      }
      return true;
    }).toList();
  }
}

final customersControllerProvider =
    StateNotifierProvider<CustomersController, CustomersState>((ref) {
  final repo = ref.watch(customersRepositoryProvider);
  return CustomersController(repo);
});

class CustomersController extends StateNotifier<CustomersState> {
  final CustomersRepository _repo;

  CustomersController(this._repo) : super(CustomersState()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null, currentPage: 1, hasMore: true);
    try {
      final list = await _repo.getCustomers(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        pagina: 1,
        tamanho: state.pageSize,
      );
      state = state.copyWith(
        customers: list,
        isLoading: false,
        hasMore: list.length >= state.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final list = await _repo.getCustomers(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        pagina: nextPage,
        tamanho: state.pageSize,
      );
      state = state.copyWith(
        customers: [...state.customers, ...list],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: list.length >= state.pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadCustomers();
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<bool> saveCustomer(Customer customer) async {
    try {
      await _repo.saveCustomer(customer);
      // Recarrega imediatamente a lista direto da API
      await loadCustomers();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repo.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
