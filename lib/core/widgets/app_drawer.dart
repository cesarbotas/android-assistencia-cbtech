import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/auth/presentation/auth_controller.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Column(
        children: [
          // Header com Informações do Tenant Ativo e Usuário
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (authState.activeTenantName?.isNotEmpty == true)
                    ? authState.activeTenantName![0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            accountName: Text(
              authState.activeTenantName ?? 'Assistência Técnica',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(authState.userName ?? 'Usuário'),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    authState.userRole?.toUpperCase() ?? 'ADMIN',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Lista de Módulos Operacionais
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: '/dashboard',
                  isSelected: currentRoute == '/dashboard',
                ),
                _DrawerItem(
                  icon: Icons.assignment_outlined,
                  title: 'Ordens de Serviço',
                  route: '/work-orders',
                  isSelected: currentRoute.startsWith('/work-orders'),
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  title: 'Clientes',
                  route: '/customers',
                  isSelected: currentRoute.startsWith('/customers'),
                ),
                _DrawerItem(
                  icon: Icons.phone_android_outlined,
                  title: 'Aparelhos',
                  route: '/devices',
                  isSelected: currentRoute.startsWith('/devices'),
                ),
                _DrawerItem(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'Fornecedores',
                  route: '/suppliers',
                  isSelected: currentRoute.startsWith('/suppliers'),
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Peças & Estoque',
                  route: '/inventory',
                  isSelected: currentRoute.startsWith('/inventory'),
                ),
                _DrawerItem(
                  icon: Icons.build_outlined,
                  title: 'Serviços',
                  route: '/services',
                  isSelected: currentRoute.startsWith('/services'),
                ),
                _DrawerItem(
                  icon: Icons.payments_outlined,
                  title: 'Financeiro',
                  route: '/finances',
                  isSelected: currentRoute.startsWith('/finances'),
                ),
                const Divider(),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  route: '/settings',
                  isSelected: currentRoute == '/settings',
                ),
              ],
            ),
          ),

          // Rodapé com Troca de Tenant e Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
            title: const Text('Trocar Assistência'),
            onTap: () {
              Navigator.pop(context);
              context.go('/select-tenant');
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}
