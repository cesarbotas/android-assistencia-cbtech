import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/service_item.dart';
import '../data/services_repository.dart';

class ServicesState {
  final List<ServiceItem> services;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory;

  ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'Todas',
  });

  ServicesState copyWith({
    List<ServiceItem>? services,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<ServiceItem> get filteredServices {
    return services.where((s) {
      if (selectedCategory != 'Todas' && s.category != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final mName = s.name.toLowerCase().contains(q);
        final mDesc = s.description?.toLowerCase().contains(q) ?? false;
        return mName || mDesc;
      }
      return true;
    }).toList();
  }
}

final servicesControllerProvider =
    StateNotifierProvider<ServicesController, ServicesState>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  return ServicesController(repo);
});

class ServicesController extends StateNotifier<ServicesState> {
  final ServicesRepository _repo;

  ServicesController(this._repo) : super(ServicesState()) {
    loadServices();
  }

  Future<void> loadServices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getServices();
      state = state.copyWith(services: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setCategory(String cat) {
    state = state.copyWith(selectedCategory: cat);
  }

  Future<bool> saveService(ServiceItem service) async {
    try {
      final saved = await _repo.saveService(service);
      final idx = state.services.indexWhere((s) => s.id == saved.id);
      List<ServiceItem> updated;
      if (idx != -1) {
        updated = List.from(state.services)..[idx] = saved;
      } else {
        updated = [saved, ...state.services];
      }
      state = state.copyWith(services: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _repo.deleteService(id);
      state = state.copyWith(
        services: state.services.where((s) => s.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
