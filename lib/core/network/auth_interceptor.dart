import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final VoidCallback onUnauthorized;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

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
    if (err.response?.statusCode == 401 &&
        !path.contains('/auth/login') &&
        !path.contains('/auth/refresh')) {

      bool refreshSuccess = false;

      if (_isRefreshing) {
        // Se já está renovando o token, aguarda o término do refresh em andamento
        if (_refreshCompleter != null) {
          refreshSuccess = await _refreshCompleter!.future;
        }
      } else {
        _isRefreshing = true;
        _refreshCompleter = Completer<bool>();

        try {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final dioRefresh = Dio(BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ));

            final response = await dioRefresh.post(
              ApiEndpoints.refreshToken,
              data: {'refreshToken': refreshToken},
            );

            if (response.statusCode == 200 && response.data != null) {
              final data = response.data;
              final newAccessToken = data['accessToken'] as String?;
              final newRefreshToken = data['refreshToken'] as String?;

              if (newAccessToken != null && newAccessToken.isNotEmpty) {
                await _storage.saveAccessToken(newAccessToken);
                if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                  await _storage.saveRefreshToken(newRefreshToken);
                }
                refreshSuccess = true;
              }
            }
          }
        } catch (_) {
          refreshSuccess = false;
        } finally {
          _isRefreshing = false;
          if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
            _refreshCompleter!.complete(refreshSuccess);
          }
        }
      }

      // Se o refresh foi bem-sucedido, repete a requisição original com o novo token
      if (refreshSuccess) {
        try {
          final newToken = await _storage.getAccessToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          final dioRetry = Dio(BaseOptions(
            baseUrl: opts.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));

          final cloneReq = await dioRetry.request(
            opts.path,
            data: opts.data,
            queryParameters: opts.queryParameters,
            options: Options(method: opts.method, headers: opts.headers),
          );
          return handler.resolve(cloneReq);
        } catch (retryErr) {
          if (retryErr is DioException) {
            return handler.next(retryErr);
          }
        }
      }

      // Se o refresh falhou, limpa storage e dispara deslogar/redirecionar
      await _storage.clearAll();
      onUnauthorized();
      return handler.next(err);
    }

    return handler.next(err);
  }
}
