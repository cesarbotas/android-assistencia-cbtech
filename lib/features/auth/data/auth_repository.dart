import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/auth_response.dart';
import 'models/tenant_info.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Chamada estrita à API real (sem bypass/fallback silencioso)
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'senha': password},
      );

      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      if (!authResponse.requiresTenantSelection && authResponse.accessToken != null) {
        await _persistSession(authResponse);
      }
      return authResponse;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ??
                      e.response?.data?['title'] ??
                      e.response?.data?['message'] ??
                      'Falha ao conectar com o servidor da API. Verifique sua conexão e o ambiente.';
      throw ApiException(
        message: message.toString(),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<AuthResponse> selectTenant({
    required String tenantId,
    required String tenantName,
    required String role,
  }) async {
    await _storage.saveActiveTenant(tenantId: tenantId, tenantName: tenantName);
    return AuthResponse(
      activeTenantId: tenantId,
      activeTenantName: tenantName,
      userRole: role,
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: {'refreshToken': await _storage.getRefreshToken() ?? ''},
      );
    } catch (_) {
      // Ignora erro de rede no logout
    } finally {
      await _storage.clearAll();
    }
  }

  Future<void> _persistSession(AuthResponse auth) async {
    if (auth.accessToken != null) {
      await _storage.saveAccessToken(auth.accessToken!);
    }
    if (auth.refreshToken != null) {
      await _storage.saveRefreshToken(auth.refreshToken!);
    }
    if (auth.activeTenantId != null && auth.activeTenantName != null) {
      await _storage.saveActiveTenant(
        tenantId: auth.activeTenantId!,
        tenantName: auth.activeTenantName!,
      );
    }
    if (auth.userId != null) {
      await _storage.saveUserData(
        id: auth.userId!,
        name: auth.userName ?? 'Usuário',
        email: auth.userEmail ?? '',
        role: auth.userRole ?? 'Administrador',
      );
    }
  }
}
