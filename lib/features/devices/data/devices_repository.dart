import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/brand.dart';
import 'models/device_model.dart';
import 'models/customer_device.dart';

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return DevicesRepository(dio);
});

class DevicesRepository {
  final Dio _dio;
  final _uuid = const Uuid();

  final List<Brand> _defaultBrands = [
    Brand(id: 'b1', name: 'Apple'),
    Brand(id: 'b2', name: 'Samsung'),
    Brand(id: 'b3', name: 'Motorola'),
    Brand(id: 'b4', name: 'Xiaomi'),
    Brand(id: 'b5', name: 'Redmi'),
    Brand(id: 'b6', name: 'Poco'),
    Brand(id: 'b7', name: 'Asus'),
    Brand(id: 'b8', name: 'Realme'),
    Brand(id: 'b9', name: 'Outros Fabricantes'),
  ];

  final List<DeviceModel> _defaultModels = [
    // Apple
    DeviceModel(id: 'm1', brandId: 'b1', brandName: 'Apple', name: 'iPhone 11'),
    DeviceModel(id: 'm2', brandId: 'b1', brandName: 'Apple', name: 'iPhone 12'),
    DeviceModel(id: 'm3', brandId: 'b1', brandName: 'Apple', name: 'iPhone 13'),
    DeviceModel(id: 'm4', brandId: 'b1', brandName: 'Apple', name: 'iPhone 13 Pro Max'),
    DeviceModel(id: 'm5', brandId: 'b1', brandName: 'Apple', name: 'iPhone 14'),
    DeviceModel(id: 'm6', brandId: 'b1', brandName: 'Apple', name: 'iPhone 15'),
    // Samsung
    DeviceModel(id: 'm7', brandId: 'b2', brandName: 'Samsung', name: 'Galaxy A14'),
    DeviceModel(id: 'm8', brandId: 'b2', brandName: 'Samsung', name: 'Galaxy A54 5G'),
    DeviceModel(id: 'm9', brandId: 'b2', brandName: 'Samsung', name: 'Galaxy S21 FE'),
    DeviceModel(id: 'm10', brandId: 'b2', brandName: 'Samsung', name: 'Galaxy S22 Ultra'),
    DeviceModel(id: 'm11', brandId: 'b2', brandName: 'Samsung', name: 'Galaxy S23'),
    // Motorola
    DeviceModel(id: 'm12', brandId: 'b3', brandName: 'Motorola', name: 'Moto G52'),
    DeviceModel(id: 'm13', brandId: 'b3', brandName: 'Motorola', name: 'Moto G84'),
    DeviceModel(id: 'm14', brandId: 'b3', brandName: 'Motorola', name: 'Edge 30 Fusion'),
    DeviceModel(id: 'm15', brandId: 'b3', brandName: 'Motorola', name: 'Edge 40 Neo'),
    // Xiaomi
    DeviceModel(id: 'm16', brandId: 'b4', brandName: 'Xiaomi', name: 'Xiaomi 12'),
    DeviceModel(id: 'm17', brandId: 'b5', brandName: 'Redmi', name: 'Redmi Note 12'),
    DeviceModel(id: 'm18', brandId: 'b5', brandName: 'Redmi', name: 'Redmi Note 13 Pro'),
    DeviceModel(id: 'm19', brandId: 'b6', brandName: 'Poco', name: 'Poco X5 Pro'),
    DeviceModel(id: 'm20', brandId: 'b6', brandName: 'Poco', name: 'Poco F5'),
  ];

  final List<CustomerDevice> _localDevices = [
    CustomerDevice(
      id: 'd1',
      tenantId: '11111111-1111-1111-1111-111111111111',
      customerId: 'c1111111-1111-1111-1111-111111111111',
      customerName: 'Mariana Souza',
      brandName: 'Apple',
      modelName: 'iPhone 13',
      imei1: '356891092384712',
      color: 'Azul',
      storage: '128 GB',
      notes: 'Bateria com saúde em 78%',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    CustomerDevice(
      id: 'd2',
      tenantId: '11111111-1111-1111-1111-111111111111',
      customerId: 'c2222222-2222-2222-2222-222222222222',
      customerName: 'Carlos Eduardo Silva',
      brandName: 'Samsung',
      modelName: 'Galaxy S22 Ultra',
      imei1: '354910293817462',
      color: 'Preto Fantasma',
      storage: '256 GB',
      notes: 'S-Pen inclusa',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    CustomerDevice(
      id: 'd3',
      tenantId: '11111111-1111-1111-1111-111111111111',
      customerId: 'c3333333-3333-3333-3333-333333333333',
      customerName: 'Fernanda Lima',
      brandName: 'Motorola',
      modelName: 'Edge 30 Fusion',
      imei1: '351928374650192',
      color: 'Dourado',
      storage: '128 GB',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    CustomerDevice(
      id: 'd4',
      tenantId: '11111111-1111-1111-1111-111111111111',
      customerId: 'c4444444-4444-4444-4444-444444444444',
      customerName: 'Rodrigo Menezes',
      brandName: 'Redmi',
      modelName: 'Redmi Note 12',
      imei1: '358291048273615',
      color: 'Azul Gelo',
      storage: '128 GB',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  DevicesRepository(this._dio);

  Future<List<Brand>> getBrands() async {
    try {
      final res = await _dio.get(ApiEndpoints.brands);
      return (res.data as List).map((b) => Brand.fromJson(b)).toList();
    } catch (_) {
      return _defaultBrands;
    }
  }

  Future<List<DeviceModel>> getModels({String? brandId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (brandId != null) params['brandId'] = brandId;

      final res = await _dio.get(
        ApiEndpoints.models,
        queryParameters: params,
      );
      return (res.data as List).map((m) => DeviceModel.fromJson(m)).toList();
    } catch (_) {
      if (brandId != null) {
        return _defaultModels.where((m) => m.brandId == brandId).toList();
      }
      return _defaultModels;
    }
  }

  Future<List<CustomerDevice>> getCustomerDevices({String? customerId, String? search}) async {
    try {
      final Map<String, dynamic> params = {};
      if (customerId != null) params['customerId'] = customerId;
      if (search != null) params['search'] = search;

      final res = await _dio.get(
        ApiEndpoints.devices,
        queryParameters: params,
      );
      return (res.data as List).map((d) => CustomerDevice.fromJson(d)).toList();
    } catch (_) {
      return _localDevices.where((d) {
        if (customerId != null && d.customerId != customerId) return false;
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
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

  Future<CustomerDevice> saveDevice(CustomerDevice device) async {
    try {
      if (device.id.isEmpty) {
        final res = await _dio.post(ApiEndpoints.devices, data: device.toJson());
        return CustomerDevice.fromJson(res.data);
      } else {
        final res = await _dio.put('${ApiEndpoints.devices}/${device.id}', data: device.toJson());
        return CustomerDevice.fromJson(res.data);
      }
    } catch (_) {
      if (device.id.isEmpty) {
        final newDev = device.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
        _localDevices.insert(0, newDev);
        return newDev;
      } else {
        final idx = _localDevices.indexWhere((d) => d.id == device.id);
        if (idx != -1) _localDevices[idx] = device;
        return device;
      }
    }
  }
}
