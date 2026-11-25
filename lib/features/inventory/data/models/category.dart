class Category {
  final String id;
  final String name; // 'nome'
  final String? description; // 'descricao'

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['nome'] as String? ?? json['name'] as String? ?? '',
      description: json['descricao'] as String? ?? json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome': name,
      'descricao': description,
    };
  }
}
