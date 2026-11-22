import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_repository.dart';
import '../data/models/tenant_info.dart';

enum AuthStatus { initial, unauthenticated, selectingTenant, authenticated }

final authExpiryProvider = StateProvider<int>((ref) => 0);

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? activeTenantId;
  final String? activeTenantName;
  final String? userRole;
  final bool isSubscriptionActive;
  final List<TenantInfo> availableTenants;

  AuthState({
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
    this.userName,
    this.userEmail,
    this.activeTenantId,
    this.activeTenantName,
    this.userRole,
    this.isSubscriptionActive = true,
    this.availableTenants = const [],
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    String? userId,
    String? userName,
    String? userEmail,
    String? activeTenantId,
    String? activeTenantName,
    String? userRole,
    bool? isSubscriptionActive,
    List<TenantInfo>? availableTenants,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      activeTenantId: activeTenantId ?? this.activeTenantId,
      activeTenantName: activeTenantName ?? this.activeTenantName,
      userRole: userRole ?? this.userRole,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      availableTenants: availableTenants ?? this.availableTenants,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthController(authRepo, storage);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final SecureStorageService _storage;

  AuthController(this._authRepo, this._storage) : super(AuthState()) {
    checkInitialStatus();
  }

  Future<void> checkInitialStatus() async {
    final tenantId = await _storage.getTenantId();
    final tenantName = await _storage.getTenantName();
    final userData = await _storage.getUserData();
    final token = await _storage.getAccessToken();

    if (token != null && token.isNotEmpty && userData['id'] != null) {
      final isActive = ! (tenantId ?? '').contains('expired');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        activeTenantId: tenantId,
        activeTenantName: tenantName,
        userId: userData['id'],
        userName: userData['name'],
        userEmail: userData['email'],
        userRole: userData['role'],
        isSubscriptionActive: isActive,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authRepo.login(email: email, password: password);

      if (response.requiresTenantSelection) {
        state = state.copyWith(
          status: AuthStatus.selectingTenant,
          isLoading: false,
          userId: response.userId,
          userName: response.userName,
          userEmail: response.userEmail,
          availableTenants: response.availableTenants,
        );
        return true;
      } else {
        final isActive = !(response.activeTenantId ?? '').contains('expired');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          activeTenantId: response.activeTenantId,
          activeTenantName: response.activeTenantName,
          userId: response.userId,
          userName: response.userName,
          userEmail: response.userEmail,
          userRole: response.userRole,
          isSubscriptionActive: isActive,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> selectTenant(TenantInfo tenant) async {
    state = state.copyWith(isLoading: true);
    await _authRepo.selectTenant(
      tenantId: tenant.id,
      tenantName: tenant.nome,
      role: tenant.perfil,
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      isLoading: false,
      activeTenantId: tenant.id,
      activeTenantName: tenant.nome,
      userRole: tenant.perfil,
      isSubscriptionActive: tenant.isSubscriptionActive,
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepo.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
