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
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Troca de Módulo Frontal / Display',
      description: 'Substituição completa do display, teste de toque e calibração.',
      category: 'Troca de Peça',
      defaultPrice: 150.00,
      estimatedTimeMinutes: 90,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    ServiceItem(
      id: 'srv2',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Substituição de Bateria',
      description: 'Troca de célula de bateria com vedação contra poeira e teste de ciclo.',
      category: 'Troca de Peça',
      defaultPrice: 90.00,
      estimatedTimeMinutes: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    ServiceItem(
      id: 'srv3',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Desoxidação em Banho Ultrassônico',
      description: 'Tratamento de aparelho após queda na água com álcool isopropílico.',
      category: 'Limpeza/Banho',
      defaultPrice: 180.00,
      estimatedTimeMinutes: 240,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
    ServiceItem(
      id: 'srv4',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Reparo Avançado em Placa / Micro solda',
      description: 'Diagnóstico de curto, reballing e substituição de CI de carga (Tristar / Hydra).',
      category: 'Reparo em Placa',
      defaultPrice: 320.00,
      estimatedTimeMinutes: 360,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    ServiceItem(
      id: 'srv5',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Troca de Conector de Carga (Sub-placa)',
      description: 'Substituição da porta USB-C / Lightning com testes de corrente.',
      category: 'Troca de Peça',
      defaultPrice: 110.00,
      estimatedTimeMinutes: 60,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  ServicesRepository(this._dio);

  Future<List<ServiceItem>> getServices({String? search, String? category}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null) params['search'] = search;
      if (category != null) params['category'] = category;

      final res = await _dio.get(
        ApiEndpoints.services,
        queryParameters: params,
      );
      return (res.data as List).map((s) => ServiceItem.fromJson(s)).toList();
    } catch (_) {
      return _localServices.where((s) {
        if (category != null && category != 'Todas' && s.category != category) {
          return false;
        }
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
        return ServiceItem.fromJson(res.data);
      } else {
        final res = await _dio.put('${ApiEndpoints.services}/${service.id}', data: service.toJson());
        return ServiceItem.fromJson(res.data);
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
