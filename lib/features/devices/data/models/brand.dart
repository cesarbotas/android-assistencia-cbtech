class Brand {
  final String id;
  final String name;
  final bool isGlobal;
  final String? tenantId;

  Brand({
    required this.id,
    required this.name,
    this.isGlobal = true,
    this.tenantId,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as String,
      name: json['name'] as String,
      isGlobal: json['isGlobal'] as bool? ?? true,
      tenantId: json['tenantId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isGlobal': isGlobal,
      'tenantId': tenantId,
    };
  }
}
