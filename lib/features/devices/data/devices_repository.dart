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
    DeviceModel(id: 'm1', brandId: 'b1', brandName: 'Apple', name: 'iPhone 11'),
    DeviceModel(id: 'm2', brandId: 'b1', brandName: 'Apple', name: 'iPhone 12'),
    DeviceModel(id: 'm3', brandId: 'b1', brandName: 'Apple', name: 'iPhone 13'),
    DeviceModel(id: 'm4', brandId: 'b1', brandName: 'Apple', name: 'iPhone 14'),
    DeviceModel(id: 'm5', brandId: 'b2', brandName: 'Samsung', name: 'Galaxy S22 Ultra'),
  ];

  final List<CustomerDevice> _localDevices = [
    CustomerDevice(
      id: 'd1',
      customerId: 'c1111111-1111-1111-1111-111111111111',
      customerName: 'Mariana Souza',
      brandName: 'Apple',
      modelName: 'iPhone 13',
      color: 'Azul',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
  ];

  DevicesRepository(this._dio);

  Future<List<Brand>> getBrands({int pagina = 1, int tamanho = 50, String? search}) async {
    try {
      final Map<String, dynamic> params = {
        'Pagina': pagina,
        'Tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['Search'] = search;

      final res = await _dio.get(ApiEndpoints.brands, queryParameters: params);
      final data = res.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['itens'] != null) {
        items = data['itens'] as List<dynamic>;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      }

      final list = items.map((b) => Brand.fromJson(b as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _defaultBrands;
    } catch (_) {
      return _defaultBrands;
    }
  }

  Future<List<DeviceModel>> getModels({String? brandId}) async {
    if (brandId != null) {
      return _defaultModels.where((m) => m.brandId == brandId).toList();
    }
    return _defaultModels;
  }

  Future<List<CustomerDevice>> getCustomerDevices({String? customerId, String? search, int pagina = 1, int tamanho = 100}) async {
    try {
      final Map<String, dynamic> params = {
        'Pagina': pagina,
        'Tamanho': tamanho,
      };
      if (customerId != null) params['clienteId'] = customerId;
      if (search != null && search.isNotEmpty) params['Search'] = search;

      final res = await _dio.get(
        ApiEndpoints.devices,
        queryParameters: params,
      );

      final data = res.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['itens'] != null) {
        items = data['itens'] as List<dynamic>;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      }

      final list = items.map((d) => CustomerDevice.fromJson(d as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _localDevices;
    } catch (_) {
      return _localDevices.where((d) {
        if (customerId != null && d.customerId != customerId) return false;
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          return d.modelName.toLowerCase().contains(q) || d.brandName.toLowerCase().contains(q);
        }
        return true;
      }).toList();
    }
  }

  Future<CustomerDevice> saveDevice(CustomerDevice device) async {
    try {
      if (device.id.isEmpty) {
        final res = await _dio.post(ApiEndpoints.devices, data: device.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return CustomerDevice.fromJson(res.data as Map<String, dynamic>);
        }
        return device;
      } else {
        final res = await _dio.put('${ApiEndpoints.devices}/${device.id}', data: device.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return CustomerDevice.fromJson(res.data as Map<String, dynamic>);
        }
        return device;
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

  Future<void> deleteDevice(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.devices}/$id');
    } catch (_) {
      _localDevices.removeWhere((d) => d.id == id);
    }
  }
}
