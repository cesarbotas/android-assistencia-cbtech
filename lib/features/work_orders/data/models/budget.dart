import 'budget_item.dart';

enum BudgetStatus { pendente, aprovado, recusado, cancelado }

class Budget {
  final String id;
  final String workOrderId;
  final int revision;
  final BudgetStatus status;
  final List<BudgetItem> items;
  final double discount;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final String? notes;

  Budget({
    required this.id,
    required this.workOrderId,
    this.revision = 1,
    this.status = BudgetStatus.pendente,
    this.items = const [],
    this.discount = 0.0,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.notes,
  });

  double get productsTotal {
    return items
        .where((i) => i.type == BudgetItemType.product)
        .fold(0.0, (acc, item) => acc + item.subtotal);
  }

  double get servicesTotal {
    return items
        .where((i) => i.type == BudgetItemType.service)
        .fold(0.0, (acc, item) => acc + item.subtotal);
  }

  double get totalCost {
    return items.fold(0.0, (acc, item) => acc + item.totalCost);
  }

  double get grandTotal {
    final sub = productsTotal + servicesTotal - discount;
    return sub > 0 ? sub : 0.0;
  }

  double get estimatedProfit => grandTotal - totalCost;

  Budget copyWith({
    String? id,
    String? workOrderId,
    int? revision,
    BudgetStatus? status,
    List<BudgetItem>? items,
    double? discount,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    String? notes,
  }) {
    return Budget(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      revision: revision ?? this.revision,
      status: status ?? this.status,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Budget(
      id: json['id'] as String,
      workOrderId: json['workOrderId'] as String? ?? '',
      revision: json['revision'] as int? ?? 1,
      status: _statusFromString(json['status'] as String?),
      items: itemsJson
          .map((i) => BudgetItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'revision': revision,
      'status': status.name,
      'items': items.map((i) => i.toJson()).toList(),
      'discount': discount,
      'productsTotal': productsTotal,
      'servicesTotal': servicesTotal,
      'grandTotal': grandTotal,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'notes': notes,
    };
  }

  static BudgetStatus _statusFromString(String? str) {
    switch (str?.toLowerCase()) {
      case 'aprovado':
        return BudgetStatus.aprovado;
      case 'recusado':
        return BudgetStatus.recusado;
      case 'cancelado':
        return BudgetStatus.cancelado;
      default:
        return BudgetStatus.pendente;
    }
  }
}
