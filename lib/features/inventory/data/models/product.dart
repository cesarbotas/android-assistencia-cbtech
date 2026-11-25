class Product {
  final String id;
  final String name; // 'nome'
  final String sku;
  final String? barcode; // 'codigoBarras'
  final String categoryId; // 'categoriaId'
  final String supplierId; // 'fornecedorId'
  final double costPrice; // 'precoCusto'
  final double salePrice; // 'precoVenda'
  final int currentStock; // 'estoqueAtual'
  final int minStock; // 'estoqueMinimo'
  final String unit; // 'unidadeMedida'
  final bool isActive; // 'ativo'
  final DateTime createdAt; // 'criadoEm'

  // Backward compatibility getters & fields
  final String? _tenantId;
  final String? _category;
  final String? _compatibleModels;
  final String? _description;
  final String? _supplierName;
  final String? _supplierPartCode;

  String get tenantId => _tenantId ?? '11111111-1111-1111-1111-111111111111';
  String get category => _category ?? 'Geral';
  String get compatibleModels => _compatibleModels ?? 'Geral';
  String? get description => _description;
  String? get supplierName => _supplierName;
  String? get supplierPartCode => _supplierPartCode;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.categoryId = '00000000-0000-0000-0000-000000000000',
    this.supplierId = '00000000-0000-0000-0000-000000000000',
    required this.costPrice,
    required this.salePrice,
    required this.currentStock,
    this.minStock = 2,
    this.unit = 'UN',
    this.isActive = true,
    required this.createdAt,
    String? tenantId,
    String? category,
    String? compatibleModels,
    String? description,
    String? supplierName,
    String? supplierPartCode,
  })  : _tenantId = tenantId,
        _category = category,
        _compatibleModels = compatibleModels,
        _description = description,
        _supplierName = supplierName,
        _supplierPartCode = supplierPartCode;

  bool get isLowStock => currentStock <= minStock;

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? supplierId,
    double? costPrice,
    double? salePrice,
    int? currentStock,
    int? minStock,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['nome'] as String? ?? json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      barcode: json['codigoBarras'] as String? ?? json['barcode'] as String?,
      categoryId: json['categoriaId'] as String? ?? json['categoryId'] as String? ?? '',
      supplierId: json['fornecedorId'] as String? ?? json['supplierId'] as String? ?? '',
      costPrice: (json['precoCusto'] as num?)?.toDouble() ?? (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['precoVenda'] as num?)?.toDouble() ?? (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      currentStock: json['estoqueAtual'] as int? ?? json['currentStock'] as int? ?? 0,
      minStock: json['estoqueMinimo'] as int? ?? json['minStock'] as int? ?? 2,
      unit: json['unidadeMedida'] as String? ?? json['unit'] as String? ?? 'UN',
      isActive: json['ativo'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome': name,
      'sku': sku,
      'codigoBarras': barcode ?? '',
      'categoriaId': categoryId.isNotEmpty ? categoryId : '00000000-0000-0000-0000-000000000000',
      'fornecedorId': supplierId.isNotEmpty ? supplierId : '00000000-0000-0000-0000-000000000000',
      'precoCusto': costPrice,
      'precoVenda': salePrice,
      'estoqueAtual': currentStock,
      'estoqueMinimo': minStock,
      'unidadeMedida': unit,
      'ativo': isActive,
    };
  }
}
