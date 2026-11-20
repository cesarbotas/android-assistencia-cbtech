import 'tenant_info.dart';

class AuthResponse {
  final bool requiresTenantSelection;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final List<String> roles;
  final String? activeTenantId;
  final String? activeTenantName;
  final String? userRole;
  final List<TenantInfo> availableTenants;

  AuthResponse({
    this.requiresTenantSelection = false,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.userId,
    this.userName,
    this.userEmail,
    this.roles = const [],
    this.activeTenantId,
    this.activeTenantName,
    this.userRole,
    this.availableTenants = const [],
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final rolesList = (userJson?['roles'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final tenantsJson = json['availableTenants'] as List<dynamic>? ?? [];

    return AuthResponse(
      requiresTenantSelection: json['requiresTenantSelection'] as bool? ?? false,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
      userId: userJson?['id'] ?? json['userId'],
      userName: userJson?['nome'] ?? json['userName'],
      userEmail: userJson?['email'] ?? json['userEmail'],
      roles: rolesList,
      activeTenantId: json['activeTenantId'] as String? ?? '11111111-1111-1111-1111-111111111111',
      activeTenantName: json['activeTenantName'] as String? ?? 'CB Tech Matriz',
      userRole: json['userRole'] as String? ?? (rolesList.isNotEmpty ? rolesList.first : 'Administrador'),
      availableTenants: tenantsJson
          .map((t) => TenantInfo.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
