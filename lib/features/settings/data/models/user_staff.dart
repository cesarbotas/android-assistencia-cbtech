enum UserRole {
  admin('Administrador', 'Acesso total a todas as funções e financeiro'),
  technician('Técnico', 'Gestão de ordens de serviço, diagnósticos e peças'),
  attendant('Atendente', 'Abertura de OS, cadastro de clientes e consulta');

  const UserRole(this.label, this.description);
  final String label;
  final String description;
}

class UserStaff {
  final String id;
  final String tenantId;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  UserStaff({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserStaff.fromJson(Map<String, dynamic> json) {
    return UserStaff(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.attendant,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
