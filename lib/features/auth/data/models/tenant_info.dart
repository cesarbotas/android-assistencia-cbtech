class TenantInfo {
  final String id;
  final String nome;
  final String? cnpj;
  final String perfil;

  TenantInfo({
    required this.id,
    required this.nome,
    this.cnpj,
    required this.perfil,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cnpj: json['cnpj'] as String?,
      perfil: json['perfil'] as String? ?? 'Administrador',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'perfil': perfil,
    };
  }
}
