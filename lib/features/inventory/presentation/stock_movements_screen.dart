import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../data/models/stock_movement.dart';
import 'stock_controller.dart';

class StockMovementsScreen extends ConsumerStatefulWidget {
  const StockMovementsScreen({super.key});

  @override
  ConsumerState<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends ConsumerState<StockMovementsScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockControllerProvider);
    final movements = stockState.filteredMovements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato Kardex de Estoque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => ref.read(stockControllerProvider.notifier).loadData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.swap_vert),
        label: const Text('Nova Movimentação'),
        onPressed: () => context.push('/inventory/movements/new'),
      ),
      body: Column(
        children: [
          // Chips de Filtro por Tipo de Movimento
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: stockState.selectedType == null,
                    onSelected: (_) {
                      ref.read(stockControllerProvider.notifier).setTypeFilter(null);
                    },
                  ),
                ),
                ...StockMovementType.values.map((type) {
                  final isSelected = stockState.selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.label),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(stockControllerProvider.notifier).setTypeFilter(type);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de Movimentações
          Expanded(
            child: stockState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : movements.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma movimentação de estoque encontrada.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(stockControllerProvider.notifier).loadData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: movements.length,
                          itemBuilder: (context, index) {
                            final mov = movements[index];
                            final isEntry = mov.type.isEntry;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: mov.type.color.withValues(alpha: 0.12),
                                          child: Icon(mov.type.icon, color: mov.type.color, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mov.productName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              Text(
                                                'SKU: ${mov.productSku}',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isEntry ? '+' : '-'}${mov.quantity}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: mov.type.color,
                                              ),
                                            ),
                                            Text(
                                              'Saldo: ${mov.previousStock} ➔ ${mov.newStock}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Motivo: ${mov.reason}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                              if (mov.workOrderNumber != null)
                                                Text(
                                                  'Ordem vinculada: ${mov.workOrderNumber}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              if (mov.supplierName != null)
                                                Text(
                                                  'Fornecedor: ${mov.supplierName}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                                ),
                                              Text(
                                                '${mov.createdBy} • ${_dateFormat.format(mov.createdAt)}',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _currency.format(mov.totalValue),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
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
