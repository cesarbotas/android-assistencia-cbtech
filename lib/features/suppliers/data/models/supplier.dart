class SupplierAddress {
  final String? id;
  final String? fornecedorId;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  SupplierAddress({
    this.id,
    this.fornecedorId,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory SupplierAddress.fromJson(Map<String, dynamic> json) {
    return SupplierAddress(
      id: json['id'] as String?,
      fornecedorId: json['fornecedorId'] as String?,
      logradouro: json['logradouro'] as String? ?? '',
      numero: json['numero'] as String? ?? '',
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      cep: json['cep'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (fornecedorId != null) 'fornecedorId': fornecedorId,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
    };
  }
}

class Supplier {
  final String id;
  final String tradeName; // 'nomeFantasia'
  final String legalName; // 'razaoSocial'
  final String? cnpj;
  final String? contactPerson; // 'contato'
  final String phone; // 'telefone'
  final String? whatsapp;
  final String? email;
  final SupplierAddress? endereco; // 'endereco'
  final int deliveryLeadTimeDays; // 'prazoEntregaDias'
  final String? paymentTerms; // 'condicaoPagamento'
  final bool isActive; // 'ativo'
  final DateTime createdAt; // 'criadoEm'

  // Backward compatibility getters for existing UI code
  String get tenantId => '11111111-1111-1111-1111-111111111111';
  String? get address => endereco != null ? '${endereco!.logradouro}, ${endereco!.numero} - ${endereco!.cidade}/${endereco!.estado}' : null;

  Supplier({
    required this.id,
    required this.tradeName,
    required this.legalName,
    this.cnpj,
    this.contactPerson,
    required this.phone,
    this.whatsapp,
    this.email,
    this.endereco,
    this.deliveryLeadTimeDays = 2,
    this.paymentTerms,
    this.isActive = true,
    required this.createdAt,
    String? tenantId,
    String? address,
  });

  Supplier copyWith({
    String? id,
    String? tradeName,
    String? legalName,
    String? cnpj,
    String? contactPerson,
    String? phone,
    String? whatsapp,
    String? email,
    SupplierAddress? endereco,
    int? deliveryLeadTimeDays,
    String? paymentTerms,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      tradeName: tradeName ?? this.tradeName,
      legalName: legalName ?? this.legalName,
      cnpj: cnpj ?? this.cnpj,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      deliveryLeadTimeDays: deliveryLeadTimeDays ?? this.deliveryLeadTimeDays,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    final enderecoJson = json['endereco'] as Map<String, dynamic>?;
    return Supplier(
      id: json['id'] as String? ?? '',
      tradeName: json['nomeFantasia'] as String? ?? json['tradeName'] as String? ?? '',
      legalName: json['razaoSocial'] as String? ?? json['legalName'] as String? ?? '',
      cnpj: json['cnpj'] as String?,
      contactPerson: json['contato'] as String? ?? json['contactPerson'] as String?,
      phone: json['telefone'] as String? ?? json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      endereco: enderecoJson != null ? SupplierAddress.fromJson(enderecoJson) : null,
      deliveryLeadTimeDays: json['prazoEntregaDias'] as int? ?? json['deliveryLeadTimeDays'] as int? ?? 2,
      paymentTerms: json['condicaoPagamento'] as String? ?? json['paymentTerms'] as String?,
      isActive: json['ativo'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nomeFantasia': tradeName,
      'razaoSocial': legalName,
      'cnpj': cnpj,
      'contato': contactPerson,
      'telefone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'endereco': endereco?.toJson() ??
          {
            'logradouro': 'Rua Principal',
            'numero': '100',
            'complemento': null,
            'bairro': 'Centro',
            'cidade': 'São Paulo',
            'estado': 'SP',
            'cep': '01001000',
          },
      'prazoEntregaDias': deliveryLeadTimeDays,
      'condicaoPagamento': paymentTerms ?? 'PIX / Boleto',
      'ativo': isActive,
    };
  }
}
