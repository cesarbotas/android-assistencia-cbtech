import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _keyAccessToken = 'cbtech_access_token';
  static const String _keyRefreshToken = 'cbtech_refresh_token';
  static const String _keyTenantId = 'cbtech_tenant_id';
  static const String _keyTenantName = 'cbtech_tenant_name';
  static const String _keyUserId = 'cbtech_user_id';
  static const String _keyUserName = 'cbtech_user_name';
  static const String _keyUserEmail = 'cbtech_user_email';
  static const String _keyUserRole = 'cbtech_user_role';

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Tenant Ativo
  Future<void> saveActiveTenant({required String tenantId, required String tenantName}) async {
    await _storage.write(key: _keyTenantId, value: tenantId);
    await _storage.write(key: _keyTenantName, value: tenantName);
  }

  Future<String?> getTenantId() async {
    return await _storage.read(key: _keyTenantId);
  }

  Future<String?> getTenantName() async {
    return await _storage.read(key: _keyTenantName);
  }

  // Usuário
  Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    required String role,
  }) async {
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<Map<String, String?>> getUserData() async {
    return {
      'id': await _storage.read(key: _keyUserId),
      'name': await _storage.read(key: _keyUserName),
      'email': await _storage.read(key: _keyUserEmail),
      'role': await _storage.read(key: _keyUserRole),
      'tenantId': await _storage.read(key: _keyTenantId),
      'tenantName': await _storage.read(key: _keyTenantName),
    };
  }

  // Limpeza Completa (Logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
