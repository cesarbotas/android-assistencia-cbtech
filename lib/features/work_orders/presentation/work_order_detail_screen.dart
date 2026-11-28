import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/budget.dart';
import '../data/models/work_order.dart';
import '../data/work_orders_repository.dart';
import 'work_orders_controller.dart';

class WorkOrderDetailScreen extends ConsumerStatefulWidget {
  final WorkOrder? workOrder;
  final String? workOrderId;

  const WorkOrderDetailScreen({super.key, this.workOrder, this.workOrderId});

  @override
  ConsumerState<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends ConsumerState<WorkOrderDetailScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  late Future<WorkOrder?> _workOrderFuture;
  late TextEditingController _diagnosisController;
  bool _isSavingDiagnosis = false;

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController(text: widget.workOrder?.diagnosis ?? '');

    final id = (widget.workOrderId != null && widget.workOrderId!.isNotEmpty)
        ? widget.workOrderId
        : widget.workOrder?.id;

    if (id != null && id.isNotEmpty) {
      _workOrderFuture = ref.read(workOrdersRepositoryProvider).getWorkOrderById(id);
    } else if (widget.workOrder != null) {
      _workOrderFuture = Future.value(widget.workOrder);
    } else {
      _workOrderFuture = Future.value(null);
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  void _shareViaWhatsApp(WorkOrder wo) {
    final text = '''
*CB Tech — Gestão de Assistência Técnica*
Ordem de Serviço: *${wo.sequentialNumber}*
Cliente: ${wo.customerName}
Aparelho: ${wo.deviceBrand} ${wo.deviceModel}
Defeito: ${wo.defectReported}
Status Atual: *${wo.status.label.toUpperCase()}*

Acompanhe os detalhes da sua manutenção conosco!
''';
    Share.share(text, subject: 'Status da ${wo.sequentialNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return FutureBuilder<WorkOrder?>(
      future: _workOrderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && widget.workOrder == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Carregando OS...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final wo = snapshot.data ?? widget.workOrder;

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

        if (_diagnosisController.text.isEmpty && wo.diagnosis != null && wo.diagnosis!.isNotEmpty) {
          _diagnosisController.text = wo.diagnosis!;
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('OS: ${wo.sequentialNumber}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar OS',
                  onPressed: () => context.push('/work-orders/edit', extra: wo),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'WhatsApp',
                  onPressed: () => _shareViaWhatsApp(wo),
                ),
              ],
              bottom: const TabBar(
                isScrollable: false,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Visão Geral', icon: Icon(Icons.info_outline, size: 18)),
                  Tab(text: 'Diagnóstico', icon: Icon(Icons.biotech_outlined, size: 18)),
                  Tab(text: 'Orçamento', icon: Icon(Icons.calculate_outlined, size: 18)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // TAB 1: VISÃO GERAL
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Status & Prioridade
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(status: wo.status.label),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Prioridade: ${wo.priority}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card Cliente
                      Card(
                        elevation: 1.5,
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
                              Text(wo.customerName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 4),
                              Text('Telefone: ${wo.customerPhone}', style: TextStyle(fontSize: 13, color: subTextColor)),
                              if (wo.customerId.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('ID Cliente: ${wo.customerId}', style: TextStyle(fontSize: 11, color: subTextColor)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card Aparelho
                      Card(
                        elevation: 1.5,
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
                              Text('${wo.deviceBrand} ${wo.deviceModel}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                              if (wo.deviceColor != null && wo.deviceColor!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Cor: ${wo.deviceColor}', style: TextStyle(fontSize: 13, color: subTextColor)),
                              ],
                              if (wo.deviceImei != null && wo.deviceImei!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('IMEI / Série: ${wo.deviceImei}', style: TextStyle(fontSize: 12, color: subTextColor)),
                              ],
                              if (wo.deviceId != null && wo.deviceId!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('ID Aparelho: ${wo.deviceId}', style: TextStyle(fontSize: 11, color: subTextColor)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card Defeito Relatado
                      Card(
                        elevation: 1.5,
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
                                  Text('Defeito Informado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                                ],
                              ),
                              const Divider(height: 16),
                              Text(
                                wo.defectReported.isNotEmpty ? wo.defectReported : 'Nenhum defeito detalhado',
                                style: TextStyle(fontSize: 14, color: textColor),
                              ),
                              if (wo.physicalCondition != null && wo.physicalCondition!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text('Termos / Estado Físico:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: subTextColor)),
                                const SizedBox(height: 2),
                                Text(wo.physicalCondition!, style: TextStyle(fontSize: 13, color: textColor)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card Data de Abertura & Identificador
                      Card(
                        elevation: 1.5,
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
                                  Text('Registro de Entrada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Data de Abertura:', style: TextStyle(fontWeight: FontWeight.bold, color: subTextColor)),
                                  Text(_dateFormat.format(wo.createdAt), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('ID no Servidor: ${wo.id}', style: TextStyle(fontSize: 11, color: subTextColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 2: DIAGNÓSTICO
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Laudo Técnico & Diagnóstico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      Text('Registre os resultados dos testes de bancada e o laudo do técnico.', style: TextStyle(color: subTextColor, fontSize: 13)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _diagnosisController,
                        maxLines: 6,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          hintText: 'Descreva detalhadamente o diagnóstico de bancada...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white, size: 18),
                          label: _isSavingDiagnosis
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Salvar Diagnóstico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: _isSavingDiagnosis
                              ? null
                              : () async {
                                  setState(() => _isSavingDiagnosis = true);
                                  final success = await ref
                                      .read(workOrdersControllerProvider.notifier)
                                      .updateDiagnosis(
                                        wo.id,
                                        _diagnosisController.text.trim(),
                                      );
                                  setState(() => _isSavingDiagnosis = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Diagnóstico técnico salvo com sucesso!'
                                              : 'Falha ao salvar diagnóstico.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 3: ORÇAMENTO
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Resumo do Orçamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: wo.currentBudget?.status == BudgetStatus.aprovado
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (wo.currentBudget?.status.name ?? 'Pendente').toUpperCase(),
                              style: TextStyle(
                                color: wo.currentBudget?.status == BudgetStatus.aprovado
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Lista de Itens do Orçamento
                      if (wo.currentBudget?.items.isNotEmpty == true) ...[
                        ...wo.currentBudget!.items.map((item) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.description, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                              subtitle: Text('${item.quantity}x • Unit: ${_currency.format(item.salePriceSnapshot)}', style: TextStyle(fontSize: 12, color: subTextColor)),
                              trailing: Text(_currency.format(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                            ),
                          );
                        }),
                      ] else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Nenhum item adicionado ao orçamento.', style: TextStyle(color: subTextColor)),
                          ),
                        ),

                      const Divider(height: 32),

                      // Resumo dos Totais
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Peças:', style: TextStyle(color: subTextColor)),
                          Text(_currency.format(wo.currentBudget?.productsTotal ?? 0.0), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mão de Obra:', style: TextStyle(color: subTextColor)),
                          Text(_currency.format(wo.currentBudget?.servicesTotal ?? 0.0), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Geral da OS:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          Text(
                            _currency.format(wo.totalValue),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
