import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import 'models/user_staff.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final authState = ref.watch(authControllerProvider);
  return UsersRepository(dio, authState.activeTenantId ?? '11111111-1111-1111-1111-111111111111');
});

class UsersRepository {
  final Dio _dio;
  final String _tenantId;

  UsersRepository(this._dio, this._tenantId);

  final List<UserStaff> _mockUsers = [
    UserStaff(
      id: 'usr-001',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'César Botas (Admin)',
      email: 'cesar.botas@cbtech.com',
      phone: '(11) 98888-7777',
      role: UserRole.admin,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    UserStaff(
      id: 'usr-002',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Lucas Técnico',
      email: 'lucas.tech@cbtech.com',
      phone: '(11) 97777-6666',
      role: UserRole.technician,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserStaff(
      id: 'usr-003',
      tenantId: '11111111-1111-1111-1111-111111111111',
      name: 'Juliana Atendimento',
      email: 'juliana.atende@cbtech.com',
      phone: '(11) 96666-5555',
      role: UserRole.attendant,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  Future<List<UserStaff>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers.where((u) => u.tenantId == _tenantId).toList();
  }

  Future<UserStaff> addUser(UserStaff user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newUser = UserStaff(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: _tenantId,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      isActive: user.isActive,
      createdAt: DateTime.now(),
    );
    _mockUsers.insert(0, newUser);
    return newUser;
  }
}
