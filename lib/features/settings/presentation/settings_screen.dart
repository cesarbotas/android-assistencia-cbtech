import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/presentation/auth_controller.dart';
import 'users_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card de Dados da Assistência
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Assistência Técnica Ativa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.store, color: Colors.white),
                    ),
                    title: Text(
                      authState.activeTenantName ?? 'CB Tech Matriz',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tenant ID: ${authState.activeTenantId ?? "11111111-1111-1111-1111-111111111111"}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seções de Configuração
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: const Text('Dados para Impressão e PDF'),
                  subtitle: const Text('Logo, termos de garantia e rodapé da OS'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: const Text('Gerenciamento de Usuários'),
                  subtitle: const Text('Atendentes, técnicos e administradores'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UsersManagementScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Privacidade e Segurança (LGPD)'),
                  subtitle: const Text('Exportação e retenção de dados'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Versão da Plataforma'),
                  subtitle: const Text('CB Tech SaaS v1.0.0 (Build 1)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
