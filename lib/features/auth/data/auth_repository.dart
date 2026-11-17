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
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      if (!authResponse.requiresTenantSelection && authResponse.accessToken != null) {
        await _persistSession(authResponse);
      }
      return authResponse;
    } on DioException catch (e) {
      // Modo de demonstração / Fallback quando backend offline no MVP
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _fallbackMockLogin(email, password);
      }

      final message = e.response?.data?['detail'] ?? 'Falha ao autenticar. Verifique seus dados.';
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
      await _dio.post(ApiEndpoints.logout);
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

  // Fallback para permitir navegação completa mesmo antes do backend remoto ser publicado
  Future<AuthResponse> _fallbackMockLogin(String email, String password) async {
    final mockTenants = [
      TenantInfo(
        id: '11111111-1111-1111-1111-111111111111',
        nome: 'CB Tech Matriz (Centro)',
        cnpj: '12.345.678/0001-99',
        perfil: 'Administrador',
      ),
      TenantInfo(
        id: '22222222-2222-2222-2222-222222222222',
        nome: 'CB Tech Express (Shopping)',
        cnpj: '12.345.678/0002-88',
        perfil: 'Técnico',
      ),
    ];

    final authResponse = AuthResponse(
      requiresTenantSelection: true,
      userId: '99999999-9999-9999-9999-999999999999',
      userName: 'Técnico Especialista',
      userEmail: email,
      availableTenants: mockTenants,
    );

    return authResponse;
  }
}
