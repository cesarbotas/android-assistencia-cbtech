import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customers_repository.dart';
import '../data/models/customer.dart';

class CustomersState {
  final List<Customer> customers;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String filter; // 'Todos', 'Ativos', 'Inativos'

  CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filter = 'Todos',
  });

  CustomersState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? filter,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getCustomers(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(customers: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<bool> saveCustomer(Customer customer) async {
    try {
      final saved = await _repo.saveCustomer(customer);
      final index = state.customers.indexWhere((c) => c.id == saved.id);
      List<Customer> updatedList;
      if (index != -1) {
        updatedList = List.from(state.customers)..[index] = saved;
      } else {
        updatedList = [saved, ...state.customers];
      }
      state = state.copyWith(customers: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repo.deleteCustomer(id);
      state = state.copyWith(
        customers: state.customers.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
