enum TransactionType {
  income('Entrada'),
  expense('Saída');

  const TransactionType(this.label);
  final String label;

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

enum PaymentMethod {
  pix('PIX'),
  creditCard('Cartão de Crédito'),
  debitCard('Cartão de Débito'),
  cash('Dinheiro'),
  bankSlip('Boleto Bancário'),
  transfer('Transferência');

  const PaymentMethod(this.label);
  final String label;
}

enum TransactionCategory {
  service('Serviço / Mão de Obra'),
  part('Peça / Componente'),
  purchase('Compra de Estoque'),
  operatingExpense('Despesa Operacional'),
  other('Outros');

  const TransactionCategory(this.label);
  final String label;
}

class FinancialTransaction {
  final String id;
  final String tenantId;
  final String title;
  final TransactionType type;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final double amount;
  final DateTime date;
  final String? referenceType; // 'work_order', 'purchase_order', 'manual'
  final String? referenceId; // ex: 'OS-0105'
  final String? notes;

  FinancialTransaction({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.type,
    required this.category,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    this.referenceType,
    this.referenceId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'title': title,
      'type': type.name,
      'category': category.name,
      'paymentMethod': paymentMethod.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'referenceType': referenceType,
      'referenceId': referenceId,
      'notes': notes,
    };
  }

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      title: json['title'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.income,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.other,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.pix,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      referenceType: json['referenceType'],
      referenceId: json['referenceId'],
      notes: json['notes'],
    );
  }
}
