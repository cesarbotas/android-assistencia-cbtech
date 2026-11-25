import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/financial_transaction.dart';

final financesRepositoryProvider = Provider<FinancesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return FinancesRepository(dio);
});

class FinancesRepository {
  final Dio _dio;

  FinancesRepository(this._dio);

  final List<FinancialTransaction> _localTransactions = [
    FinancialTransaction(
      id: 'tx-001',
      title: 'Pagamento OS-0101 (Rodrigo M.)',
      type: TransactionType.income,
      category: 'Serviços',
      paymentMethod: PaymentMethod.pix,
      amount: 150.0,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FinancialTransaction(
      id: 'tx-002',
      title: 'Compra de Peças - TotalCell',
      type: TransactionType.expense,
      category: 'Estoque',
      paymentMethod: PaymentMethod.bankSlip,
      amount: 1250.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<FinancialTransaction>> getTransactions({int pagina = 1, int tamanho = 100, String? search}) async {
    try {
      final Map<String, dynamic> params = {
        'pagina': pagina,
        'tamanho': tamanho,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;

      final res = await _dio.get(ApiEndpoints.payments, queryParameters: params);
      final data = res.data;
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['itens'] != null) {
        items = data['itens'] as List<dynamic>;
      } else if (data is Map && data['items'] != null) {
        items = data['items'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        items = data['data'] as List<dynamic>;
      }

      return items.map((t) => FinancialTransaction.fromJson(t as Map<String, dynamic>)).toList();
    } catch (_) {
      return _localTransactions;
    }
  }

  Future<FinancialTransaction> addTransaction(FinancialTransaction transaction) async {
    try {
      final res = await _dio.post(ApiEndpoints.payments, data: transaction.toJson());
      if (res.data is Map<String, dynamic> && res.data['id'] != null) {
        return FinancialTransaction.fromJson(res.data as Map<String, dynamic>);
      }
      return transaction;
    } catch (_) {
      final newTx = FinancialTransaction(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        title: transaction.title,
        type: transaction.type,
        category: transaction.category,
        paymentMethod: transaction.paymentMethod,
        amount: transaction.amount,
        date: DateTime.now(),
        customerId: transaction.customerId,
      );
      _localTransactions.insert(0, newTx);
      return newTx;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.payments}/$id');
    } catch (_) {
      _localTransactions.removeWhere((t) => t.id == id);
    }
  }
}
