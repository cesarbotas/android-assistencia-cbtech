enum BudgetItemType { product, service }

class BudgetItem {
  final String id;
  final BudgetItemType type;
  final String? productId;
  final String? serviceId;
  final String description;
  final int quantity;
  final double costSnapshot;
  final double salePriceSnapshot;
  final double discount;

  BudgetItem({
    required this.id,
    required this.type,
    this.productId,
    this.serviceId,
    required this.description,
    this.quantity = 1,
    required this.costSnapshot,
    required this.salePriceSnapshot,
    this.discount = 0.0,
  });

  double get subtotal => (salePriceSnapshot * quantity) - discount;
  double get totalCost => costSnapshot * quantity;
  double get profit => subtotal - totalCost;

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as String,
      type: json['type'] == 'product' ? BudgetItemType.product : BudgetItemType.service,
      productId: json['productId'] as String?,
      serviceId: json['serviceId'] as String?,
      description: json['description'] as String,
      quantity: json['quantity'] as int? ?? 1,
      costSnapshot: (json['costSnapshot'] as num?)?.toDouble() ?? 0.0,
      salePriceSnapshot: (json['salePriceSnapshot'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == BudgetItemType.product ? 'product' : 'service',
      'productId': productId,
      'serviceId': serviceId,
      'description': description,
      'quantity': quantity,
      'costSnapshot': costSnapshot,
      'salePriceSnapshot': salePriceSnapshot,
      'discount': discount,
      'subtotal': subtotal,
    };
  }
}
