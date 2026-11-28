import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/work_order.dart';
import 'work_orders_controller.dart';

class WorkOrderDetailScreen extends ConsumerStatefulWidget {
  final WorkOrder? workOrder;
  final String? workOrderId;

  const WorkOrderDetailScreen({super.key, this.workOrder, this.workOrderId});

  @override
  ConsumerState<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends ConsumerState<WorkOrderDetailScreen> {
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.workOrder != null) {
        ref.read(workOrdersControllerProvider.notifier).setSelectedWorkOrder(widget.workOrder!);
      }
      final id = widget.workOrder?.id ?? widget.workOrderId;
      if (id != null && id.isNotEmpty) {
        ref.read(workOrdersControllerProvider.notifier).selectWorkOrder(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final woState = ref.watch(workOrdersControllerProvider);
    final wo = woState.selectedWorkOrder ?? widget.workOrder;

    if (wo == null && woState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando OS...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (wo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da OS')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('Ordem de serviço não encontrada.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar para Listagem'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('OS: ${wo.sequentialNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar OS',
            onPressed: () => context.push('/work-orders/edit', extra: wo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status & Prioridade
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: wo.status.label),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Prioridade: ${wo.priority}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Cliente
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      wo.customerName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Telefone: ${wo.customerPhone}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    if (wo.customerId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'ID Cliente: ${wo.customerId}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Card Aparelho
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.smartphone_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Aparelho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      '${wo.deviceBrand} ${wo.deviceModel}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (wo.deviceColor != null && wo.deviceColor!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Cor: ${wo.deviceColor}', style: const TextStyle(fontSize: 13)),
                    ],
                    if (wo.deviceImei != null && wo.deviceImei!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('IMEI / Série: ${wo.deviceImei}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                    if (wo.deviceId != null && wo.deviceId!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('ID Aparelho: ${wo.deviceId}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Card Defeito Relatado
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Defeito Relatado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      wo.defectReported.isNotEmpty ? wo.defectReported : 'Nenhum defeito detalhado',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    if (wo.physicalCondition != null && wo.physicalCondition!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Termos / Condição Física:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(wo.physicalCondition!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Card Informações do Registro
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event_note_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Registro & Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                      ],
                    ),
                    const Divider(height: 16),
                    Text('Data de Abertura: ${_dateFormat.format(wo.createdAt)}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('ID da OS no Servidor: ${wo.id}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
