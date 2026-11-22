import 'package:flutter/material.dart';

enum PurchaseOrderStatus {
  rascunho('Rascunho'),
  emitido('Emitido / Aguardando'),
  recebido('Recebido no Estoque'),
  cancelado('Cancelado');

  final String label;
  const PurchaseOrderStatus(this.label);

  Color get color {
    switch (this) {
      case PurchaseOrderStatus.rascunho:
        return Colors.grey;
      case PurchaseOrderStatus.emitido:
        return Colors.orange;
      case PurchaseOrderStatus.recebido:
        return Colors.green;
      case PurchaseOrderStatus.cancelado:
        return Colors.red;
    }
  }
}

class PurchaseOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double unitCost;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.unitCost,
  });

  double get subtotal => quantity * unitCost;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String? ?? '',
      quantity: (json['quantity'] as num).toInt(),
      unitCost: (json['unitCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'quantity': quantity,
      'unitCost': unitCost,
      'subtotal': subtotal,
    };
  }
}

class PurchaseOrder {
  final String id;
  final String tenantId;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final PurchaseOrderStatus status;
  final List<PurchaseOrderItem> items;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? expectedDeliveryDate;
  final DateTime? receivedAt;

  PurchaseOrder({
    required this.id,
    required this.tenantId,
    required this.orderNumber,
    required this.supplierId,
    required this.supplierName,
    this.status = PurchaseOrderStatus.emitido,
    this.items = const [],
    this.notes,
    this.createdBy = 'Responsável de Compras',
    required this.createdAt,
    this.expectedDeliveryDate,
    this.receivedAt,
  });

  double get totalAmount => items.fold(0.0, (acc, item) => acc + item.subtotal);
  int get totalItemsCount => items.fold(0, (acc, item) => acc + item.quantity);

  PurchaseOrder copyWith({
    String? id,
    String? tenantId,
    String? orderNumber,
    String? supplierId,
    String? supplierName,
    PurchaseOrderStatus? status,
    List<PurchaseOrderItem>? items,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? expectedDeliveryDate,
    DateTime? receivedAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      orderNumber: orderNumber ?? this.orderNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      status: _statusFromString(json['status'] as String?),
      items: (json['items'] as List?)
              ?.map((i) => PurchaseOrderItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String? ?? 'Usuário',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.parse(json['expectedDeliveryDate'] as String)
          : null,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'orderNumber': orderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.name,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
    };
  }

  static PurchaseOrderStatus _statusFromString(String? s) {
    if (s == null) return PurchaseOrderStatus.emitido;
    for (final st in PurchaseOrderStatus.values) {
      if (st.name.toLowerCase() == s.toLowerCase() ||
          st.label.toLowerCase() == s.toLowerCase()) {
        return st;
      }
    }
    return PurchaseOrderStatus.emitido;
  }
}
