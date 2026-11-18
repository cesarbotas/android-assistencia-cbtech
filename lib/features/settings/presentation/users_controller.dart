import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_staff.dart';
import '../data/users_repository.dart';

final usersControllerProvider = StateNotifierProvider<UsersController, UsersState>((ref) {
  final repo = ref.watch(usersRepositoryProvider);
  return UsersController(repo);
});

class UsersState {
  final List<UserStaff> users;
  final bool isLoading;
  final UserRole? filterRole;

  UsersState({
    this.users = const [],
    this.isLoading = false,
    this.filterRole,
  });

  UsersState copyWith({
    List<UserStaff>? users,
    bool? isLoading,
    UserRole? filterRole,
    bool clearFilterRole = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      filterRole: clearFilterRole ? null : (filterRole ?? this.filterRole),
    );
  }

  List<UserStaff> get filteredUsers {
    if (filterRole == null) return users;
    return users.where((u) => u.role == filterRole).toList();
  }
}

class UsersController extends StateNotifier<UsersState> {
  final UsersRepository _repository;

  UsersController(this._repository) : super(UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getUsers();
      state = state.copyWith(users: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilterRole(UserRole? role) {
    if (role == state.filterRole) {
      state = state.copyWith(clearFilterRole: true);
    } else {
      state = state.copyWith(filterRole: role);
    }
  }

  Future<bool> addUser({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final newUser = UserStaff(
        id: '',
        tenantId: '',
        name: name,
        email: email,
        phone: phone,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await _repository.addUser(newUser);
      await loadUsers();
      return true;
    } catch (_) {
      return false;
    }
  }
}
