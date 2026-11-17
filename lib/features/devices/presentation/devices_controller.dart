import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/devices_repository.dart';
import '../data/models/brand.dart';
import '../data/models/device_model.dart';
import '../data/models/customer_device.dart';

class DevicesState {
  final List<CustomerDevice> devices;
  final List<Brand> brands;
  final List<DeviceModel> models;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedBrandFilter;

  DevicesState({
    this.devices = const [],
    this.brands = const [],
    this.models = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedBrandFilter,
  });

  DevicesState copyWith({
    List<CustomerDevice>? devices,
    List<Brand>? brands,
    List<DeviceModel>? models,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedBrandFilter,
    bool clearBrandFilter = false,
  }) {
    return DevicesState(
      devices: devices ?? this.devices,
      brands: brands ?? this.brands,
      models: models ?? this.models,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBrandFilter: clearBrandFilter ? null : (selectedBrandFilter ?? this.selectedBrandFilter),
    );
  }

  List<CustomerDevice> get filteredDevices {
    return devices.where((d) {
      if (selectedBrandFilter != null && d.brandName != selectedBrandFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final mModel = d.modelName.toLowerCase().contains(q);
        final mBrand = d.brandName.toLowerCase().contains(q);
        final mClient = d.customerName.toLowerCase().contains(q);
        final mImei = d.imei1?.contains(q) ?? false;
        return mModel || mBrand || mClient || mImei;
      }
      return true;
    }).toList();
  }
}

final devicesControllerProvider =
    StateNotifierProvider<DevicesController, DevicesState>((ref) {
  final repo = ref.watch(devicesRepositoryProvider);
  return DevicesController(repo);
});

class DevicesController extends StateNotifier<DevicesState> {
  final DevicesRepository _repo;

  DevicesController(this._repo) : super(DevicesState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final brands = await _repo.getBrands();
      final devices = await _repo.getCustomerDevices();
      state = state.copyWith(
        brands: brands,
        devices: devices,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<List<DeviceModel>> getModelsForBrand(String brandId) async {
    return await _repo.getModels(brandId: brandId);
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setBrandFilter(String? brand) {
    if (brand == null) {
      state = state.copyWith(clearBrandFilter: true);
    } else {
      state = state.copyWith(selectedBrandFilter: brand);
    }
  }

  Future<bool> saveDevice(CustomerDevice device) async {
    try {
      final saved = await _repo.saveDevice(device);
      final idx = state.devices.indexWhere((d) => d.id == saved.id);
      List<CustomerDevice> updated;
      if (idx != -1) {
        updated = List.from(state.devices)..[idx] = saved;
      } else {
        updated = [saved, ...state.devices];
      }
      state = state.copyWith(devices: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
