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
  final String title; // 'descricao'
  final TransactionType type; // 'tipo' (RECEITA / DESPESA)
  final String category; // 'categoria'
  final PaymentMethod paymentMethod; // 'formaPagamento'
  final double amount; // 'valor'
  final DateTime date; // 'criadoEm'
  final String? customerId; // 'clienteId'

  // Backward compatibility fields & getters
  final String? _tenantId;
  final TransactionCategory? _categoryEnum;
  final String? _referenceType;
  final String? _referenceId;
  final String? _notes;

  String get tenantId => _tenantId ?? '11111111-1111-1111-1111-111111111111';
  TransactionCategory get categoryEnum => _categoryEnum ?? TransactionCategory.other;
  String? get referenceType => _referenceType;
  String? get referenceId => _referenceId;
  String? get notes => _notes;

  FinancialTransaction({
    required this.id,
    required this.title,
    required this.type,
    required dynamic category,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    this.customerId,
    String? tenantId,
    TransactionCategory? categoryEnum,
    String? referenceType,
    String? referenceId,
    String? notes,
  })  : category = category is TransactionCategory ? category.label : (category as String? ?? 'Geral'),
        _tenantId = tenantId,
        _categoryEnum = category is TransactionCategory ? category : (categoryEnum ?? TransactionCategory.other),
        _referenceType = referenceType,
        _referenceId = referenceId,
        _notes = notes;

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    final tipoStr = (json['tipo'] as String? ?? 'RECEITA').toUpperCase();
    final tipo = tipoStr.contains('REC') || tipoStr == 'RECEITA' ? TransactionType.income : TransactionType.expense;

    final pagStr = (json['formaPagamento'] as String? ?? 'PIX').toUpperCase();
    PaymentMethod pm = PaymentMethod.pix;
    if (pagStr.contains('CREDITO')) pm = PaymentMethod.creditCard;
    if (pagStr.contains('DEBITO')) pm = PaymentMethod.debitCard;
    if (pagStr.contains('DINHEIRO')) pm = PaymentMethod.cash;
    if (pagStr.contains('BOLETO')) pm = PaymentMethod.bankSlip;
    if (pagStr.contains('TRANSFERENCIA')) pm = PaymentMethod.transfer;

    return FinancialTransaction(
      id: json['id'] as String? ?? '',
      title: json['descricao'] as String? ?? json['title'] as String? ?? '',
      type: tipo,
      category: json['categoria'] as String? ?? 'Geral',
      paymentMethod: pm,
      amount: (json['valor'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
      customerId: json['clienteId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'tipo': type == TransactionType.income ? 'RECEITA' : 'DESPESA',
      'descricao': title,
      'categoria': category,
      'valor': amount,
      'formaPagamento': paymentMethod.name.toUpperCase(),
      'clienteId': customerId,
      'status': 'PAGO',
    };
  }
}
