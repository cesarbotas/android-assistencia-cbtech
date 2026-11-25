import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/work_order.dart';
import '../data/models/work_order_status.dart';
import 'work_orders_controller.dart';

class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen> {
  final _searchController = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(workOrdersControllerProvider.notifier).loadWorkOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _shareViaWhatsApp(WorkOrder wo) {
    final budgetStr = wo.currentBudget != null
        ? 'Valor total: ${_currency.format(wo.currentBudget!.grandTotal)}'
        : 'Orçamento em elaboração';

    final message = '''
*CB Tech — Atualização de Ordem de Serviço*
Olá, ${wo.customerName}!
Sua ordem *${wo.sequentialNumber}* está atualmente com o status: *${wo.status.label.toUpperCase()}*.
Aparelho: ${wo.deviceBrand} ${wo.deviceModel}
Defeito: ${wo.defectReported}
$budgetStr

Caso tenha dúvidas, estamos à disposição!
''';
    Share.share(message, subject: 'Status da ${wo.sequentialNumber} - CB Tech');
  }

  @override
  Widget build(BuildContext context) {
    final woState = ref.watch(workOrdersControllerProvider);
    final workOrders = woState.filteredWorkOrders;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: () => ref.read(workOrdersControllerProvider.notifier).loadWorkOrders(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => context.push('/work-orders/new'),
      ),
      body: Column(
        children: [
          // Campo de Busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por OS, cliente, aparelho ou defeito...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(workOrdersControllerProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (q) {
                ref.read(workOrdersControllerProvider.notifier).setSearchQuery(q);
              },
            ),
          ),

          // Chips de Filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: woState.statusFilter == null,
                    onSelected: (_) {
                      ref.read(workOrdersControllerProvider.notifier).setStatusFilter(null);
                    },
                  ),
                ),
                ...WorkOrderStatus.values.map((status) {
                  final isSelected = woState.statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.label),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(workOrdersControllerProvider.notifier).setStatusFilter(status);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de OS
          Expanded(
            child: woState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : woState.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(woState.errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref.read(workOrdersControllerProvider.notifier).loadWorkOrders(),
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : workOrders.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma ordem de serviço encontrada.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(workOrdersControllerProvider.notifier).loadWorkOrders(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: workOrders.length,
                              itemBuilder: (context, index) {
                                final os = workOrders[index];
                                final hasBudget = os.currentBudget != null;
                                final totalFormatted = hasBudget
                                    ? _currency.format(os.currentBudget!.grandTotal)
                                    : 'Aguardando Orçamento';

                                return Card(
                                  elevation: 1.5,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => context.push('/work-orders/detail', extra: os.id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    os.sequentialNumber,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  if (os.priority == 'Urgente' || os.priority == 'Alta') ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: os.priority == 'Urgente'
                                                            ? Colors.red.shade100
                                                            : Colors.orange.shade100,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        os.priority.toUpperCase(),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: os.priority == 'Urgente'
                                                              ? Colors.red.shade900
                                                              : Colors.orange.shade900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              StatusBadge(status: os.status.label),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.person, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  os.customerName,
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: const Icon(Icons.share, size: 18, color: Color(0xFF25D366)),
                                                tooltip: 'Enviar status no WhatsApp',
                                                onPressed: () => _shareViaWhatsApp(os),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.smartphone, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${os.deviceBrand} ${os.deviceModel}',
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            os.defectReported,
                                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Divider(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Entrada: ${_dateFormat.format(os.createdAt)}',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                              Text(
                                                totalFormatted,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: hasBudget ? Colors.green.shade800 : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
