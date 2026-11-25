class ServiceItem {
  final String id;
  final String name; // 'nome'
  final String categoryServiceId; // 'categoriaServicoId'
  final String? description; // 'descricao'
  final double defaultPrice; // 'precoSugerido'
  final int estimatedTimeMinutes; // 'tempoEstimadoMinutos'
  final bool isActive; // 'ativo'
  final DateTime createdAt;

  // Backward compatibility getters & fields
  final String? _tenantId;
  final String? _category;

  String get tenantId => _tenantId ?? '11111111-1111-1111-1111-111111111111';
  String get category => _category ?? 'Geral';

  ServiceItem({
    required this.id,
    required this.name,
    this.categoryServiceId = '00000000-0000-0000-0000-000000000000',
    this.description,
    required this.defaultPrice,
    this.estimatedTimeMinutes = 60,
    this.isActive = true,
    required this.createdAt,
    String? tenantId,
    String? category,
  })  : _tenantId = tenantId,
        _category = category;

  ServiceItem copyWith({
    String? id,
    String? name,
    String? categoryServiceId,
    String? description,
    double? defaultPrice,
    int? estimatedTimeMinutes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryServiceId: categoryServiceId ?? this.categoryServiceId,
      description: description ?? this.description,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String? ?? '',
      name: json['nome'] as String? ?? json['name'] as String? ?? '',
      categoryServiceId: json['categoriaServicoId'] as String? ?? json['categoryServiceId'] as String? ?? '',
      description: json['descricao'] as String? ?? json['description'] as String?,
      defaultPrice: (json['precoSugerido'] as num?)?.toDouble() ?? (json['defaultPrice'] as num?)?.toDouble() ?? 0.0,
      estimatedTimeMinutes: json['tempoEstimadoMinutos'] as int? ?? json['estimatedTimeMinutes'] as int? ?? 60,
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
      'categoriaServicoId': categoryServiceId.isNotEmpty ? categoryServiceId : '00000000-0000-0000-0000-000000000000',
      'descricao': description,
      'precoSugerido': defaultPrice,
      'tempoEstimadoMinutos': estimatedTimeMinutes,
      'ativo': isActive,
    };
  }
}
