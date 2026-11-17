import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/supplier.dart';
import 'suppliers_controller.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tradeNameController;
  late TextEditingController _legalNameController;
  late TextEditingController _cnpjController;
  late TextEditingController _contactController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _leadTimeController;
  late TextEditingController _paymentTermsController;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _tradeNameController = TextEditingController(text: s?.tradeName ?? '');
    _legalNameController = TextEditingController(text: s?.legalName ?? '');
    _cnpjController = TextEditingController(text: s?.cnpj ?? '');
    _contactController = TextEditingController(text: s?.contactPerson ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _whatsappController = TextEditingController(text: s?.whatsapp ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _leadTimeController = TextEditingController(text: s?.deliveryLeadTimeDays.toString() ?? '1');
    _paymentTermsController = TextEditingController(text: s?.paymentTerms ?? 'Boleto 28 dias / PIX');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _tradeNameController.dispose();
    _legalNameController.dispose();
    _cnpjController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _leadTimeController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final supplierToSave = Supplier(
      id: widget.supplier?.id ?? '',
      tenantId: widget.supplier?.tenantId ?? '',
      tradeName: _tradeNameController.text.trim(),
      legalName: _legalNameController.text.trim().isNotEmpty
          ? _legalNameController.text.trim()
          : _tradeNameController.text.trim(),
      cnpj: _cnpjController.text.trim().isNotEmpty ? _cnpjController.text.trim() : null,
      contactPerson: _contactController.text.trim().isNotEmpty ? _contactController.text.trim() : null,
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      deliveryLeadTimeDays: int.tryParse(_leadTimeController.text) ?? 1,
      paymentTerms: _paymentTermsController.text.trim(),
      isActive: _isActive,
      createdAt: widget.supplier?.createdAt ?? DateTime.now(),
    );

    final success = await ref
        .read(suppliersControllerProvider.notifier)
        .saveSupplier(supplierToSave);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.supplier == null
                ? 'Fornecedor cadastrado com sucesso!'
                : 'Fornecedor atualizado com sucesso!',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dados Cadastrais',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _tradeNameController,
                label: 'Nome Fantasia *',
                hint: 'Ex: TotalCell Distribuidora',
                prefixIcon: Icons.store_outlined,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nome fantasia é obrigatório' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _legalNameController,
                label: 'Razão Social',
                hint: 'Ex: TotalCell Peças e Acessórios Ltda',
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cnpjController,
                      label: 'CNPJ',
                      hint: '00.000.000/0001-00',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _contactController,
                      label: 'Vendedor / Contato',
                      hint: 'Ex: Marcos',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Contatos & Localização',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Telefone Comercial *',
                      hint: '(11) 3222-1000',
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
                      label: 'WhatsApp Pedidos',
                      hint: '(11) 98111-2222',
                      prefixIcon: Icons.chat_bubble_outline,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _emailController,
                label: 'E-mail Comercial',
                hint: 'pedidos@fornecedor.com.br',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _addressController,
                label: 'Endereço Completo',
                hint: 'Rua, número, bairro, cidade, CEP...',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              const Text(
                'Condições Comerciais',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _leadTimeController,
                      label: 'Prazo Médio Entrega (Dias)',
                      hint: 'Ex: 1 ou 2',
                      prefixIcon: Icons.local_shipping_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _paymentTermsController,
                      label: 'Condições de Pagamento',
                      hint: 'Boleto 28D, PIX, Cartão...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fornecedor Ativo', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Fornecedor',
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
