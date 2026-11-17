class Customer {
  final String id;
  final String tenantId;
  final String name;
  final String? cpfCnpj;
  final String phone;
  final String? whatsapp;
  final String? email;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final int devicesCount;

  Customer({
    required this.id,
    required this.tenantId,
    required this.name,
    this.cpfCnpj,
    required this.phone,
    this.whatsapp,
    this.email,
    this.street,
    this.number,
    this.neighborhood,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    this.devicesCount = 0,
  });

  Customer copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? cpfCnpj,
    String? phone,
    String? whatsapp,
    String? email,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    int? devicesCount,
  }) {
    return Customer(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      devicesCount: devicesCount ?? this.devicesCount,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String,
      cpfCnpj: json['cpfCnpj'] as String?,
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      street: json['street'] as String?,
      number: json['number'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      devicesCount: json['devicesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'cpfCnpj': cpfCnpj,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
