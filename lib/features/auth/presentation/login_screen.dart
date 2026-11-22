import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'auth_controller.dart';
import 'environment_selector_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isTestingConnection = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      final state = ref.read(authControllerProvider);
      if (state.status == AuthStatus.selectingTenant) {
        context.go('/select-tenant');
      } else if (state.status == AuthStatus.authenticated) {
        context.go('/dashboard');
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isTestingConnection = true);
    try {
      final dio = ref.read(apiClientProvider);
      final baseUrl = dio.options.baseUrl;

      final response = await dio.get('/auth/me', options: Options(receiveTimeout: const Duration(seconds: 4)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conexão OK com $baseUrl (Status: ${response.statusCode})')),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conexão bem-sucedida! O servidor respondeu (API ativa).')),
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Falha na Conexão com a API'),
              content: Text(
                'Não foi possível conectar ao servidor em:\n${ref.read(apiClientProvider).options.baseUrl}\n\n'
                'Erro: ${e.message}\n\n'
                '💡 Dica para Celular Físico via USB:\n'
                'Execute no terminal do seu computador:\nadb reverse tcp:5176 tcp:5176\n\n'
                '💡 Dica para Wi-Fi Local:\n'
                'Certifique-se de usar o IP local da sua máquina (ex: 192.168.x.x:5176).',
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
              ],
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isTestingConnection = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Ícone
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.phonelink_setup,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'CB Tech',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gestão Especializada de Assistências Técnicas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mensagem de Erro
                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo E-mail
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-mail profissional',
                    hint: 'seuemail@assistencia.com.br',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o seu e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Senha
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha de acesso',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a sua senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contate o administrador para redefinir sua senha.'),
                          ),
                        );
                      },
                      child: const Text('Esqueceu a senha?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'Acessar Plataforma',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),

                  // Botão de Diagnóstico / Teste de Conexão com a API
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    icon: _isTestingConnection
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering, size: 18),
                    label: Text(_isTestingConnection ? 'Testando conexão...' : 'Testar Conexão com a API'),
                    onPressed: _isTestingConnection ? null : _testConnection,
                  ),
                  const SizedBox(height: 24),

                  Consumer(
                    builder: (context, ref, _) {
                      final currentEnv = ref.watch(environmentNotifierProvider);
                      return Center(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                          icon: const Icon(Icons.dns_outlined, size: 16),
                          label: Text('Ambiente: ${currentEnv.label}'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const EnvironmentSelectorDialog(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
