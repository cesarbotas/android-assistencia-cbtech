import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/purchase_order.dart';
import 'models/stock_movement.dart';
import 'products_repository.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final productsRepo = ref.watch(productsRepositoryProvider);
  return StockRepository(dio, productsRepo);
});

class StockRepository {
  final Dio _dio;
  final ProductsRepository _productsRepo;
  final _uuid = const Uuid();
  int _lastPurchaseOrderNumber = 101;

  final List<StockMovement> _localMovements = [
    StockMovement(
      id: 'mov-1',
      tenantId: '11111111-1111-1111-1111-111111111111',
      productId: 'p1',
      productName: 'Tela Display OLED iPhone 13',
      productSku: 'TEL-IP13-OLED',
      type: StockMovementType.compra,
      quantity: 5,
      unitCost: 220.00,
      totalValue: 1100.00,
      previousStock: 0,
      newStock: 5,
      reason: 'Recebimento do Pedido de Compra PC-0100',
      supplierName: 'iParts Especialista Apple',
      createdBy: 'Carlos Almoxarife',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    StockMovement(
      id: 'mov-2',
      tenantId: '11111111-1111-1111-1111-111111111111',
      productId: 'p1',
      productName: 'Tela Display OLED iPhone 13',
      productSku: 'TEL-IP13-OLED',
      type: StockMovementType.baixaOs,
      quantity: 1,
      unitCost: 220.00,
      totalValue: 220.00,
      previousStock: 5,
      newStock: 4,
      reason: 'Substituição em bancada',
      workOrderId: 'wo-1',
      workOrderNumber: 'OS-0104',
      createdBy: 'Lucas Lima (Técnico)',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    StockMovement(
      id: 'mov-3',
      tenantId: '11111111-1111-1111-1111-111111111111',
      productId: 'p2',
      productName: 'Bateria Original iPhone 13',
      productSku: 'BAT-IP13-ORIG',
      type: StockMovementType.baixaOs,
      quantity: 1,
      unitCost: 85.00,
      totalValue: 85.00,
      previousStock: 2,
      newStock: 1,
      reason: 'Substituição preventiva por degradação',
      workOrderId: 'wo-1',
      workOrderNumber: 'OS-0104',
      createdBy: 'Lucas Lima (Técnico)',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    StockMovement(
      id: 'mov-4',
      tenantId: '11111111-1111-1111-1111-111111111111',
      productId: 'p3',
      productName: 'Conector de Carga Galaxy S22 Ultra',
      productSku: 'SUB-S22U-USBC',
      type: StockMovementType.compra,
      quantity: 6,
      unitCost: 45.00,
      totalValue: 270.00,
      previousStock: 0,
      newStock: 6,
      reason: 'Reposição de estoque crítico',
      supplierName: 'TotalCell Distribuidora',
      createdBy: 'Carlos Almoxarife',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  final List<PurchaseOrder> _localPurchaseOrders = [
    PurchaseOrder(
      id: 'po-1',
      tenantId: '11111111-1111-1111-1111-111111111111',
      orderNumber: 'PC-0100',
      supplierId: 's1',
      supplierName: 'iParts Especialista Apple',
      status: PurchaseOrderStatus.recebido,
      createdAt: DateTime.now().subtract(const Duration(days: 16)),
      receivedAt: DateTime.now().subtract(const Duration(days: 15)),
      notes: 'Entrega rápida via transportadora expressa.',
      items: [
        PurchaseOrderItem(
          id: 'poi-1',
          productId: 'p1',
          productName: 'Tela Display OLED iPhone 13',
          productSku: 'TEL-IP13-OLED',
          quantity: 5,
          unitCost: 220.00,
        ),
      ],
    ),
    PurchaseOrder(
      id: 'po-2',
      tenantId: '11111111-1111-1111-1111-111111111111',
      orderNumber: 'PC-0101',
      supplierId: 's2',
      supplierName: 'TotalCell Distribuidora',
      status: PurchaseOrderStatus.emitido,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
      notes: 'Pedido urgente de reposição de displays e baterias Xiaomi.',
      items: [
        PurchaseOrderItem(
          id: 'poi-2',
          productId: 'p5',
          productName: 'Módulo Frontal Redmi Note 12',
          productSku: 'TEL-RED-N12',
          quantity: 4,
          unitCost: 95.00,
        ),
        PurchaseOrderItem(
          id: 'poi-3',
          productId: 'p2',
          productName: 'Bateria Original iPhone 13',
          productSku: 'BAT-IP13-ORIG',
          quantity: 3,
          unitCost: 85.00,
        ),
      ],
    ),
  ];

  StockRepository(this._dio, this._productsRepo);

  Future<List<StockMovement>> getMovements({String? productId, StockMovementType? type}) async {
    try {
      final Map<String, dynamic> params = {};
      if (productId != null) params['productId'] = productId;
      if (type != null) params['type'] = type.name;

      final res = await _dio.get(ApiEndpoints.stockMovements, queryParameters: params);
      return (res.data as List).map((m) => StockMovement.fromJson(m)).toList();
    } catch (_) {
      return _localMovements.where((m) {
        if (productId != null && m.productId != productId) return false;
        if (type != null && m.type != type) return false;
        return true;
      }).toList();
    }
  }

  Future<StockMovement> recordMovement(StockMovement movement) async {
    // Busca dados atualizados do produto para calcular estoque
    final allProducts = await _productsRepo.getProducts();
    final product = allProducts.firstWhere(
      (p) => p.id == movement.productId,
      orElse: () => throw Exception('Produto não encontrado para movimentação.'),
    );

    int calculatedNewStock;
    if (movement.type == StockMovementType.ajuste) {
      calculatedNewStock = movement.newStock;
    } else if (movement.type.isEntry) {
      calculatedNewStock = product.currentStock + movement.quantity;
    } else {
      if (product.currentStock < movement.quantity) {
        throw Exception('Estoque insuficiente! Saldo atual: ${product.currentStock}');
      }
      calculatedNewStock = product.currentStock - movement.quantity;
    }

    final id = movement.id.isNotEmpty ? movement.id : _uuid.v4();
    final processed = StockMovement(
      id: id,
      tenantId: movement.tenantId,
      productId: movement.productId,
      productName: movement.productName,
      productSku: movement.productSku,
      type: movement.type,
      quantity: movement.quantity,
      unitCost: movement.unitCost > 0 ? movement.unitCost : product.costPrice,
      totalValue: movement.quantity * (movement.unitCost > 0 ? movement.unitCost : product.costPrice),
      previousStock: product.currentStock,
      newStock: calculatedNewStock,
      reason: movement.reason,
      workOrderId: movement.workOrderId,
      workOrderNumber: movement.workOrderNumber,
      supplierId: movement.supplierId,
      supplierName: movement.supplierName,
      createdBy: movement.createdBy,
      createdAt: DateTime.now(),
    );

    try {
      final res = await _dio.post(ApiEndpoints.stockMovements, data: processed.toJson());
      final saved = StockMovement.fromJson(res.data);
      await _productsRepo.updateProductStock(movement.productId, calculatedNewStock);
      _localMovements.insert(0, saved);
      return saved;
    } catch (_) {
      await _productsRepo.updateProductStock(movement.productId, calculatedNewStock);
      _localMovements.insert(0, processed);
      return processed;
    }
  }

  Future<List<PurchaseOrder>> getPurchaseOrders({PurchaseOrderStatus? status}) async {
    try {
      final Map<String, dynamic> params = {};
      if (status != null) params['status'] = status.name;

      final res = await _dio.get(ApiEndpoints.purchaseOrders, queryParameters: params);
      return (res.data as List).map((o) => PurchaseOrder.fromJson(o)).toList();
    } catch (_) {
      return _localPurchaseOrders.where((po) {
        if (status != null && po.status != status) return false;
        return true;
      }).toList();
    }
  }

  Future<PurchaseOrder> createPurchaseOrder(PurchaseOrder order) async {
    _lastPurchaseOrderNumber++;
    final orderNum = 'PC-0${_lastPurchaseOrderNumber.toString().padLeft(3, '0')}';
    final id = order.id.isNotEmpty ? order.id : _uuid.v4();

    final created = order.copyWith(
      id: id,
      orderNumber: orderNum,
      createdAt: DateTime.now(),
      status: PurchaseOrderStatus.emitido,
    );

    try {
      final res = await _dio.post(ApiEndpoints.purchaseOrders, data: created.toJson());
      final saved = PurchaseOrder.fromJson(res.data);
      _localPurchaseOrders.insert(0, saved);
      return saved;
    } catch (_) {
      _localPurchaseOrders.insert(0, created);
      return created;
    }
  }

  Future<PurchaseOrder> receivePurchaseOrder(String orderId) async {
    final idx = _localPurchaseOrders.indexWhere((p) => p.id == orderId);
    if (idx == -1) throw Exception('Pedido de compra não encontrado.');

    final currentOrder = _localPurchaseOrders[idx];
    if (currentOrder.status == PurchaseOrderStatus.recebido) {
      return currentOrder;
    }

    final receivedOrder = currentOrder.copyWith(
      status: PurchaseOrderStatus.recebido,
      receivedAt: DateTime.now(),
    );

    // Gera movimentação de estoque para cada item
    for (final item in currentOrder.items) {
      final mov = StockMovement(
        id: _uuid.v4(),
        tenantId: currentOrder.tenantId,
        productId: item.productId,
        productName: item.productName,
        productSku: item.productSku,
        type: StockMovementType.compra,
        quantity: item.quantity,
        unitCost: item.unitCost,
        totalValue: item.subtotal,
        previousStock: 0,
        newStock: 0,
        reason: 'Recebimento de Mercadoria ${currentOrder.orderNumber}',
        supplierId: currentOrder.supplierId,
        supplierName: currentOrder.supplierName,
        createdAt: DateTime.now(),
      );
      await recordMovement(mov);
    }

    try {
      final res = await _dio.put('${ApiEndpoints.purchaseOrders}/$orderId/receive');
      final updated = PurchaseOrder.fromJson(res.data);
      _localPurchaseOrders[idx] = updated;
      return updated;
    } catch (_) {
      _localPurchaseOrders[idx] = receivedOrder;
      return receivedOrder;
    }
  }
}
