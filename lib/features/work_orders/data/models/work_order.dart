import 'budget.dart';
import 'work_order_attachment.dart';
import 'work_order_history.dart';
import 'work_order_status.dart';

class WorkOrder {
  final String id;
  final String tenantId;
  final String sequentialNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? deviceId;
  final String deviceBrand;
  final String deviceModel;
  final String? deviceImei;
  final String? deviceColor;
  final String defectReported;
  final String? physicalCondition;
  final String? accessoriesLeft;
  final String priority; // Baixa, Normal, Alta, Urgente
  final String? technicianId;
  final String? technicianName;
  final WorkOrderStatus status;
  final DateTime? deliveryForecast;
  final String? diagnosis;
  final Budget? currentBudget;
  final List<Budget> budgetRevisions;
  final List<WorkOrderHistory> history;
  final List<WorkOrderAttachment> attachments;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final DateTime? deliveredAt;

  WorkOrder({
    required this.id,
    required this.tenantId,
    required this.sequentialNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.deviceId,
    required this.deviceBrand,
    required this.deviceModel,
    this.deviceImei,
    this.deviceColor,
    required this.defectReported,
    this.physicalCondition,
    this.accessoriesLeft,
    this.priority = 'Normal',
    this.technicianId,
    this.technicianName,
    this.status = WorkOrderStatus.aberta,
    this.deliveryForecast,
    this.diagnosis,
    this.currentBudget,
    this.budgetRevisions = const [],
    this.history = const [],
    this.attachments = const [],
    required this.createdAt,
    this.finishedAt,
    this.deliveredAt,
  });

  double get totalValue => currentBudget?.grandTotal ?? 0.0;

  WorkOrder copyWith({
    String? id,
    String? tenantId,
    String? sequentialNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deviceId,
    String? deviceBrand,
    String? deviceModel,
    String? deviceImei,
    String? deviceColor,
    String? defectReported,
    String? physicalCondition,
    String? accessoriesLeft,
    String? priority,
    String? technicianId,
    String? technicianName,
    WorkOrderStatus? status,
    DateTime? deliveryForecast,
    String? diagnosis,
    Budget? currentBudget,
    List<Budget>? budgetRevisions,
    List<WorkOrderHistory>? history,
    List<WorkOrderAttachment>? attachments,
    DateTime? createdAt,
    DateTime? finishedAt,
    DateTime? deliveredAt,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      sequentialNumber: sequentialNumber ?? this.sequentialNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deviceId: deviceId ?? this.deviceId,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceImei: deviceImei ?? this.deviceImei,
      deviceColor: deviceColor ?? this.deviceColor,
      defectReported: defectReported ?? this.defectReported,
      physicalCondition: physicalCondition ?? this.physicalCondition,
      accessoriesLeft: accessoriesLeft ?? this.accessoriesLeft,
      priority: priority ?? this.priority,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      status: status ?? this.status,
      deliveryForecast: deliveryForecast ?? this.deliveryForecast,
      diagnosis: diagnosis ?? this.diagnosis,
      currentBudget: currentBudget ?? this.currentBudget,
      budgetRevisions: budgetRevisions ?? this.budgetRevisions,
      history: history ?? this.history,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    final revisionsJson = json['budgetRevisions'] as List<dynamic>? ?? [];
    final historyJson = json['history'] as List<dynamic>? ?? [];
    final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];

    return WorkOrder(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      sequentialNumber: json['sequentialNumber'] as String? ?? 'OS-0000',
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      deviceId: json['deviceId'] as String?,
      deviceBrand: json['deviceBrand'] as String? ?? '',
      deviceModel: json['deviceModel'] as String? ?? '',
      deviceImei: json['deviceImei'] as String?,
      deviceColor: json['deviceColor'] as String?,
      defectReported: json['defectReported'] as String? ?? '',
      physicalCondition: json['physicalCondition'] as String?,
      accessoriesLeft: json['accessoriesLeft'] as String?,
      priority: json['priority'] as String? ?? 'Normal',
      technicianId: json['technicianId'] as String?,
      technicianName: json['technicianName'] as String?,
      status: WorkOrderStatus.fromString(json['status'] as String? ?? 'Aberta'),
      deliveryForecast: json['deliveryForecast'] != null
          ? DateTime.parse(json['deliveryForecast'] as String)
          : null,
      diagnosis: json['diagnosis'] as String?,
      currentBudget: json['currentBudget'] != null
          ? Budget.fromJson(json['currentBudget'] as Map<String, dynamic>)
          : null,
      budgetRevisions: revisionsJson
          .map((r) => Budget.fromJson(r as Map<String, dynamic>))
          .toList(),
      history: historyJson
          .map((h) => WorkOrderHistory.fromJson(h as Map<String, dynamic>))
          .toList(),
      attachments: attachmentsJson
          .map((a) => WorkOrderAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'sequentialNumber': sequentialNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deviceId': deviceId,
      'deviceBrand': deviceBrand,
      'deviceModel': deviceModel,
      'deviceImei': deviceImei,
      'deviceColor': deviceColor,
      'defectReported': defectReported,
      'physicalCondition': physicalCondition,
      'accessoriesLeft': accessoriesLeft,
      'priority': priority,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'status': status.label,
      'deliveryForecast': deliveryForecast?.toIso8601String(),
      'diagnosis': diagnosis,
      'currentBudget': currentBudget?.toJson(),
      'budgetRevisions': budgetRevisions.map((b) => b.toJson()).toList(),
      'history': history.map((h) => h.toJson()).toList(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }
}
