import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/user_staff.dart';
import 'users_controller.dart';

class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends ConsumerState<UsersManagementScreen> {
  void _showAddUserBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    UserRole selectedRole = UserRole.technician;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar Novo Colaborador',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: nameCtrl,
                  label: 'Nome Completo',
                  hint: 'Ex: Carlos Silva',
                  validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: emailCtrl,
                  label: 'E-mail de Acesso',
                  hint: 'carlos@cbtech.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Informe o e-mail' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: phoneCtrl,
                  label: 'WhatsApp / Telefone',
                  hint: '(11) 99999-9999',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
                ),
                const SizedBox(height: 12),
                const Text('Cargo / Nível de Acesso', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text('${role.label} — ${role.description}'),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedRole = val ?? UserRole.technician),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Cadastrar Colaborador',
                  isLoading: isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    setModalState(() => isLoading = true);
                    final success = await ref.read(usersControllerProvider.notifier).addUser(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          role: selectedRole,
                        );

                    setModalState(() => isLoading = false);

                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Colaborador cadastrado com sucesso!' : 'Erro ao cadastrar colaborador.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersControllerProvider);
    final controller = ref.read(usersControllerProvider.notifier);
    final users = state.filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuários & Equipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadUsers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Colaborador'),
        onPressed: _showAddUserBottomSheet,
      ),
      body: Column(
        children: [
          // Filtro por Cargo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: state.filterRole == null,
                  onSelected: (_) => controller.setFilterRole(null),
                ),
                const SizedBox(width: 8),
                ...UserRole.values.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(role.label),
                      selected: state.filterRole == role,
                      onSelected: (_) => controller.setFilterRole(role),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de Usuários
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum colaborador encontrado.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.loadUsers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: user.role == UserRole.admin
                                      ? Colors.purple.shade50
                                      : user.role == UserRole.technician
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                  child: Icon(
                                    user.role == UserRole.admin
                                        ? Icons.admin_panel_settings
                                        : user.role == UserRole.technician
                                            ? Icons.build
                                            : Icons.support_agent,
                                    color: user.role == UserRole.admin
                                        ? Colors.purple
                                        : user.role == UserRole.technician
                                            ? Colors.blue
                                            : Colors.green,
                                  ),
                                ),
                                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(user.email, style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text('${user.role.label} • ${user.phone}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(
                                    user.isActive ? 'Ativo' : 'Inativo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: user.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
