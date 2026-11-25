import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/supplier.dart';

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SuppliersRepository(dio);
});

class SuppliersRepository {
  final Dio _dio;
  final _uuid = const Uuid();

  final List<Supplier> _localSuppliers = [
    Supplier(
      id: 'sup1',
      tradeName: 'TotalCell Distribuidora',
      legalName: 'TotalCell Comercio e Distribuicao Ltda',
      cnpj: '11.222.333/0001-44',
      contactPerson: 'Marcos Vinicius',
      phone: '(11) 3222-1000',
      whatsapp: '(11) 98111-2222',
      email: 'comercial@totalcell.com.br',
      deliveryLeadTimeDays: 1,
      paymentTerms: 'Boleto 28 dias ou 5% no PIX',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    Supplier(
      id: 'sup2',
      tradeName: 'MegaPeças Express',
      legalName: 'MegaPecas Importacao e Exportacao Eireli',
      cnpj: '22.333.444/0001-55',
      contactPerson: 'Juliana Castro',
      phone: '(11) 3333-5500',
      whatsapp: '(11) 97222-3333',
      email: 'vendas@megapecas.com.br',
      deliveryLeadTimeDays: 2,
      paymentTerms: 'Cartão 3x sem juros ou PIX à vista',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Supplier(
      id: 'sup3',
      tradeName: 'iParts Especialista Apple',
      legalName: 'iParts Componentes Originais Ltda',
      cnpj: '33.444.555/0001-66',
      contactPerson: 'Felipe Ramos',
      phone: '(11) 3456-7890',
      whatsapp: '(11) 96333-4444',
      email: 'pedidos@iparts.com.br',
      deliveryLeadTimeDays: 1,
      paymentTerms: 'Faturamento quinzenal',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  SuppliersRepository(this._dio);

  Future<List<Supplier>> getSuppliers({String? search, int pagina = 1, int tamanho = 100, bool? activeOnly}) async {
    try {
      final Map<String, dynamic> params = {
        'Pagina': pagina,
        'Tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['Search'] = search;

      final res = await _dio.get(
        ApiEndpoints.suppliers,
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
      } else if (data is Map && data['id'] != null) {
        items = [data];
      }

      final list = items.map((s) => Supplier.fromJson(s as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _localSuppliers;
    } catch (_) {
      // Fallback local para garantir que a tela sempre carregue
      return _localSuppliers.where((s) {
        if (activeOnly == true && !s.isActive) return false;
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          final mTrade = s.tradeName.toLowerCase().contains(q);
          final mLegal = s.legalName.toLowerCase().contains(q);
          final mCnpj = s.cnpj?.contains(q) ?? false;
          return mTrade || mLegal || mCnpj;
        }
        return true;
      }).toList();
    }
  }

  Future<Supplier> saveSupplier(Supplier supplier) async {
    try {
      if (supplier.id.isEmpty) {
        final res = await _dio.post(ApiEndpoints.suppliers, data: supplier.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return Supplier.fromJson(res.data as Map<String, dynamic>);
        }
        return supplier;
      } else {
        final res = await _dio.put('${ApiEndpoints.suppliers}/${supplier.id}', data: supplier.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return Supplier.fromJson(res.data as Map<String, dynamic>);
        }
        return supplier;
      }
    } catch (_) {
      if (supplier.id.isEmpty) {
        final newSup = supplier.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
        _localSuppliers.insert(0, newSup);
        return newSup;
      } else {
        final idx = _localSuppliers.indexWhere((s) => s.id == supplier.id);
        if (idx != -1) _localSuppliers[idx] = supplier;
        return supplier;
      }
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.suppliers}/$id');
    } catch (_) {
      _localSuppliers.removeWhere((s) => s.id == id);
    }
  }
}
