class CustomerDevice {
  final String id;
  final String customerId; // 'clienteId'
  final String customerName; // 'nomeCliente'
  final String brandId; // 'marcaId'
  final String brandName; // 'nomeMarca'
  final String modelName; // 'modelo'
  final String? imei1;
  final String? imei2;
  final String? serialNumber; // 'numeroSerie'
  final String? color; // 'cor'
  final String? screenPassword; // 'senhaTela'
  final bool isActive; // 'ativo'
  final DateTime createdAt; // 'criadoEm'

  // Backward compatibility getters & fields
  final String? _tenantId;
  final String? _storage;
  final String? _notes;

  String get tenantId => _tenantId ?? '11111111-1111-1111-1111-111111111111';
  String? get storage => _storage;
  String? get notes => _notes;

  CustomerDevice({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.brandId = '00000000-0000-0000-0000-000000000000',
    required this.brandName,
    required this.modelName,
    this.imei1,
    this.imei2,
    this.serialNumber,
    this.color,
    this.screenPassword,
    this.isActive = true,
    required this.createdAt,
    String? tenantId,
    String? storage,
    String? notes,
  })  : _tenantId = tenantId,
        _storage = storage,
        _notes = notes;

  CustomerDevice copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? brandId,
    String? brandName,
    String? modelName,
    String? imei1,
    String? imei2,
    String? serialNumber,
    String? color,
    String? screenPassword,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CustomerDevice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      modelName: modelName ?? this.modelName,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      serialNumber: serialNumber ?? this.serialNumber,
      color: color ?? this.color,
      screenPassword: screenPassword ?? this.screenPassword,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomerDevice.fromJson(Map<String, dynamic> json) {
    return CustomerDevice(
      id: json['id'] as String? ?? '',
      customerId: json['clienteId'] as String? ?? json['customerId'] as String? ?? '',
      customerName: json['nomeCliente'] as String? ?? json['customerName'] as String? ?? '',
      brandId: json['marcaId'] as String? ?? json['brandId'] as String? ?? '',
      brandName: json['nomeMarca'] as String? ?? json['brandName'] as String? ?? '',
      modelName: json['modelo'] as String? ?? json['modelName'] as String? ?? '',
      imei1: json['imei1'] as String?,
      imei2: json['imei2'] as String?,
      serialNumber: json['numeroSerie'] as String? ?? json['serialNumber'] as String?,
      color: json['cor'] as String? ?? json['color'] as String?,
      screenPassword: json['senhaTela'] as String?,
      isActive: json['ativo'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'clienteId': customerId,
      'marcaId': brandId.isNotEmpty ? brandId : '00000000-0000-0000-0000-000000000000',
      'modelo': modelName,
      'cor': color,
      'imei1': imei1,
      'imei2': imei2,
      'numeroSerie': serialNumber,
      'senhaTela': screenPassword,
      'ativo': isActive,
    };
  }
}
