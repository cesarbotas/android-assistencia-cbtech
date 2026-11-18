import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import 'models/financial_transaction.dart';

final financesRepositoryProvider = Provider<FinancesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final authState = ref.watch(authControllerProvider);
  return FinancesRepository(dio, authState.activeTenantId ?? '11111111-1111-1111-1111-111111111111');
});

class FinancesRepository {
  final Dio _dio;
  final String _tenantId;

  FinancesRepository(this._dio, this._tenantId);

  // Mock initial transactions for realistic SaaS experience
  final List<FinancialTransaction> _mockTransactions = [
    FinancialTransaction(
      id: 'tx-001',
      tenantId: '11111111-1111-1111-1111-111111111111',
      title: 'Pagamento OS-0101 (Rodrigo M.)',
      type: TransactionType.income,
      category: TransactionCategory.service,
      paymentMethod: PaymentMethod.pix,
      amount: 150.0,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      referenceType: 'work_order',
      referenceId: 'OS-0101',
      notes: 'Troca de tela iPhone 11',
    ),
    FinancialTransaction(
      id: 'tx-002',
      tenantId: '11111111-1111-1111-1111-111111111111',
      title: 'Adiantamento OS-0104 (Mariana S.)',
      type: TransactionType.income,
      category: TransactionCategory.service,
      paymentMethod: PaymentMethod.creditCard,
      amount: 300.0,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      referenceType: 'work_order',
      referenceId: 'OS-0104',
      notes: 'Sinal para troca de bateria Samsung S21',
    ),
    FinancialTransaction(
      id: 'tx-003',
      tenantId: '11111111-1111-1111-1111-111111111111',
      title: 'Compra de Peças - Fornecedor TotalCell',
      type: TransactionType.expense,
      category: TransactionCategory.purchase,
      paymentMethod: PaymentMethod.bankSlip,
      amount: 1250.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      referenceType: 'purchase_order',
      referenceId: 'PO-0042',
      notes: 'Lote de telas OLED e baterias',
    ),
    FinancialTransaction(
      id: 'tx-004',
      tenantId: '11111111-1111-1111-1111-111111111111',
      title: 'Pagamento OS-0099 (Ana Paula)',
      type: TransactionType.income,
      category: TransactionCategory.part,
      paymentMethod: PaymentMethod.cash,
      amount: 280.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      referenceType: 'work_order',
      referenceId: 'OS-0099',
      notes: 'Conector de carga Motorola Moto G',
    ),
  ];

  Future<List<FinancialTransaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTransactions.where((t) => t.tenantId == _tenantId).toList();
  }

  Future<FinancialTransaction> addTransaction(FinancialTransaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newTx = FinancialTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: _tenantId,
      title: transaction.title,
      type: transaction.type,
      category: transaction.category,
      paymentMethod: transaction.paymentMethod,
      amount: transaction.amount,
      date: transaction.date,
      referenceType: transaction.referenceType,
      referenceId: transaction.referenceId,
      notes: transaction.notes,
    );
    _mockTransactions.insert(0, newTx);
    return newTx;
  }
}
