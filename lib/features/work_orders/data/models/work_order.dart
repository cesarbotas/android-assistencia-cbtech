import 'package:uuid/uuid.dart';
import 'budget.dart';
import 'budget_item.dart';
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
    final pecasJson = json['pecas'] as List<dynamic>? ?? [];
    final servicosJson = json['servicos'] as List<dynamic>? ?? [];

    final idStr = json['id'] as String? ?? '';
    final shortId = idStr.length >= 4 ? idStr.substring(0, 4).toUpperCase() : '0000';

    final clienteId = json['clienteId'] as String? ?? json['customerId'] as String? ?? '';
    final aparelhoId = json['aparelhoId'] as String? ?? json['deviceId'] as String? ?? '';

    List<BudgetItem> budgetItems = [];
    for (final p in pecasJson) {
      budgetItems.add(BudgetItem(
        id: const Uuid().v4(),
        type: BudgetItemType.product,
        productId: p['produtoId'] as String? ?? '',
        description: p['descricao'] as String? ?? 'Peça / Componente',
        quantity: p['quantidade'] as int? ?? 1,
        costSnapshot: 0.0,
        salePriceSnapshot: (p['valorUnitario'] as num?)?.toDouble() ?? 0.0,
      ));
    }
    for (final s in servicosJson) {
      budgetItems.add(BudgetItem(
        id: const Uuid().v4(),
        type: BudgetItemType.service,
        serviceId: s['servicoId'] as String? ?? '',
        description: s['descricao'] as String? ?? 'Serviço Técnico',
        quantity: s['quantidade'] as int? ?? 1,
        costSnapshot: 0.0,
        salePriceSnapshot: (s['valorUnitario'] as num?)?.toDouble() ?? 0.0,
      ));
    }

    Budget? budget = json['currentBudget'] != null
        ? Budget.fromJson(json['currentBudget'] as Map<String, dynamic>)
        : (budgetItems.isNotEmpty ? Budget(id: const Uuid().v4(), workOrderId: idStr, items: budgetItems, status: BudgetStatus.aprovado, createdAt: DateTime.now()) : null);

    return WorkOrder(
      id: idStr,
      tenantId: json['tenantId'] as String? ?? '',
      sequentialNumber: json['numeroOs'] as String? ?? json['sequentialNumber'] as String? ?? 'OS-$shortId',
      customerId: clienteId,
      customerName: json['nomeCliente'] as String? ?? json['customerName'] as String? ?? (clienteId.isNotEmpty ? 'Cliente (ID: ${clienteId.substring(0, 6)}...)' : 'Cliente'),
      customerPhone: json['telefoneCliente'] as String? ?? json['customerPhone'] as String? ?? '(11) 90000-0000',
      deviceId: aparelhoId,
      deviceBrand: json['nomeMarca'] as String? ?? json['deviceBrand'] as String? ?? 'Marca',
      deviceModel: json['modelo'] as String? ?? json['modelName'] as String? ?? json['deviceModel'] as String? ?? (aparelhoId.isNotEmpty ? 'Aparelho (ID: ${aparelhoId.substring(0, 6)}...)' : 'Aparelho'),
      deviceImei: json['deviceImei'] as String?,
      deviceColor: json['deviceColor'] as String?,
      defectReported: json['problemaRelatado'] as String? ?? json['defectReported'] as String? ?? '',
      physicalCondition: json['physicalCondition'] as String? ?? json['termoGarantia'] as String?,
      accessoriesLeft: json['accessoriesLeft'] as String?,
      priority: json['prioridade'] as String? ?? json['priority'] as String? ?? 'Normal',
      technicianId: json['tecnicoId'] as String? ?? json['technicianId'] as String?,
      technicianName: json['technicianName'] as String?,
      status: WorkOrderStatus.fromString(json['status']?.toString() ?? 'Aberta'),
      deliveryForecast: json['deliveryForecast'] != null
          ? DateTime.parse(json['deliveryForecast'] as String)
          : null,
      diagnosis: json['diagnosis'] as String?,
      currentBudget: budget,
      budgetRevisions: revisionsJson
          .map((r) => Budget.fromJson(r as Map<String, dynamic>))
          .toList(),
      history: historyJson
          .map((h) => WorkOrderHistory.fromJson(h as Map<String, dynamic>))
          .toList(),
      attachments: attachmentsJson
          .map((a) => WorkOrderAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      createdAt: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
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
      if (id.isNotEmpty) 'id': id,
      'clienteId': customerId,
      'aparelhoId': deviceId,
      'problemaRelatado': defectReported,
      'prioridade': priority.toUpperCase(),
      'status': status.name.toUpperCase(),
      'termoGarantia': physicalCondition ?? 'Garantia de 90 dias',
      'pecas': currentBudget?.items
          .where((i) => i.type == BudgetItemType.product)
          .map((p) => {
                'produtoId': p.productId,
                'quantidade': p.quantity,
                'valorUnitario': p.salePriceSnapshot,
              })
          .toList() ?? [],
      'servicos': currentBudget?.items
          .where((i) => i.type == BudgetItemType.service)
          .map((s) => {
                'servicoId': s.serviceId,
                'quantidade': s.quantity,
                'valorUnitario': s.salePriceSnapshot,
              })
          .toList() ?? [],
    };
  }
}
