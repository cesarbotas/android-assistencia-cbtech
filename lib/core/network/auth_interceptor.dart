import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final VoidCallback onUnauthorized;
  bool _isRefreshing = false;

  AuthInterceptor(this._storage, this.onUnauthorized);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final tenantId = await _storage.getTenantId();
    if (tenantId != null && tenantId.isNotEmpty) {
      options.headers['X-Tenant-Id'] = tenantId;
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;

    // Se receber 401 e não for nas rotas de login ou refresh
    if (err.response?.statusCode == 401 && !path.contains('/auth/login') && !path.contains('/auth/refresh')) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final dio = Dio(BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              headers: {'Content-Type': 'application/json'},
            ));

            final response = await dio.post(
              ApiEndpoints.refreshToken,
              data: {'refreshToken': refreshToken},
            );

            if (response.statusCode == 200 && response.data != null) {
              final data = response.data;
              final newAccessToken = data['accessToken'] as String?;
              final newRefreshToken = data['refreshToken'] as String?;

              if (newAccessToken != null) {
                await _storage.saveAccessToken(newAccessToken);
                if (newRefreshToken != null) {
                  await _storage.saveRefreshToken(newRefreshToken);
                }

                _isRefreshing = false;

                // Refaz a requisição original com o novo token
                final opts = err.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';

                final dioRetry = Dio(BaseOptions(baseUrl: opts.baseUrl));
                final cloneReq = await dioRetry.request(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(method: opts.method, headers: opts.headers),
                );
                return handler.resolve(cloneReq);
              }
            }
          }
        } catch (_) {
          // Refresh falhou
        } finally {
          _isRefreshing = false;
        }
      }

      // Se o refresh falhou ou não havia refresh token, limpa storage e dispara onUnauthorized
      await _storage.clearAll();
      onUnauthorized();
    }

    return handler.next(err);
  }
}
