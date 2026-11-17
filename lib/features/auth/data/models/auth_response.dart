import 'tenant_info.dart';

class AuthResponse {
  final bool requiresTenantSelection;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? activeTenantId;
  final String? activeTenantName;
  final String? userRole;
  final List<TenantInfo> availableTenants;

  AuthResponse({
    this.requiresTenantSelection = false,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.userName,
    this.userEmail,
    this.activeTenantId,
    this.activeTenantName,
    this.userRole,
    this.availableTenants = const [],
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final tenantsJson = json['availableTenants'] as List<dynamic>? ?? [];
    return AuthResponse(
      requiresTenantSelection: json['requiresTenantSelection'] as bool? ?? false,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      activeTenantId: json['activeTenantId'] as String?,
      activeTenantName: json['activeTenantName'] as String?,
      userRole: json['userRole'] as String?,
      availableTenants: tenantsJson
          .map((t) => TenantInfo.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
