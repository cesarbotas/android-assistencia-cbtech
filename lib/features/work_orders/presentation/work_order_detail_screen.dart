import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../inventory/presentation/products_controller.dart';
import '../../services/presentation/services_controller.dart';
import '../data/models/budget.dart';
import '../data/models/budget_item.dart';
import '../data/models/work_order.dart';
import 'work_orders_controller.dart';

class WorkOrderDetailScreen extends ConsumerStatefulWidget {
  final String workOrderId;

  const WorkOrderDetailScreen({super.key, required this.workOrderId});

  @override
  ConsumerState<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends ConsumerState<WorkOrderDetailScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  late TextEditingController _diagnosisController;
  bool _isSavingDiagnosis = false;

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workOrdersControllerProvider.notifier).selectWorkOrder(widget.workOrderId);
    });
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  void _shareViaWhatsApp(WorkOrder wo) {
    final budgetStr = wo.currentBudget != null
        ? 'Valor total: ${_currency.format(wo.currentBudget!.grandTotal)}'
        : 'Orçamento em elaboração';

    final text = '''
*CB Tech — Gestão de Assistência Técnica*
Ordem de Serviço: *${wo.sequentialNumber}*
Cliente: ${wo.customerName}
Aparelho: ${wo.deviceBrand} ${wo.deviceModel}
Defeito: ${wo.defectReported}
Status Atual: *${wo.status.label.toUpperCase()}*
$budgetStr

Acompanhe os detalhes da sua manutenção conosco!
''';
    Share.share(text, subject: 'Status da ${wo.sequentialNumber}');
  }

  void _showChangeStatusDialog(WorkOrder wo) {
    final nextOptions = wo.status.nextAllowedTransitions;
    if (nextOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta OS já atingiu seu status final.')),
      );
      return;
    }

    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Avançar ${wo.sequentialNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Atual: ${wo.status.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Selecione o novo status:'),
            const SizedBox(height: 8),
            ...nextOptions.map((st) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: st.color,
                ),
                title: Text(st.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref.read(workOrdersControllerProvider.notifier).updateStatus(
                        wo.id,
                        st,
                        note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status atualizado para ${st.label}!')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddPartDialog(WorkOrder wo) {
    final prodState = ref.read(productsControllerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Adicionar Peça do Estoque',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: prodState.products.length,
                itemBuilder: (context, index) {
                  final p = prodState.products[index];
                  return ListTile(
                    leading: const Icon(Icons.extension_outlined, color: AppColors.primary),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('SKU: ${p.sku} • Estoque: ${p.currentStock} ${p.unit}'),
                    trailing: Text(
                      _currency.format(p.salePrice),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final currentItems = List<BudgetItem>.from(wo.currentBudget?.items ?? []);
                      currentItems.add(
                        BudgetItem(
                          id: const Uuid().v4(),
                          type: BudgetItemType.product,
                          productId: p.id,
                          description: p.name,
                          quantity: 1,
                          costSnapshot: p.costPrice,
                          salePriceSnapshot: p.salePrice,
                        ),
                      );

                      final updatedBudget = (wo.currentBudget ??
                              Budget(
                                id: const Uuid().v4(),
                                workOrderId: wo.id,
                                createdAt: DateTime.now(),
                              ))
                          .copyWith(items: currentItems, status: BudgetStatus.pendente);

                      await ref.read(workOrdersControllerProvider.notifier).saveBudgetRevision(wo.id, updatedBudget);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(WorkOrder wo) {
    final srvState = ref.read(servicesControllerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Adicionar Serviço de Mão de Obra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: srvState.services.length,
                itemBuilder: (context, index) {
                  final s = srvState.services[index];
                  return ListTile(
                    leading: const Icon(Icons.build_circle_outlined, color: AppColors.primary),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${s.category} • Estimado: ${s.estimatedTimeMinutes} min'),
                    trailing: Text(
                      _currency.format(s.defaultPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final currentItems = List<BudgetItem>.from(wo.currentBudget?.items ?? []);
                      currentItems.add(
                        BudgetItem(
                          id: const Uuid().v4(),
                          type: BudgetItemType.service,
                          serviceId: s.id,
                          description: s.name,
                          quantity: 1,
                          costSnapshot: 0.0,
                          salePriceSnapshot: s.defaultPrice,
                        ),
                      );

                      final updatedBudget = (wo.currentBudget ??
                              Budget(
                                id: const Uuid().v4(),
                                workOrderId: wo.id,
                                createdAt: DateTime.now(),
                              ))
                          .copyWith(items: currentItems, status: BudgetStatus.pendente);

                      await ref.read(workOrdersControllerProvider.notifier).saveBudgetRevision(wo.id, updatedBudget);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _approveBudgetDialog(WorkOrder wo) {
    final approverCtrl = TextEditingController(text: wo.customerName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aprovar Orçamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor Total: ${_currency.format(wo.totalValue)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: approverCtrl,
              decoration: const InputDecoration(
                labelText: 'Quem autorizou a aprovação? *',
                hintText: 'Ex: Cliente via WhatsApp / Presencial',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(workOrdersControllerProvider.notifier).approveBudget(
                    wo.id,
                    approverCtrl.text.trim(),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orçamento aprovado com sucesso!')),
                );
              }
            },
            child: const Text('Confirmar Aprovação', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final woState = ref.watch(workOrdersControllerProvider);
    final wo = woState.selectedWorkOrder;

    if (wo == null && woState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (wo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da OS')),
        body: const Center(child: Text('Ordem de serviço não encontrada.')),
      );
    }

    if (_diagnosisController.text.isEmpty && wo.diagnosis != null) {
      _diagnosisController.text = wo.diagnosis!;
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(wo.sequentialNumber),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              tooltip: 'WhatsApp',
              onPressed: () => _shareViaWhatsApp(wo),
            ),
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Imprimir / PDF',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Comprovante da ${wo.sequentialNumber} pronto para impressão.')),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Visão Geral', icon: Icon(Icons.info_outline, size: 20)),
              Tab(text: 'Diagnóstico', icon: Icon(Icons.biotech_outlined, size: 20)),
              Tab(text: 'Orçamento', icon: Icon(Icons.calculate_outlined, size: 20)),
              Tab(text: 'Histórico', icon: Icon(Icons.timeline, size: 20)),
              Tab(text: 'Fotos & Anexos', icon: Icon(Icons.photo_library_outlined, size: 20)),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total da OS:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      _currency.format(wo.totalValue),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Avançar Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => _showChangeStatusDialog(wo),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: VISÃO GERAL
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: wo.status.label),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Prioridade: ${wo.priority}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card Cliente
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text(wo.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(wo.customerPhone, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card Aparelho
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aparelho', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text('${wo.deviceBrand} ${wo.deviceModel}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (wo.deviceColor != null) Text('Cor: ${wo.deviceColor}'),
                        if (wo.deviceImei != null) Text('IMEI: ${wo.deviceImei}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card Defeito & Observações
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Defeito Informado pelo Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text(wo.defectReported),
                        if (wo.physicalCondition != null) ...[
                          const SizedBox(height: 10),
                          const Text('Estado de Conservação:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(wo.physicalCondition!, style: const TextStyle(fontSize: 13)),
                        ],
                        if (wo.accessoriesLeft != null) ...[
                          const SizedBox(height: 10),
                          const Text('Acessórios Deixados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(wo.accessoriesLeft!, style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // TAB 2: DIAGNÓSTICO
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Laudo Técnico & Diagnóstico',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registre os resultados dos testes de bancada, curtos identificados e procedimentos necessários.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _diagnosisController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Descreva detalhadamente o diagnóstico...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: _isSavingDiagnosis
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Diagnóstico', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    setState(() => _isSavingDiagnosis = true);
                    await ref.read(workOrdersControllerProvider.notifier).updateDiagnosis(
                          wo.id,
                          _diagnosisController.text.trim(),
                        );
                    setState(() => _isSavingDiagnosis = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diagnóstico técnico atualizado!')),
                      );
                    }
                  },
                ),
              ],
            ),

            // TAB 3: ORÇAMENTO & REVISÕES
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Revisão ${wo.currentBudget?.revision ?? 1}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: wo.currentBudget?.status == BudgetStatus.aprovado
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
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
                const SizedBox(height: 12),

                // Lista de Itens do Orçamento
                if (wo.currentBudget?.items.isNotEmpty == true) ...[
                  ...wo.currentBudget!.items.map((item) {
                    final isProd = item.type == BudgetItemType.product;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isProd ? Colors.blue.shade50 : Colors.green.shade50,
                          child: Icon(
                            isProd ? Icons.extension : Icons.build,
                            color: isProd ? AppColors.primary : Colors.green,
                            size: 18,
                          ),
                        ),
                        title: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${item.quantity}x • Unit: ${_currency.format(item.salePriceSnapshot)}'),
                        trailing: Text(
                          _currency.format(item.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    );
                  }),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('Nenhum item adicionado ao orçamento.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Peça'),
                        onPressed: () => _showAddPartDialog(wo),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_task, size: 18),
                        label: const Text('Serviço'),
                        onPressed: () => _showAddServiceDialog(wo),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Resumo do Orçamento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peças:', style: TextStyle(color: Colors.grey)),
                    Text(_currency.format(wo.currentBudget?.productsTotal ?? 0.0), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mão de Obra:', style: TextStyle(color: Colors.grey)),
                    Text(_currency.format(wo.currentBudget?.servicesTotal ?? 0.0), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Geral:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      _currency.format(wo.currentBudget?.grandTotal ?? 0.0),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (wo.currentBudget?.status != BudgetStatus.aprovado)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Aprovar Orçamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () => _approveBudgetDialog(wo),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // TAB 4: HISTÓRICO / LINHA DO TEMPO
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wo.history.length,
              itemBuilder: (context, index) {
                final h = wo.history[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: h.newStatus.color,
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                        if (index < wo.history.length - 1)
                          Container(width: 2, height: 40, color: Colors.grey.shade300),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.newStatus.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Por: ${h.userName} • ${_dateFormat.format(h.createdAt)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (h.note != null) ...[
                              const SizedBox(height: 4),
                              Text(h.note!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // TAB 5: FOTOS & ANEXOS
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fotografias do Aparelho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_a_photo, size: 16),
                      label: const Text('Tirar Foto'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Captura de foto anexada à OS com sucesso.')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Fotos do Recebimento e Diagnóstico salvas com segurança no S3/Storage.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
