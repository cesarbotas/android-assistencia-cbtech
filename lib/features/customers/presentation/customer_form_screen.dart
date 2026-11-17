import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
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
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _notesController;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _cpfCnpjController = TextEditingController(text: c?.cpfCnpj ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _whatsappController = TextEditingController(text: c?.whatsapp ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _streetController = TextEditingController(text: c?.street ?? '');
    _numberController = TextEditingController(text: c?.number ?? '');
    _neighborhoodController = TextEditingController(text: c?.neighborhood ?? '');
    _cityController = TextEditingController(text: c?.city ?? 'São Paulo');
    _stateController = TextEditingController(text: c?.state ?? 'SP');
    _zipCodeController = TextEditingController(text: c?.zipCode ?? '');
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
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final customerToSave = Customer(
      id: widget.customer?.id ?? '',
      tenantId: widget.customer?.tenantId ?? '',
      name: _nameController.text.trim(),
      cpfCnpj: _cpfCnpjController.text.trim().isNotEmpty ? _cpfCnpjController.text.trim() : null,
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      street: _streetController.text.trim().isNotEmpty ? _streetController.text.trim() : null,
      number: _numberController.text.trim().isNotEmpty ? _numberController.text.trim() : null,
      neighborhood: _neighborhoodController.text.trim().isNotEmpty ? _neighborhoodController.text.trim() : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
      zipCode: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      isActive: _isActive,
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
      devicesCount: widget.customer?.devicesCount ?? 0,
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
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
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _streetController,
                      label: 'Logradouro',
                      hint: 'Rua, Avenida...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _numberController,
                      label: 'Número',
                      hint: '123',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _neighborhoodController,
                      label: 'Bairro',
                      hint: 'Centro...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _zipCodeController,
                      label: 'CEP',
                      hint: '00000-000',
                      keyboardType: TextInputType.number,
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
                      label: 'Cidade',
                      hint: 'São Paulo',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'UF',
                      hint: 'SP',
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
            ],
          ),
        ),
      ),
    );
  }
}
