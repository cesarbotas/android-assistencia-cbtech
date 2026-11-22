import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppEnvironment {
  local('Local (http://localhost:5176)'),
  hml('Homologação (Render)'),
  prd('Produção (Locaweb VPS)');

  const AppEnvironment(this.label);
  final String label;
}

final environmentNotifierProvider = StateNotifierProvider<EnvironmentNotifier, AppEnvironment>((ref) {
  return EnvironmentNotifier(const FlutterSecureStorage());
});

class EnvironmentNotifier extends StateNotifier<AppEnvironment> {
  final FlutterSecureStorage _storage;
  static const String _key = 'cbtech_app_environment';

  EnvironmentNotifier(this._storage) : super(AppEnvironment.local) {
    _loadSavedEnvironment();
  }

  Future<void> _loadSavedEnvironment() async {
    try {
      final saved = await _storage.read(key: _key);
      if (saved != null) {
        for (final env in AppEnvironment.values) {
          if (env.name == saved) {
            state = env;
            break;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> setEnvironment(AppEnvironment env) async {
    state = env;
    try {
      await _storage.write(key: _key, value: env.name);
    } catch (_) {}
  }

  String get baseUrl {
    switch (state) {
      case AppEnvironment.local:
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          return 'http://10.0.2.2:5176/api/v1';
        }
        return 'http://localhost:5176/api/v1';
      case AppEnvironment.hml:
        return 'https://cbtech-api-hml.onrender.com/api/v1';
      case AppEnvironment.prd:
        return 'https://api.cbtech.com.br/api/v1';
    }
  }
}
