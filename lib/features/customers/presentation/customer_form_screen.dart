import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/customer.dart';
import 'customers_controller.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cpfCnpjController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _zipCodeController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _notesController;
  late bool _isActive;
  bool _isSaving = false;
  bool _isLoadingCep = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _cpfCnpjController = TextEditingController(text: c?.cpfCnpj ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _whatsappController = TextEditingController(text: c?.whatsapp ?? '');
    _emailController = TextEditingController(text: c?.email ?? 'cliente@cbtech.com');
    _zipCodeController = TextEditingController(text: c?.zipCode ?? '');
    _streetController = TextEditingController(text: c?.street ?? '');
    _numberController = TextEditingController(text: c?.number ?? '');
    _complementController = TextEditingController(text: c?.endereco?.complemento ?? '');
    _neighborhoodController = TextEditingController(text: c?.neighborhood ?? '');
    _cityController = TextEditingController(text: c?.city ?? 'São Paulo');
    _stateController = TextEditingController(text: c?.state ?? 'SP');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfCnpjController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) return;

    setState(() => _isLoadingCep = true);
    try {
      final dio = Dio();
      final response = await dio.get('https://viacep.com.br/ws/$cleanCep/json/');
      if (response.data != null && response.data['erro'] != true) {
        final data = response.data;
        setState(() {
          _streetController.text = data['logradouro'] ?? '';
          _neighborhoodController.text = data['bairro'] ?? '';
          _cityController.text = data['localidade'] ?? '';
          _stateController.text = data['uf'] ?? '';
        });
      }
    } catch (_) {
      // Ignora erro de consulta de CEP
    } finally {
      if (mounted) setState(() => _isLoadingCep = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final address = Address(
      logradouro: _streetController.text.trim(),
      numero: _numberController.text.trim(),
      complemento: _complementController.text.trim().isNotEmpty ? _complementController.text.trim() : null,
      bairro: _neighborhoodController.text.trim(),
      cidade: _cityController.text.trim(),
      estado: _stateController.text.trim(),
      cep: _zipCodeController.text.trim(),
    );

    final customerToSave = Customer(
      id: widget.customer?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'cliente@cbtech.com',
      phone: _phoneController.text.trim(),
      endereco: address,
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
      cpfCnpj: _cpfCnpjController.text.trim().isNotEmpty ? _cpfCnpjController.text.trim() : null,
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      isActive: _isActive,
    );

    final success = await ref
        .read(customersControllerProvider.notifier)
        .saveCustomer(customerToSave);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.customer == null
                ? 'Cliente cadastrado com sucesso!'
                : 'Cliente atualizado com sucesso!',
          ),
        ),
      );
      context.pop();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: Text('Deseja realmente excluir o cliente ${widget.customer?.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.customer != null) {
                await ref.read(customersControllerProvider.notifier).deleteCustomer(widget.customer!.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente excluído com sucesso.')),
                  );
                  context.pop();
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    final authState = ref.watch(authControllerProvider);
    final userRole = (authState.userRole ?? '').toLowerCase();
    final isAdminOrManager = userRole.contains('admin') || userRole.contains('gerente') || userRole.contains('administrador');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
        actions: [
          if (isEditing && isAdminOrManager)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Excluir Cliente',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identificação',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: 'Nome Completo *',
                hint: 'Ex: Roberto de Oliveira',
                prefixIcon: Icons.person_outline,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Telefone Principal *',
                      hint: '(11) 98765-4321',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Telefone é obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _whatsappController,
                      label: 'WhatsApp (Opcional)',
                      hint: '(11) 98765-4321',
                      prefixIcon: Icons.chat_bubble_outline,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cpfCnpjController,
                      label: 'CPF ou CNPJ',
                      hint: '000.000.000-00',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'cliente@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Endereço',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),

              // CEP como primeiro campo para consulta ViaCEP
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _zipCodeController,
                      label: 'CEP *',
                      hint: '00000-000',
                      prefixIcon: Icons.map_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'CEP é obrigatório' : null,
                      suffixIcon: _isLoadingCep
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Buscar CEP'),
                      onPressed: () => _fetchCep(_zipCodeController.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _streetController,
                      label: 'Logradouro *',
                      hint: 'Rua, Avenida...',
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Logradouro obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _numberController,
                      label: 'Número *',
                      hint: '123',
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _complementController,
                label: 'Complemento (Opcional)',
                hint: 'Apto 42, Bloco B, Fundos...',
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _neighborhoodController,
                      label: 'Bairro *',
                      hint: 'Centro...',
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Bairro obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'Cidade *',
                      hint: 'São Paulo',
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Cidade obrigatória' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'UF *',
                      hint: 'SP',
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'UF obrigatória' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Observações & Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _notesController,
                label: 'Observações Internas',
                hint: 'Preferências de peças, histórico...',
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cliente Ativo', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Clientes inativos não aparecem na abertura de novas ordens'),
                value: _isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Cliente',
                isLoading: _isSaving,
                onPressed: _save,
              ),

              if (isEditing && isAdminOrManager) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _confirmDelete,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
