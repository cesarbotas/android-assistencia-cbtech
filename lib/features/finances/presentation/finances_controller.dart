import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/finances_repository.dart';
import '../data/models/financial_transaction.dart';

final financesControllerProvider = StateNotifierProvider<FinancesController, FinancesState>((ref) {
  final repo = ref.watch(financesRepositoryProvider);
  return FinancesController(repo);
});

class FinancesState {
  final List<FinancialTransaction> transactions;
  final bool isLoading;
  final TransactionType? filterType;
  final PaymentMethod? filterPaymentMethod;

  FinancesState({
    this.transactions = const [],
    this.isLoading = false,
    this.filterType,
    this.filterPaymentMethod,
  });

  FinancesState copyWith({
    List<FinancialTransaction>? transactions,
    bool? isLoading,
    Object? filterType = const _Sentinel(),
    Object? filterPaymentMethod = const _Sentinel(),
  }) {
    return FinancesState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      filterType: filterType is _Sentinel ? this.filterType : (filterType as TransactionType?),
      filterPaymentMethod: filterPaymentMethod is _Sentinel ? this.filterPaymentMethod : (filterPaymentMethod as PaymentMethod?),
    );
  }

  List<FinancialTransaction> get filteredTransactions {
    return transactions.where((t) {
      if (filterType != null && t.type != filterType) return false;
      if (filterPaymentMethod != null && t.paymentMethod != filterPaymentMethod) return false;
      return true;
    }).toList();
  }

  double get totalIncome {
    return transactions.where((t) => t.type.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return transactions.where((t) => t.type.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentBalance => totalIncome - totalExpense;
}

class _Sentinel {
  const _Sentinel();
}

class FinancesController extends StateNotifier<FinancesState> {
  final FinancesRepository _repository;

  FinancesController(this._repository) : super(FinancesState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    try {
      final txs = await _repository.getTransactions();
      state = state.copyWith(transactions: txs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilterType(TransactionType? type) {
    state = state.copyWith(filterType: type);
  }

  void setFilterPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(filterPaymentMethod: method);
  }

  Future<bool> addTransaction({
    required String title,
    required TransactionType type,
    required TransactionCategory category,
    required PaymentMethod paymentMethod,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      final newTx = FinancialTransaction(
        id: '',
        title: title,
        type: type,
        category: category.label,
        paymentMethod: paymentMethod,
        amount: amount,
        date: DateTime.now(),
        referenceType: referenceType ?? 'manual',
        referenceId: referenceId,
        notes: notes,
      );
      await _repository.addTransaction(newTx);
      await loadTransactions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
    } catch (_) {}
  }
}
