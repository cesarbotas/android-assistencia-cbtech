import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customers/data/customers_repository.dart';
import '../../devices/data/devices_repository.dart';
import '../data/models/budget.dart';
import '../data/models/work_order.dart';
import '../data/models/work_order_status.dart';
import '../data/work_orders_repository.dart';

class WorkOrdersState {
  final List<WorkOrder> workOrders;
  final WorkOrder? selectedWorkOrder;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final WorkOrderStatus? statusFilter;

  WorkOrdersState({
    this.workOrders = const [],
    this.selectedWorkOrder,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.statusFilter,
  });

  WorkOrdersState copyWith({
    List<WorkOrder>? workOrders,
    WorkOrder? selectedWorkOrder,
    bool clearSelected = false,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    WorkOrderStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return WorkOrdersState(
      workOrders: workOrders ?? this.workOrders,
      selectedWorkOrder: clearSelected ? null : (selectedWorkOrder ?? this.selectedWorkOrder),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }

  List<WorkOrder> get filteredWorkOrders {
    return workOrders.where((wo) {
      if (statusFilter != null && wo.status != statusFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final mNum = wo.sequentialNumber.toLowerCase().contains(q);
        final mCli = wo.customerName.toLowerCase().contains(q);
        final mDev = '${wo.deviceBrand} ${wo.deviceModel}'.toLowerCase().contains(q);
        final mDef = wo.defectReported.toLowerCase().contains(q);
        return mNum || mCli || mDev || mDef;
      }
      return true;
    }).toList();
  }
}

final workOrdersControllerProvider =
    StateNotifierProvider<WorkOrdersController, WorkOrdersState>((ref) {
  final repo = ref.watch(workOrdersRepositoryProvider);
  final custRepo = ref.watch(customersRepositoryProvider);
  final devRepo = ref.watch(devicesRepositoryProvider);
  return WorkOrdersController(repo, custRepo, devRepo);
});

class WorkOrdersController extends StateNotifier<WorkOrdersState> {
  final WorkOrdersRepository _repo;
  final CustomersRepository _custRepo;
  final DevicesRepository _devRepo;

  WorkOrdersController(this._repo, this._custRepo, this._devRepo) : super(WorkOrdersState()) {
    loadWorkOrders();
  }

  Future<void> loadWorkOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getWorkOrders(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.statusFilter,
      );
      state = state.copyWith(workOrders: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setStatusFilter(WorkOrderStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  void setSelectedWorkOrder(WorkOrder wo) {
    state = state.copyWith(selectedWorkOrder: wo, isLoading: false);
  }

  Future<void> selectWorkOrder(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final fetchedWo = await _repo.getWorkOrderById(id);
      if (fetchedWo != null) {
        // Exibe a Ordem de Serviço imediatamente na tela sem travar no loader!
        state = state.copyWith(selectedWorkOrder: fetchedWo, isLoading: false);

        // Busca o nome do cliente e do aparelho em segundo plano sem bloquear a UI
        _enrichWorkOrderInBackground(fetchedWo);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> _enrichWorkOrderInBackground(WorkOrder wo) async {
    try {
      var current = wo;
      if (current.customerId.isNotEmpty && (current.customerName == 'Cliente' || current.customerName.contains('Cliente (ID:'))) {
        try {
          final customers = await _custRepo.getCustomers(tamanho: 100);
          final match = customers.where((c) => c.id == current.customerId).firstOrNull;
          if (match != null) {
            current = current.copyWith(customerName: match.name, customerPhone: match.phone);
          }
        } catch (_) {}
      }
      if (current.deviceId != null && current.deviceId!.isNotEmpty && (current.deviceModel == 'Aparelho' || current.deviceModel.contains('Aparelho (ID:'))) {
        try {
          final devices = await _devRepo.getCustomerDevices(tamanho: 100);
          final matchDev = devices.where((d) => d.id == current.deviceId).firstOrNull;
          if (matchDev != null) {
            current = current.copyWith(
              deviceBrand: matchDev.brandName,
              deviceModel: matchDev.modelName,
              deviceColor: matchDev.color,
              deviceImei: matchDev.imei1,
            );
          }
        } catch (_) {}
      }
      state = state.copyWith(selectedWorkOrder: current);
    } catch (_) {}
  }

  Future<bool> createWorkOrder(WorkOrder order) async {
    try {
      final created = await _repo.createWorkOrder(order);
      state = state.copyWith(workOrders: [created, ...state.workOrders]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateWorkOrder(WorkOrder order) async {
    try {
      final updated = await _repo.updateWorkOrder(order);
      _updateLocalList(updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String id, WorkOrderStatus newStatus, {String? note}) async {
    try {
      final updated = await _repo.updateStatus(id, newStatus, note: note);
      _updateLocalList(updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateDiagnosis(String id, String diagnosis) async {
    try {
      final updated = await _repo.updateDiagnosis(id, diagnosis);
      _updateLocalList(updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> saveBudgetRevision(String id, Budget budget) async {
    try {
      final updated = await _repo.saveBudgetRevision(id, budget);
      _updateLocalList(updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> approveBudget(String id, String approvedBy) async {
    try {
      final updated = await _repo.approveBudget(id, approvedBy: approvedBy);
      _updateLocalList(updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectBudget(String id, String reason) async {
    try {
      final updated = await _repo.rejectBudget(id, reason: reason);
      _updateLocalList(updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void _updateLocalList(WorkOrder updated) {
    final idx = state.workOrders.indexWhere((o) => o.id == updated.id);
    if (idx != -1) {
      final list = List<WorkOrder>.from(state.workOrders)..[idx] = updated;
      state = state.copyWith(
        workOrders: list,
        selectedWorkOrder: state.selectedWorkOrder?.id == updated.id ? updated : state.selectedWorkOrder,
      );
    }
  }
}
