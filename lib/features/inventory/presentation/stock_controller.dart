import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/purchase_order.dart';
import '../data/models/stock_movement.dart';
import '../data/stock_repository.dart';
import 'products_controller.dart';

class StockState {
  final List<StockMovement> movements;
  final List<PurchaseOrder> purchaseOrders;
  final bool isLoading;
  final String? errorMessage;
  final StockMovementType? selectedType;
  final String? selectedProductId;

  StockState({
    this.movements = const [],
    this.purchaseOrders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType,
    this.selectedProductId,
  });

  StockState copyWith({
    List<StockMovement>? movements,
    List<PurchaseOrder>? purchaseOrders,
    bool? isLoading,
    String? errorMessage,
    StockMovementType? selectedType,
    bool clearType = false,
    String? selectedProductId,
    bool clearProduct = false,
  }) {
    return StockState(
      movements: movements ?? this.movements,
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedProductId: clearProduct ? null : (selectedProductId ?? this.selectedProductId),
    );
  }

  List<StockMovement> get filteredMovements {
    return movements.where((m) {
      if (selectedType != null && m.type != selectedType) return false;
      if (selectedProductId != null && m.productId != selectedProductId) return false;
      return true;
    }).toList();
  }
}

final stockControllerProvider = StateNotifierProvider<StockController, StockState>((ref) {
  final repo = ref.watch(stockRepositoryProvider);
  return StockController(repo, ref);
});

class StockController extends StateNotifier<StockState> {
  final StockRepository _repo;
  final Ref _ref;

  StockController(this._repo, this._ref) : super(StockState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final movs = await _repo.getMovements();
      final pos = await _repo.getPurchaseOrders();
      state = state.copyWith(movements: movs, purchaseOrders: pos, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setTypeFilter(StockMovementType? type) {
    if (type == null) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  void setProductFilter(String? productId) {
    if (productId == null) {
      state = state.copyWith(clearProduct: true);
    } else {
      state = state.copyWith(selectedProductId: productId);
    }
  }

  Future<bool> recordMovement(StockMovement movement) async {
    try {
      final recorded = await _repo.recordMovement(movement);
      state = state.copyWith(movements: [recorded, ...state.movements]);
      // Atualiza também a lista geral de produtos
      await _ref.read(productsControllerProvider.notifier).loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> createPurchaseOrder(PurchaseOrder order) async {
    try {
      final created = await _repo.createPurchaseOrder(order);
      state = state.copyWith(purchaseOrders: [created, ...state.purchaseOrders]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> receivePurchaseOrder(String orderId) async {
    try {
      final updated = await _repo.receivePurchaseOrder(orderId);
      final list = List<PurchaseOrder>.from(state.purchaseOrders);
      final idx = list.indexWhere((o) => o.id == orderId);
      if (idx != -1) list[idx] = updated;

      // Recarrega movimentações geradas e produtos atualizados
      final newMovements = await _repo.getMovements();
      state = state.copyWith(purchaseOrders: list, movements: newMovements);
      await _ref.read(productsControllerProvider.notifier).loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
