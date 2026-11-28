import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/service_item.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ServicesRepository(dio);
});

class ServicesRepository {
  final Dio _dio;
  final _uuid = const Uuid();

  final List<ServiceItem> _localServices = [
    ServiceItem(
      id: 'srv1',
      name: 'Troca de Módulo Frontal / Display',
      categoryServiceId: '11111111-1111-1111-1111-111111111111',
      description: 'Substituição completa do display, teste de toque e calibração.',
      defaultPrice: 150.00,
      estimatedTimeMinutes: 90,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    ServiceItem(
      id: 'srv2',
      name: 'Substituição de Bateria',
      categoryServiceId: '11111111-1111-1111-1111-111111111111',
      description: 'Troca de célula de bateria com vedação contra poeira e teste de ciclo.',
      defaultPrice: 90.00,
      estimatedTimeMinutes: 45,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    ServiceItem(
      id: 'srv3',
      name: 'Desoxidação em Banho Ultrassônico',
      categoryServiceId: '33333333-3333-3333-3333-333333333333',
      description: 'Tratamento de aparelho após queda na água com álcool isopropílico.',
      defaultPrice: 180.00,
      estimatedTimeMinutes: 240,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
    ServiceItem(
      id: 'srv4',
      name: 'Reparo Avançado em Placa / Micro solda',
      categoryServiceId: '22222222-2222-2222-2222-222222222222',
      description: 'Diagnóstico de curto, reballing e substituição de CI de carga.',
      defaultPrice: 320.00,
      estimatedTimeMinutes: 360,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    ServiceItem(
      id: 'srv5',
      name: 'Troca de Conector de Carga (Sub-placa)',
      categoryServiceId: '11111111-1111-1111-1111-111111111111',
      description: 'Substituição da porta USB-C / Lightning com testes de corrente.',
      defaultPrice: 110.00,
      estimatedTimeMinutes: 60,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  ServicesRepository(this._dio);

  Future<List<Map<String, String>>> getServiceCategories() async {
    try {
      final res = await _dio.get(ApiEndpoints.serviceCategories);
      final data = res.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['itens'] != null) {
        items = data['itens'] as List<dynamic>;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      }
      final list = items.map((c) => {'id': c['id'].toString(), 'name': c['nome'].toString()}).toList();
      if (list.isNotEmpty) return list;
      return _defaultServiceCategories();
    } catch (_) {
      return _defaultServiceCategories();
    }
  }

  List<Map<String, String>> _defaultServiceCategories() => [
        {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Troca de Peça'},
        {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Reparo em Placa'},
        {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Limpeza/Banho'},
        {'id': '44444444-4444-4444-4444-444444444444', 'name': 'Software/Reset'},
        {'id': '55555555-5555-5555-5555-555555555555', 'name': 'Outros'},
      ];

  Future<List<ServiceItem>> getServices({String? search, int pagina = 1, int tamanho = 100}) async {
    try {
      final Map<String, dynamic> params = {
        'pagina': pagina,
        'tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;

      final res = await _dio.get(
        ApiEndpoints.services,
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
      } else if (data is Map && data['data'] != null) {
        items = data['data'] as List<dynamic>;
      }

      final list = items.map((s) => ServiceItem.fromJson(s as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _localServices;
    } catch (_) {
      return _localServices.where((s) {
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          final mName = s.name.toLowerCase().contains(q);
          final mDesc = s.description?.toLowerCase().contains(q) ?? false;
          return mName || mDesc;
        }
        return true;
      }).toList();
    }
  }

  Future<ServiceItem> saveService(ServiceItem service) async {
    try {
      if (service.id.isEmpty) {
        final res = await _dio.post(ApiEndpoints.services, data: service.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return ServiceItem.fromJson(res.data as Map<String, dynamic>);
        }
        return service;
      } else {
        final res = await _dio.put('${ApiEndpoints.services}/${service.id}', data: service.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return ServiceItem.fromJson(res.data as Map<String, dynamic>);
        }
        return service;
      }
    } catch (_) {
      if (service.id.isEmpty) {
        final newSrv = service.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
        _localServices.insert(0, newSrv);
        return newSrv;
      } else {
        final idx = _localServices.indexWhere((s) => s.id == service.id);
        if (idx != -1) _localServices[idx] = service;
        return service;
      }
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.services}/$id');
    } catch (_) {
      _localServices.removeWhere((s) => s.id == id);
    }
  }
}
