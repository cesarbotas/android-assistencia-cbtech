import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/product.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ProductsRepository(dio);
});

class ProductsRepository {
  final Dio _dio;
  final _uuid = const Uuid();

  final List<Product> _localProducts = [
    Product(
      id: 'p1',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sku: 'TEL-IP13-OLED',
      name: 'Tela Display OLED iPhone 13',
      category: 'Telas',
      description: 'Módulo frontal completo original importado OLED com aro.',
      compatibleModels: 'Apple iPhone 13 / iPhone 13 Pro',
      salePrice: 450.00,
      costPrice: 220.00,
      currentStock: 2,
      minStock: 3,
      supplierName: 'iParts Especialista Apple',
      supplierPartCode: 'IP-DS-13',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Product(
      id: 'p2',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sku: 'BAT-IP13-ORIG',
      name: 'Bateria Original iPhone 13',
      category: 'Baterias',
      description: 'Célula de alta capacidade 3227mAh com flex.',
      compatibleModels: 'Apple iPhone 13',
      salePrice: 180.00,
      costPrice: 85.00,
      currentStock: 1,
      minStock: 2,
      supplierName: 'iParts Especialista Apple',
      supplierPartCode: 'IP-BAT-13',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Product(
      id: 'p3',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sku: 'SUB-S22U-USBC',
      name: 'Conector de Carga Galaxy S22 Ultra',
      category: 'Conectores',
      description: 'Sub-placa de conector Tipo C com microfone integrado e flex.',
      compatibleModels: 'Samsung Galaxy S22 Ultra (SM-S908)',
      salePrice: 120.00,
      costPrice: 45.00,
      currentStock: 5,
      minStock: 2,
      supplierName: 'TotalCell Distribuidora',
      supplierPartCode: 'TC-S22U-SUB',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Product(
      id: 'p4',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sku: 'BAT-MOT-E30F',
      name: 'Bateria Motorola Edge 30 Fusion',
      category: 'Baterias',
      description: 'Bateria 4400mAh modelo NH40 original.',
      compatibleModels: 'Motorola Edge 30 Fusion',
      salePrice: 130.00,
      costPrice: 60.00,
      currentStock: 4,
      minStock: 2,
      supplierName: 'MegaPeças Express',
      supplierPartCode: 'MP-NH40',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Product(
      id: 'p5',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sku: 'TEL-RED-N12',
      name: 'Módulo Frontal Redmi Note 12',
      category: 'Telas',
      description: 'Display AMOLED 120Hz com touch.',
      compatibleModels: 'Xiaomi Redmi Note 12 4G / 5G',
      salePrice: 210.00,
      costPrice: 95.00,
      currentStock: 6,
      minStock: 3,
      supplierName: 'TotalCell Distribuidora',
      supplierPartCode: 'TC-RN12-AMOLED',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  ProductsRepository(this._dio);

  Future<List<Product>> getProducts({String? search, String? category, bool? lowStockOnly}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null) params['search'] = search;
      if (category != null) params['category'] = category;
      if (lowStockOnly != null) params['lowStockOnly'] = lowStockOnly;

      final res = await _dio.get(
        ApiEndpoints.products,
        queryParameters: params,
      );
      return (res.data as List).map((p) => Product.fromJson(p)).toList();
    } catch (_) {
      return _localProducts.where((p) {
        if (category != null && category != 'Todas' && p.category != category) {
          return false;
        }
        if (lowStockOnly == true && !p.isLowStock) {
          return false;
        }
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          final mSku = p.sku.toLowerCase().contains(q);
          final mName = p.name.toLowerCase().contains(q);
          final mCompat = p.compatibleModels.toLowerCase().contains(q);
          return mSku || mName || mCompat;
        }
        return true;
      }).toList();
    }
  }

  Future<Product> saveProduct(Product product) async {
    try {
      if (product.id.isEmpty) {
        final res = await _dio.post(ApiEndpoints.products, data: product.toJson());
        return Product.fromJson(res.data);
      } else {
        final res = await _dio.put('${ApiEndpoints.products}/${product.id}', data: product.toJson());
        return Product.fromJson(res.data);
      }
    } catch (_) {
      if (product.id.isEmpty) {
        final newProd = product.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
        _localProducts.insert(0, newProd);
        return newProd;
      } else {
        final idx = _localProducts.indexWhere((p) => p.id == product.id);
        if (idx != -1) _localProducts[idx] = product;
        return product;
      }
    }
  }

  Future<void> updateProductStock(String id, int newStock) async {
    try {
      await _dio.patch('${ApiEndpoints.products}/$id/stock', data: {'stock': newStock});
    } catch (_) {}
    final idx = _localProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _localProducts[idx] = _localProducts[idx].copyWith(currentStock: newStock);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.products}/$id');
    } catch (_) {
      _localProducts.removeWhere((p) => p.id == id);
    }
  }
}
