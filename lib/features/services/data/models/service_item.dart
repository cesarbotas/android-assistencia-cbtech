class ServiceItem {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String category; // Troca de Peça, Reparo em Placa, Limpeza/Banho, Software/Reset, Outros
  final double defaultPrice;
  final int estimatedTimeMinutes;
  final bool isActive;
  final DateTime createdAt;

  ServiceItem({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.category = 'Troca de Peça',
    required this.defaultPrice,
    this.estimatedTimeMinutes = 60,
    this.isActive = true,
    required this.createdAt,
  });

  ServiceItem copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? description,
    String? category,
    double? defaultPrice,
    int? estimatedTimeMinutes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Geral',
      defaultPrice: (json['defaultPrice'] as num).toDouble(),
      estimatedTimeMinutes: json['estimatedTimeMinutes'] as int? ?? 60,
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
      'name': name,
      'description': description,
      'category': category,
      'defaultPrice': defaultPrice,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
