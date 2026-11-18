import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/models/financial_transaction.dart';
import 'finances_controller.dart';
import 'transaction_form_screen.dart';

class FinancesScreen extends ConsumerStatefulWidget {
  const FinancesScreen({super.key});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financesControllerProvider);
    final controller = ref.read(financesControllerProvider.notifier);
    final transactions = state.filteredTransactions;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Controle Financeiro & Caixa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => controller.loadTransactions(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Lançamento'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Card Balanço
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo em Caixa Atual', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      _currencyFormat.format(state.currentBalance),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Entradas', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text(_currencyFormat.format(state.totalIncome), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saídas / Despesas', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text(_currencyFormat.format(state.totalExpense), style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filtros por Tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: state.filterType == null,
                  onSelected: (_) => controller.setFilterType(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Entradas'),
                  selected: state.filterType == TransactionType.income,
                  onSelected: (_) => controller.setFilterType(TransactionType.income),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Saídas'),
                  selected: state.filterType == TransactionType.expense,
                  onSelected: (_) => controller.setFilterType(TransactionType.expense),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Lista de Transações
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma transação financeira encontrada.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.loadTransactions(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            final isIncome = tx.type.isIncome;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                  child: Icon(
                                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isIncome ? Colors.green : Colors.red,
                                    size: 18,
                                  ),
                                ),
                                title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                subtitle: Text(
                                  '${tx.paymentMethod.label} • ${_dateFormat.format(tx.date)}${tx.referenceId != null ? ' (${tx.referenceId})' : ''}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'} ${_currencyFormat.format(tx.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isIncome ? Colors.green.shade800 : Colors.red.shade800,
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
