class TenantInfo {
  final String id;
  final String nome;
  final String? cnpj;
  final String perfil;
  final bool isSubscriptionActive;
  final String? primaryColorHex;
  final String? logoUrl;

  TenantInfo({
    required this.id,
    required this.nome,
    this.cnpj,
    required this.perfil,
    this.isSubscriptionActive = true,
    this.primaryColorHex,
    this.logoUrl,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cnpj: json['cnpj'] as String?,
      perfil: json['perfil'] as String? ?? 'Administrador',
      isSubscriptionActive: json['isSubscriptionActive'] as bool? ?? true,
      primaryColorHex: json['primaryColorHex'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'perfil': perfil,
      'isSubscriptionActive': isSubscriptionActive,
      'primaryColorHex': primaryColorHex,
      'logoUrl': logoUrl,
    };
  }
}
