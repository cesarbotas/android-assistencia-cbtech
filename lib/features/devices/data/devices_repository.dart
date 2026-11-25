import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/brand.dart';
import 'models/device_model.dart';
import 'models/customer_device.dart';

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return DevicesRepository(dio);
});

class DevicesRepository {
  final Dio _dio;

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

      return items.map((b) => Brand.fromJson(b as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao carregar marcas da API.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
    }
  }

  Future<List<DeviceModel>> getModels({String? brandId}) async {
    // Modelos podem ser gerenciados localmente ou via API de modelos
    return [];
  }

  Future<List<CustomerDevice>> getCustomerDevices({String? customerId, String? search, int pagina = 1, int tamanho = 10}) async {
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

      return items.map((d) => CustomerDevice.fromJson(d as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao carregar aparelhos da API.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
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
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao salvar aparelho na API.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteDevice(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.devices}/$id');
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.response?.data?['title'] ?? 'Erro ao excluir aparelho na API.';
      throw ApiException(message: message.toString(), statusCode: e.response?.statusCode);
    }
  }
}
