class Address {
  final String? id;
  final String? clienteId;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  Address({
    this.id,
    this.clienteId,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String?,
      clienteId: json['clienteId'] as String?,
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
      if (clienteId != null) 'clienteId': clienteId,
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

class Customer {
  final String id;
  final String name; // 'nome'
  final String email; // 'email'
  final String phone; // 'telefone'
  final Address? endereco; // 'endereco'
  final DateTime createdAt; // 'criadoEm'

  // Backward compatibility fields & getters for existing UI code
  final String? _cpfCnpj;
  final String? _street;
  final String? _number;
  final String? _neighborhood;
  final String? _city;
  final String? _state;
  final String? _zipCode;
  final String? _notes;
  final bool _isActive;
  final int _devicesCount;

  String get tenantId => '11111111-1111-1111-1111-111111111111';
  String? get cpfCnpj => _cpfCnpj;
  String? get whatsapp => phone;
  String? get street => _street ?? endereco?.logradouro;
  String? get number => _number ?? endereco?.numero;
  String? get neighborhood => _neighborhood ?? endereco?.bairro;
  String? get city => _city ?? endereco?.cidade;
  String? get state => _state ?? endereco?.estado;
  String? get zipCode => _zipCode ?? endereco?.cep;
  String? get notes => _notes;
  bool get isActive => _isActive;
  int get devicesCount => _devicesCount;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.endereco,
    required this.createdAt,
    String? tenantId,
    String? cpfCnpj,
    String? whatsapp,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? notes,
    bool? isActive,
    int? devicesCount,
  })  : _cpfCnpj = cpfCnpj,
        _street = street,
        _number = number,
        _neighborhood = neighborhood,
        _city = city,
        _state = state,
        _zipCode = zipCode,
        _notes = notes,
        _isActive = isActive ?? true,
        _devicesCount = devicesCount ?? 0;

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    Address? endereco,
    DateTime? createdAt,
    String? tenantId,
    String? cpfCnpj,
    String? whatsapp,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? notes,
    bool? isActive,
    int? devicesCount,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      endereco: endereco ?? this.endereco,
      createdAt: createdAt ?? this.createdAt,
      cpfCnpj: cpfCnpj ?? _cpfCnpj,
      street: street ?? _street,
      number: number ?? _number,
      neighborhood: neighborhood ?? _neighborhood,
      city: city ?? _city,
      state: state ?? _state,
      zipCode: zipCode ?? _zipCode,
      notes: notes ?? _notes,
      isActive: isActive ?? _isActive,
      devicesCount: devicesCount ?? _devicesCount,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    final enderecoJson = json['endereco'] as Map<String, dynamic>?;
    final addressObj = enderecoJson != null ? Address.fromJson(enderecoJson) : null;

    return Customer(
      id: json['id'] as String? ?? '',
      name: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['telefone'] as String? ?? '',
      endereco: addressObj,
      createdAt: json['criadoEm'] != null ? DateTime.parse(json['criadoEm'] as String) : DateTime.now(),
      street: addressObj?.logradouro,
      number: addressObj?.numero,
      neighborhood: addressObj?.bairro,
      city: addressObj?.cidade,
      state: addressObj?.estado,
      zipCode: addressObj?.cep,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome': name,
      'email': email,
      'telefone': phone,
      'endereco': endereco?.toJson() ??
          {
            'logradouro': _street ?? '',
            'numero': _number ?? '',
            'complemento': null,
            'bairro': _neighborhood ?? '',
            'cidade': _city ?? 'São Paulo',
            'estado': _state ?? 'SP',
            'cep': _zipCode ?? '',
          },
    };
  }
}
