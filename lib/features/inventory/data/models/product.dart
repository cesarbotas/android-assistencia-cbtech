class Product {
  final String id;
  final String tenantId;
  final String sku;
  final String name;
  final String category; // Telas, Baterias, Conectores, Câmeras, Placas, Acessórios, Outros
  final String? description;
  final String compatibleModels; // Ex: iPhone 13 / iPhone 13 Pro
  final double salePrice;
  final double costPrice;
  final int currentStock;
  final int minStock;
  final String unit; // UN, PC, KT
  final String? supplierId;
  final String? supplierName;
  final String? supplierPartCode;
  final bool isActive;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.tenantId,
    required this.sku,
    required this.name,
    required this.category,
    this.description,
    required this.compatibleModels,
    required this.salePrice,
    this.costPrice = 0.0,
    required this.currentStock,
    this.minStock = 2,
    this.unit = 'UN',
    this.supplierId,
    this.supplierName,
    this.supplierPartCode,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isLowStock => currentStock <= minStock;

  Product copyWith({
    String? id,
    String? tenantId,
    String? sku,
    String? name,
    String? category,
    String? description,
    String? compatibleModels,
    double? salePrice,
    double? costPrice,
    int? currentStock,
    int? minStock,
    String? unit,
    String? supplierId,
    String? supplierName,
    String? supplierPartCode,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      compatibleModels: compatibleModels ?? this.compatibleModels,
      salePrice: salePrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierPartCode: supplierPartCode ?? this.supplierPartCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Geral',
      description: json['description'] as String?,
      compatibleModels: json['compatibleModels'] as String? ?? 'Geral',
      salePrice: (json['salePrice'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      currentStock: json['currentStock'] as int? ?? 0,
      minStock: json['minStock'] as int? ?? 2,
      unit: json['unit'] as String? ?? 'UN',
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierPartCode: json['supplierPartCode'] as String?,
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
      'sku': sku,
      'name': name,
      'category': category,
      'description': description,
      'compatibleModels': compatibleModels,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'currentStock': currentStock,
      'minStock': minStock,
      'unit': unit,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierPartCode': supplierPartCode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
