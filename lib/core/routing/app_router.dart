import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/select_tenant_screen.dart';
import '../../features/customers/data/models/customer.dart';
import '../../features/customers/presentation/customer_form_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/devices/data/models/customer_device.dart';
import '../../features/devices/presentation/device_form_screen.dart';
import '../../features/devices/presentation/devices_screen.dart';
import '../../features/finances/presentation/finances_screen.dart';
import '../../features/inventory/data/models/product.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/inventory/presentation/product_form_screen.dart';
import '../../features/services/data/models/service_item.dart';
import '../../features/services/presentation/service_form_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/suppliers/data/models/supplier.dart';
import '../../features/suppliers/presentation/supplier_form_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
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
      // Clientes
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomersScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CustomerFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => CustomerFormScreen(
              customer: state.extra as Customer?,
            ),
          ),
        ],
      ),
      // Aparelhos
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DevicesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const DeviceFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => DeviceFormScreen(
              device: state.extra as CustomerDevice?,
            ),
          ),
        ],
      ),
      // Fornecedores
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SuppliersScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const SupplierFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => SupplierFormScreen(
              supplier: state.extra as Supplier?,
            ),
          ),
        ],
      ),
      // Peças e Estoque
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => ProductFormScreen(
              product: state.extra as Product?,
            ),
          ),
        ],
      ),
      // Serviços
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const ServiceFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => ServiceFormScreen(
              service: state.extra as ServiceItem?,
            ),
          ),
        ],
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
