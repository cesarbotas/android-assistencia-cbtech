import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/category.dart';
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
      sku: 'TEL-IP13-OLED',
      name: 'Tela Display OLED iPhone 13',
      categoryId: 'cat1',
      supplierId: 'sup3',
      salePrice: 450.00,
      costPrice: 220.00,
      currentStock: 2,
      minStock: 3,
      unit: 'UN',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Product(
      id: 'p2',
      sku: 'BAT-IP13-ORIG',
      name: 'Bateria Original iPhone 13',
      categoryId: 'cat2',
      supplierId: 'sup3',
      salePrice: 180.00,
      costPrice: 85.00,
      currentStock: 1,
      minStock: 2,
      unit: 'UN',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Product(
      id: 'p3',
      sku: 'SUB-S22U-USBC',
      name: 'Conector de Carga Galaxy S22 Ultra',
      categoryId: 'cat3',
      supplierId: 'sup1',
      salePrice: 120.00,
      costPrice: 45.00,
      currentStock: 5,
      minStock: 2,
      unit: 'UN',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  List<Category> _defaultCategories() => [
        Category(id: 'cat1', name: 'Telas', description: 'Displays e vidros'),
        Category(id: 'cat2', name: 'Baterias', description: 'Baterias e células'),
        Category(id: 'cat3', name: 'Conectores', description: 'Sub-placas e flex de carga'),
        Category(id: 'cat4', name: 'Câmeras', description: 'Câmeras frontal e traseira'),
        Category(id: 'cat5', name: 'Placas', description: 'Placas principais'),
        Category(id: 'cat6', name: 'Acessórios', description: 'Cabos e carregadores'),
      ];

  ProductsRepository(this._dio);

  Future<List<Category>> getCategories({int pagina = 1, int tamanho = 100, String? search}) async {
    try {
      final Map<String, dynamic> params = {
        'pagina': pagina,
        'tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;

      final res = await _dio.get(ApiEndpoints.categories, queryParameters: params);
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

      final list = items.map((c) => Category.fromJson(c as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _defaultCategories();
    } catch (_) {
      return _defaultCategories();
    }
  }

  Future<List<Product>> getProducts({String? search, String? categoriaId, String? fornecedorId, int pagina = 1, int tamanho = 100}) async {
    try {
      final Map<String, dynamic> params = {
        'pagina': pagina,
        'tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoriaId != null && categoriaId.isNotEmpty) params['categoriaId'] = categoriaId;
      if (fornecedorId != null && fornecedorId.isNotEmpty) params['fornecedorId'] = fornecedorId;

      final res = await _dio.get(
        ApiEndpoints.products,
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

      final list = items.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _localProducts;
    } catch (_) {
      return _localProducts.where((p) {
        if (categoriaId != null && categoriaId.isNotEmpty && p.categoryId != categoriaId) {
          return false;
        }
        if (fornecedorId != null && fornecedorId.isNotEmpty && p.supplierId != fornecedorId) {
          return false;
        }
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          final mSku = p.sku.toLowerCase().contains(q);
          final mName = p.name.toLowerCase().contains(q);
          return mSku || mName;
        }
        return true;
      }).toList();
    }
  }

  Future<Product> saveProduct(Product product) async {
    try {
      if (product.id.isEmpty) {
        final res = await _dio.post(ApiEndpoints.products, data: product.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return Product.fromJson(res.data as Map<String, dynamic>);
        }
        return product;
      } else {
        final res = await _dio.put('${ApiEndpoints.products}/${product.id}', data: product.toJson());
        if (res.data is Map<String, dynamic> && res.data['id'] != null) {
          return Product.fromJson(res.data as Map<String, dynamic>);
        }
        return product;
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
