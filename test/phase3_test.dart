import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cbtech/features/work_orders/data/models/budget.dart';
import 'package:cbtech/features/work_orders/data/models/budget_item.dart';
import 'package:cbtech/features/work_orders/data/models/work_order.dart';
import 'package:cbtech/features/work_orders/data/models/work_order_status.dart';
import 'package:cbtech/features/work_orders/data/work_orders_repository.dart';
import 'package:cbtech/features/work_orders/presentation/work_orders_controller.dart';

void main() {
  group('Fase 3: Work Order Models & Domain Logic', () {
    test('Status transitions follow allowed flow', () {
      expect(WorkOrderStatus.aberta.nextAllowedTransitions, contains(WorkOrderStatus.orcamentoPendente));
      expect(WorkOrderStatus.aberta.nextAllowedTransitions, contains(WorkOrderStatus.cancelada));

      expect(WorkOrderStatus.orcamentoPendente.nextAllowedTransitions, contains(WorkOrderStatus.aprovada));
      expect(WorkOrderStatus.orcamentoPendente.nextAllowedTransitions, contains(WorkOrderStatus.cancelada));

      expect(WorkOrderStatus.aprovada.nextAllowedTransitions, contains(WorkOrderStatus.emReparo));
      expect(WorkOrderStatus.emReparo.nextAllowedTransitions, contains(WorkOrderStatus.testes));
      expect(WorkOrderStatus.testes.nextAllowedTransitions, contains(WorkOrderStatus.concluida));
      expect(WorkOrderStatus.concluida.nextAllowedTransitions, contains(WorkOrderStatus.entregue));

      expect(WorkOrderStatus.entregue.nextAllowedTransitions, isEmpty);
    });

    test('Budget calculations for totals, costs, and profit', () {
      final items = [
        BudgetItem(
          id: 'item-1',
          type: BudgetItemType.product,
          productId: 'p1',
          description: 'Tela OLED',
          quantity: 2,
          costSnapshot: 150.0,
          salePriceSnapshot: 300.0,
        ),
        BudgetItem(
          id: 'item-2',
          type: BudgetItemType.service,
          serviceId: 's1',
          description: 'Mão de obra',
          quantity: 1,
          costSnapshot: 0.0,
          salePriceSnapshot: 150.0,
        ),
      ];

      final budget = Budget(
        id: 'bg-1',
        workOrderId: 'wo-test',
        items: items,
        createdAt: DateTime.now(),
      );

      expect(items[0].subtotal, 600.0);
      expect(items[1].subtotal, 150.0);

      expect(budget.productsTotal, 600.0);
      expect(budget.servicesTotal, 150.0);
      expect(budget.grandTotal, 750.0);

      // Custo: 2 * 150.0 = 300.0
      expect(budget.totalCost, 300.0);
      // Lucro: 750.0 - 300.0 = 450.0
      expect(budget.estimatedProfit, 450.0);
    });
  });

  group('Fase 3: WorkOrdersController & Repository', () {
    late WorkOrdersRepository repo;
    late WorkOrdersController controller;

    setUp(() {
      final dio = Dio();
      repo = WorkOrdersRepository(dio);
      controller = WorkOrdersController(repo);
    });

    test('Loads initial work orders and filters', () async {
      await controller.loadWorkOrders();
      expect(controller.state.workOrders.isNotEmpty, isTrue);

      final initialCount = controller.state.workOrders.length;

      // Filter by query
      controller.setSearchQuery('iPhone 13');
      expect(controller.state.filteredWorkOrders.length, 1);
      expect(controller.state.filteredWorkOrders.first.deviceModel, 'iPhone 13');

      // Clear search query
      controller.setSearchQuery('');
      expect(controller.state.filteredWorkOrders.length, initialCount);

      // Filter by status
      controller.setStatusFilter(WorkOrderStatus.emReparo);
      for (final wo in controller.state.filteredWorkOrders) {
        expect(wo.status, WorkOrderStatus.emReparo);
      }

      // Reset filter
      controller.setStatusFilter(null);
      expect(controller.state.filteredWorkOrders.length, initialCount);
    });

    test('Creates new work order with sequential number and history log', () async {
      final newOrder = WorkOrder(
        id: '',
        tenantId: '11111111-1111-1111-1111-111111111111',
        sequentialNumber: '',
        customerId: 'cust-1',
        customerName: 'Ana Beatriz',
        customerPhone: '(11) 91234-5678',
        deviceBrand: 'Xiaomi',
        deviceModel: 'Poco X5 Pro',
        defectReported: 'Não liga após descarga total',
        priority: 'Alta',
        status: WorkOrderStatus.aberta,
        createdAt: DateTime.now(),
      );

      final success = await controller.createWorkOrder(newOrder);
      expect(success, isTrue);

      final created = controller.state.workOrders.firstWhere((w) => w.customerName == 'Ana Beatriz');
      expect(created.sequentialNumber.startsWith('OS-'), isTrue);
      expect(created.history.isNotEmpty, isTrue);
      expect(created.history.first.note, contains('Abertura'));
    });

    test('Updates diagnosis and advances status', () async {
      await controller.loadWorkOrders();
      final target = controller.state.workOrders.first;

      // Update diagnosis
      final diagSuccess = await controller.updateDiagnosis(target.id, 'Novo diagnóstico de bancada');
      expect(diagSuccess, isTrue);

      // Advance status
      final statusSuccess = await controller.updateStatus(
        target.id,
        WorkOrderStatus.aguardandoPeca,
        note: 'Peça encomendada ao fornecedor',
      );
      expect(statusSuccess, isTrue);

      final updated = controller.state.workOrders.firstWhere((w) => w.id == target.id);
      expect(updated.diagnosis, 'Novo diagnóstico de bancada');
      expect(updated.status, WorkOrderStatus.aguardandoPeca);
      expect(updated.history.any((h) => h.newStatus == WorkOrderStatus.aguardandoPeca), isTrue);
    });

    test('Approves budget and registers approver in history', () async {
      await controller.loadWorkOrders();
      // Encontrar OS com orçamento pendente
      final woPending = controller.state.workOrders.firstWhere((w) => w.status == WorkOrderStatus.orcamentoPendente);

      final approveSuccess = await controller.approveBudget(woPending.id, 'Cliente via WhatsApp');
      expect(approveSuccess, isTrue);

      final approvedWo = controller.state.workOrders.firstWhere((w) => w.id == woPending.id);
      expect(approvedWo.status, WorkOrderStatus.aprovada);
      expect(approvedWo.currentBudget?.status, BudgetStatus.aprovado);
      expect(approvedWo.currentBudget?.approvedBy, 'Cliente via WhatsApp');
    });
  });
}
