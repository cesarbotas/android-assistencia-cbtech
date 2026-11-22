import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/budget.dart';
import 'models/budget_item.dart';
import 'models/work_order.dart';
import 'models/work_order_history.dart';
import 'models/work_order_status.dart';

final workOrdersRepositoryProvider = Provider<WorkOrdersRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return WorkOrdersRepository(dio);
});

class WorkOrdersRepository {
  final Dio _dio;
  final _uuid = const Uuid();
  int _lastSequenceNumber = 104;

  final List<WorkOrder> _localWorkOrders = [
    WorkOrder(
      id: 'wo-1',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sequentialNumber: 'OS-0104',
      customerId: 'c1111111-1111-1111-1111-111111111111',
      customerName: 'Mariana Souza',
      customerPhone: '(11) 99876-5432',
      deviceBrand: 'Apple',
      deviceModel: 'iPhone 13',
      deviceImei: '356891092384712',
      deviceColor: 'Azul',
      defectReported: 'Touch não responde em certas áreas, vidro com trincas na parte superior.',
      physicalCondition: 'Trincado no canto superior direito. Sem marcas no aro.',
      accessoriesLeft: 'Capa transparente MagSafe',
      priority: 'Alta',
      status: WorkOrderStatus.emReparo,
      technicianName: 'Lucas Lima',
      diagnosis: 'Display OLED danificado internamente nas linhas de digitalização do touch. Substituição recomendada.',
      currentBudget: Budget(
        id: 'bg-1',
        workOrderId: 'wo-1',
        revision: 1,
        status: BudgetStatus.aprovado,
        approvedAt: DateTime.now().subtract(const Duration(hours: 3)),
        approvedBy: 'Mariana Souza (WhatsApp)',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        items: [
          BudgetItem(
            id: 'bi-1',
            type: BudgetItemType.product,
            productId: 'p1',
            description: 'Tela Display OLED iPhone 13 Original',
            quantity: 1,
            costSnapshot: 220.00,
            salePriceSnapshot: 450.00,
          ),
          BudgetItem(
            id: 'bi-2',
            type: BudgetItemType.service,
            serviceId: 'srv1',
            description: 'Mão de Obra Especializada - Troca de Tela',
            quantity: 1,
            costSnapshot: 0.0,
            salePriceSnapshot: 180.00,
          ),
        ],
      ),
      history: [
        WorkOrderHistory(
          id: 'h-1',
          workOrderId: 'wo-1',
          previousStatus: WorkOrderStatus.aberta,
          newStatus: WorkOrderStatus.aberta,
          userName: 'Atendente Carlos',
          note: 'Aparelho recebido no balcão.',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        WorkOrderHistory(
          id: 'h-2',
          workOrderId: 'wo-1',
          previousStatus: WorkOrderStatus.aberta,
          newStatus: WorkOrderStatus.orcamentoPendente,
          userName: 'Lucas Lima',
          note: 'Diagnóstico concluído e orçamento montado.',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        WorkOrderHistory(
          id: 'h-3',
          workOrderId: 'wo-1',
          previousStatus: WorkOrderStatus.orcamentoPendente,
          newStatus: WorkOrderStatus.aprovada,
          userName: 'Lucas Lima',
          note: 'Cliente aprovou o valor de R\$ 630,00 via WhatsApp.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        WorkOrderHistory(
          id: 'h-4',
          workOrderId: 'wo-1',
          previousStatus: WorkOrderStatus.aprovada,
          newStatus: WorkOrderStatus.emReparo,
          userName: 'Lucas Lima',
          note: 'Peça separada do estoque e iniciada a montagem em bancada.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    WorkOrder(
      id: 'wo-2',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sequentialNumber: 'OS-0103',
      customerId: 'c2222222-2222-2222-2222-222222222222',
      customerName: 'Carlos Eduardo Silva',
      customerPhone: '(11) 98888-7777',
      deviceBrand: 'Samsung',
      deviceModel: 'Galaxy S22 Ultra',
      deviceImei: '354910293817462',
      deviceColor: 'Preto Fantasma',
      defectReported: 'Aparelho parou de carregar após aviso de umidade na porta USB.',
      physicalCondition: 'Excelente estado, com película de gel e S-Pen original.',
      priority: 'Normal',
      status: WorkOrderStatus.aprovada,
      technicianName: 'Lucas Lima',
      diagnosis: 'Oxidação severa nos pinos da sub-placa do conector Tipo-C. Linha VBUS interrompida.',
      currentBudget: Budget(
        id: 'bg-2',
        workOrderId: 'wo-2',
        revision: 1,
        status: BudgetStatus.aprovado,
        approvedAt: DateTime.now().subtract(const Duration(hours: 8)),
        approvedBy: 'Carlos Eduardo (Presencial)',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        items: [
          BudgetItem(
            id: 'bi-3',
            type: BudgetItemType.product,
            productId: 'p3',
            description: 'Conector de Carga Galaxy S22 Ultra (Sub-placa)',
            quantity: 1,
            costSnapshot: 45.00,
            salePriceSnapshot: 120.00,
          ),
          BudgetItem(
            id: 'bi-4',
            type: BudgetItemType.service,
            serviceId: 'srv3',
            description: 'Desoxidação em Banho Ultrassônico',
            quantity: 1,
            costSnapshot: 0.0,
            salePriceSnapshot: 180.00,
          ),
          BudgetItem(
            id: 'bi-5',
            type: BudgetItemType.service,
            serviceId: 'srv5',
            description: 'Mão de Obra de Troca de Conector',
            quantity: 1,
            costSnapshot: 0.0,
            salePriceSnapshot: 80.00,
          ),
        ],
      ),
      history: [
        WorkOrderHistory(
          id: 'h-21',
          workOrderId: 'wo-2',
          previousStatus: WorkOrderStatus.aberta,
          newStatus: WorkOrderStatus.aprovada,
          userName: 'Lucas Lima',
          note: 'Aprovado pelo cliente.',
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    WorkOrder(
      id: 'wo-3',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sequentialNumber: 'OS-0102',
      customerId: 'c3333333-3333-3333-3333-333333333333',
      customerName: 'Fernanda Lima',
      customerPhone: '(11) 97777-6666',
      deviceBrand: 'Motorola',
      deviceModel: 'Edge 30 Fusion',
      defectReported: 'Bateria estufou e levantou ligeiramente a tampa traseira.',
      priority: 'Urgente',
      status: WorkOrderStatus.orcamentoPendente,
      diagnosis: 'Risco de perfuração térmica. Troca imediata da bateria e colagem da tampa.',
      currentBudget: Budget(
        id: 'bg-3',
        workOrderId: 'wo-3',
        revision: 1,
        status: BudgetStatus.pendente,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          BudgetItem(
            id: 'bi-6',
            type: BudgetItemType.product,
            productId: 'p4',
            description: 'Bateria Motorola Edge 30 Fusion Original',
            quantity: 1,
            costSnapshot: 60.00,
            salePriceSnapshot: 130.00,
          ),
          BudgetItem(
            id: 'bi-7',
            type: BudgetItemType.service,
            serviceId: 'srv2',
            description: 'Mão de Obra de Substituição de Bateria',
            quantity: 1,
            costSnapshot: 0.0,
            salePriceSnapshot: 90.00,
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WorkOrder(
      id: 'wo-4',
      tenantId: '11111111-1111-1111-1111-111111111111',
      sequentialNumber: 'OS-0101',
      customerId: 'c4444444-4444-4444-4444-444444444444',
      customerName: 'Rodrigo Menezes',
      customerPhone: '(11) 96666-5555',
      deviceBrand: 'Redmi',
      deviceModel: 'Redmi Note 12',
      defectReported: 'Sem som durante ligações normais.',
      status: WorkOrderStatus.concluida,
      diagnosis: 'Tela frontal limpa e auricular substituído.',
      currentBudget: Budget(
        id: 'bg-4',
        workOrderId: 'wo-4',
        revision: 1,
        status: BudgetStatus.aprovado,
        approvedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        items: [
          BudgetItem(
            id: 'bi-8',
            type: BudgetItemType.service,
            serviceId: 'srv2',
            description: 'Troca de Alto-falante Auricular',
            quantity: 1,
            costSnapshot: 20.00,
            salePriceSnapshot: 150.00,
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      finishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  WorkOrdersRepository(this._dio);

  Future<List<WorkOrder>> getWorkOrders({String? search, WorkOrderStatus? status}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (status != null) params['status'] = status.name;

      final res = await _dio.get(ApiEndpoints.workOrders, queryParameters: params);
      return (res.data as List).map((o) => WorkOrder.fromJson(o)).toList();
    } catch (_) {
      return _localWorkOrders.where((wo) {
        if (status != null && wo.status != status) return false;
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          final mNum = wo.sequentialNumber.toLowerCase().contains(q);
          final mCli = wo.customerName.toLowerCase().contains(q);
          final mDev = '${wo.deviceBrand} ${wo.deviceModel}'.toLowerCase().contains(q);
          final mDef = wo.defectReported.toLowerCase().contains(q);
          return mNum || mCli || mDev || mDef;
        }
        return true;
      }).toList();
    }
  }

  Future<WorkOrder?> getWorkOrderById(String id) async {
    try {
      final res = await _dio.get('${ApiEndpoints.workOrders}/$id');
      return WorkOrder.fromJson(res.data);
    } catch (_) {
      try {
        return _localWorkOrders.firstWhere((wo) => wo.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<WorkOrder> createWorkOrder(WorkOrder newWo) async {
    _lastSequenceNumber++;
    final generatedNumber = 'OS-0${_lastSequenceNumber.toString().padLeft(3, '0')}';
    final woId = newWo.id.isNotEmpty ? newWo.id : _uuid.v4();

    final createdWo = newWo.copyWith(
      id: woId,
      sequentialNumber: generatedNumber,
      createdAt: DateTime.now(),
      history: [
        WorkOrderHistory(
          id: _uuid.v4(),
          workOrderId: woId,
          previousStatus: WorkOrderStatus.aberta,
          newStatus: WorkOrderStatus.aberta,
          userName: newWo.technicianName ?? 'Atendente',
          note: 'Abertura de OS registrada no sistema.',
          createdAt: DateTime.now(),
        ),
      ],
    );

    try {
      final res = await _dio.post(ApiEndpoints.workOrders, data: createdWo.toJson());
      return WorkOrder.fromJson(res.data);
    } catch (_) {
      _localWorkOrders.insert(0, createdWo);
      return createdWo;
    }
  }

  Future<WorkOrder> updateStatus(
    String id,
    WorkOrderStatus newStatus, {
    String? note,
    String? userName,
  }) async {
    final wo = await getWorkOrderById(id);
    if (wo == null) throw Exception('Ordem de serviço não encontrada');

    final historyEntry = WorkOrderHistory(
      id: _uuid.v4(),
      workOrderId: id,
      previousStatus: wo.status,
      newStatus: newStatus,
      userName: userName ?? 'Técnico Responsável',
      note: note ?? 'Status alterado para ${newStatus.label}',
      createdAt: DateTime.now(),
    );

    final updated = wo.copyWith(
      status: newStatus,
      history: [historyEntry, ...wo.history],
      finishedAt: newStatus == WorkOrderStatus.concluida ? DateTime.now() : wo.finishedAt,
      deliveredAt: newStatus == WorkOrderStatus.entregue ? DateTime.now() : wo.deliveredAt,
    );

    try {
      await _dio.post(
        '${ApiEndpoints.workOrders}/$id/status',
        data: {'status': newStatus.name, 'note': note},
      );
    } catch (_) {
      final idx = _localWorkOrders.indexWhere((o) => o.id == id);
      if (idx != -1) _localWorkOrders[idx] = updated;
    }
    return updated;
  }

  Future<WorkOrder> updateDiagnosis(String id, String diagnosis) async {
    final wo = await getWorkOrderById(id);
    if (wo == null) throw Exception('OS não encontrada');

    final updated = wo.copyWith(diagnosis: diagnosis);
    final idx = _localWorkOrders.indexWhere((o) => o.id == id);
    if (idx != -1) _localWorkOrders[idx] = updated;
    return updated;
  }

  Future<WorkOrder> saveBudgetRevision(String id, Budget newBudget) async {
    final wo = await getWorkOrderById(id);
    if (wo == null) throw Exception('OS não encontrada');

    final nextRevisionNumber = (wo.currentBudget?.revision ?? 0) + 1;
    final budgetToSave = newBudget.copyWith(
      id: _uuid.v4(),
      workOrderId: id,
      revision: nextRevisionNumber,
      createdAt: DateTime.now(),
    );

    final allRevisions = [
      if (wo.currentBudget != null) wo.currentBudget!,
      ...wo.budgetRevisions,
    ];

    final updated = wo.copyWith(
      currentBudget: budgetToSave,
      budgetRevisions: allRevisions,
      status: wo.status == WorkOrderStatus.aberta ? WorkOrderStatus.orcamentoPendente : wo.status,
    );

    final idx = _localWorkOrders.indexWhere((o) => o.id == id);
    if (idx != -1) _localWorkOrders[idx] = updated;
    return updated;
  }

  Future<WorkOrder> approveBudget(String id, {required String approvedBy}) async {
    final wo = await getWorkOrderById(id);
    if (wo == null || wo.currentBudget == null) throw Exception('Orçamento não disponível');

    final approvedBudget = wo.currentBudget!.copyWith(
      status: BudgetStatus.aprovado,
      approvedAt: DateTime.now(),
      approvedBy: approvedBy,
    );

    return await updateStatus(
      id,
      WorkOrderStatus.aprovada,
      note: 'Orçamento aprovado por: $approvedBy',
    ).then((updatedWo) {
      final res = updatedWo.copyWith(currentBudget: approvedBudget);
      final idx = _localWorkOrders.indexWhere((o) => o.id == id);
      if (idx != -1) _localWorkOrders[idx] = res;
      return res;
    });
  }

  Future<WorkOrder> rejectBudget(String id, {required String reason}) async {
    final wo = await getWorkOrderById(id);
    if (wo == null || wo.currentBudget == null) throw Exception('Orçamento não disponível');

    final rejectedBudget = wo.currentBudget!.copyWith(
      status: BudgetStatus.recusado,
      rejectionReason: reason,
    );

    final updated = wo.copyWith(
      currentBudget: rejectedBudget,
      status: WorkOrderStatus.orcamentoPendente,
    );

    final idx = _localWorkOrders.indexWhere((o) => o.id == id);
    if (idx != -1) _localWorkOrders[idx] = updated;
    return updated;
  }
}
