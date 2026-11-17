import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/select_tenant_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/devices/presentation/devices_screen.dart';
import '../../features/finances/presentation/finances_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/work_orders/presentation/new_work_order_screen.dart';
import '../../features/work_orders/presentation/work_orders_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingTenant = state.matchedLocation == '/select-tenant';

      if (authState.status == AuthStatus.unauthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (authState.status == AuthStatus.selectingTenant) {
        return isSelectingTenant ? null : '/select-tenant';
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isLoggingIn || isSelectingTenant) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/select-tenant',
        builder: (context, state) => const SelectTenantScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/work-orders',
        builder: (context, state) => const WorkOrdersScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewWorkOrderScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DevicesScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/finances',
        builder: (context, state) => const FinancesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
