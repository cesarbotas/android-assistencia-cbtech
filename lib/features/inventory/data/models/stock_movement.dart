import 'package:flutter/material.dart';

enum StockMovementType {
  entrada('Entrada Manual'),
  compra('Recebimento de Compra'),
  saida('Saída Avulsa / Descarte'),
  baixaOs('Baixa em OS'),
  ajuste('Ajuste de Inventário'),
  devolucao('Devolução a Fornecedor');

  final String label;
  const StockMovementType(this.label);

  Color get color {
    switch (this) {
      case StockMovementType.entrada:
      case StockMovementType.compra:
        return Colors.green;
      case StockMovementType.saida:
      case StockMovementType.devolucao:
        return Colors.red;
      case StockMovementType.baixaOs:
        return Colors.deepPurple;
      case StockMovementType.ajuste:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case StockMovementType.entrada:
      case StockMovementType.compra:
        return Icons.arrow_downward;
      case StockMovementType.saida:
      case StockMovementType.devolucao:
        return Icons.arrow_upward;
      case StockMovementType.baixaOs:
        return Icons.build_circle_outlined;
      case StockMovementType.ajuste:
        return Icons.tune;
    }
  }

  bool get isEntry => this == StockMovementType.entrada || this == StockMovementType.compra;
}

class StockMovement {
  final String id;
  final String tenantId;
  final String productId;
  final String productName;
  final String productSku;
  final StockMovementType type;
  final int quantity;
  final double unitCost;
  final double totalValue;
  final int previousStock;
  final int newStock;
  final String reason;
  final String? workOrderId;
  final String? workOrderNumber;
  final String? supplierId;
  final String? supplierName;
  final String createdBy;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.totalValue,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    this.workOrderId,
    this.workOrderNumber,
    this.supplierId,
    this.supplierName,
    this.createdBy = 'Técnico Responsável',
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String? ?? '',
      type: _typeFromString(json['type'] as String?),
      quantity: (json['quantity'] as num).toInt(),
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      previousStock: (json['previousStock'] as num?)?.toInt() ?? 0,
      newStock: (json['newStock'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      workOrderId: json['workOrderId'] as String?,
      workOrderNumber: json['workOrderNumber'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      createdBy: json['createdBy'] as String? ?? 'Usuário',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'type': type.name,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalValue': totalValue,
      'previousStock': previousStock,
      'newStock': newStock,
      'reason': reason,
      'workOrderId': workOrderId,
      'workOrderNumber': workOrderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static StockMovementType _typeFromString(String? typeStr) {
    if (typeStr == null) return StockMovementType.entrada;
    for (final t in StockMovementType.values) {
      if (t.name.toLowerCase() == typeStr.toLowerCase() ||
          t.label.toLowerCase() == typeStr.toLowerCase()) {
        return t;
      }
    }
    return StockMovementType.entrada;
  }
}
