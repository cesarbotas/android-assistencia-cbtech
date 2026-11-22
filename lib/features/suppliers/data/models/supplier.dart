class Supplier {
  final String id;
  final String tenantId;
  final String tradeName; // Nome Fantasia
  final String legalName; // Razão Social
  final String? cnpj;
  final String? contactPerson;
  final String phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final int deliveryLeadTimeDays;
  final String? paymentTerms;
  final bool isActive;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.tenantId,
    required this.tradeName,
    required this.legalName,
    this.cnpj,
    this.contactPerson,
    required this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.deliveryLeadTimeDays = 2,
    this.paymentTerms = '30 dias / Boleto / PIX',
    this.isActive = true,
    required this.createdAt,
  });

  Supplier copyWith({
    String? id,
    String? tenantId,
    String? tradeName,
    String? legalName,
    String? cnpj,
    String? contactPerson,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    int? deliveryLeadTimeDays,
    String? paymentTerms,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      tradeName: tradeName ?? this.tradeName,
      legalName: legalName ?? this.legalName,
      cnpj: cnpj ?? this.cnpj,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      address: address ?? this.address,
      deliveryLeadTimeDays: deliveryLeadTimeDays ?? this.deliveryLeadTimeDays,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      tradeName: json['tradeName'] as String,
      legalName: json['legalName'] as String? ?? json['tradeName'] as String,
      cnpj: json['cnpj'] as String?,
      contactPerson: json['contactPerson'] as String?,
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      deliveryLeadTimeDays: json['deliveryLeadTimeDays'] as int? ?? 2,
      paymentTerms: json['paymentTerms'] as String? ?? 'À vista / PIX',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'tradeName': tradeName,
      'legalName': legalName,
      'cnpj': cnpj,
      'contactPerson': contactPerson,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'address': address,
      'deliveryLeadTimeDays': deliveryLeadTimeDays,
      'paymentTerms': paymentTerms,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
