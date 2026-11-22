class CustomerDevice {
  final String id;
  final String tenantId;
  final String customerId;
  final String customerName;
  final String brandName;
  final String modelName;
  final String? imei1;
  final String? imei2;
  final String? serialNumber;
  final String? color;
  final String? storage;
  final String? notes;
  final DateTime createdAt;

  CustomerDevice({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.customerName,
    required this.brandName,
    required this.modelName,
    this.imei1,
    this.imei2,
    this.serialNumber,
    this.color,
    this.storage,
    this.notes,
    required this.createdAt,
  });

  CustomerDevice copyWith({
    String? id,
    String? tenantId,
    String? customerId,
    String? customerName,
    String? brandName,
    String? modelName,
    String? imei1,
    String? imei2,
    String? serialNumber,
    String? color,
    String? storage,
    String? notes,
    DateTime? createdAt,
  }) {
    return CustomerDevice(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      brandName: brandName ?? this.brandName,
      modelName: modelName ?? this.modelName,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      serialNumber: serialNumber ?? this.serialNumber,
      color: color ?? this.color,
      storage: storage ?? this.storage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomerDevice.fromJson(Map<String, dynamic> json) {
    return CustomerDevice(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      modelName: json['modelName'] as String? ?? '',
      imei1: json['imei1'] as String?,
      imei2: json['imei2'] as String?,
      serialNumber: json['serialNumber'] as String?,
      color: json['color'] as String?,
      storage: json['storage'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'customerId': customerId,
      'customerName': customerName,
      'brandName': brandName,
      'modelName': modelName,
      'imei1': imei1,
      'imei2': imei2,
      'serialNumber': serialNumber,
      'color': color,
      'storage': storage,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
