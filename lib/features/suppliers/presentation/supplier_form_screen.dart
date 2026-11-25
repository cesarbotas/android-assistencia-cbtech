import 'package:dio/dio.dart';
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

  // Endereço Estruturado (Opcional)
  late TextEditingController _zipCodeController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  late TextEditingController _leadTimeController;
  late TextEditingController _paymentTermsController;
  late bool _isActive;
  bool _isSaving = false;
  bool _isLoadingCep = false;

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

    final addr = s?.endereco;
    _zipCodeController = TextEditingController(text: addr?.cep ?? '');
    _streetController = TextEditingController(text: addr?.logradouro ?? '');
    _numberController = TextEditingController(text: addr?.numero ?? '');
    _complementController = TextEditingController(text: addr?.complemento ?? '');
    _neighborhoodController = TextEditingController(text: addr?.bairro ?? '');
    _cityController = TextEditingController(text: addr?.cidade ?? '');
    _stateController = TextEditingController(text: addr?.estado ?? '');

    _leadTimeController = TextEditingController(text: s?.deliveryLeadTimeDays.toString() ?? '2');
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
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _leadTimeController.dispose();
    _paymentTermsController.dispose();
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

  void _clearAddress() {
    setState(() {
      _zipCodeController.clear();
      _streetController.clear();
      _numberController.clear();
      _complementController.clear();
      _neighborhoodController.clear();
      _cityController.clear();
      _stateController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Endereço limpo com sucesso.')),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Endereço é opcional. Se houver logradouro ou cep preenchido, monta o objeto de endereço
    SupplierAddress? supplierAddress;
    if (_streetController.text.trim().isNotEmpty || _zipCodeController.text.trim().isNotEmpty) {
      supplierAddress = SupplierAddress(
        id: widget.supplier?.endereco?.id,
        fornecedorId: widget.supplier?.id,
        logradouro: _streetController.text.trim().isNotEmpty ? _streetController.text.trim() : 'Não informado',
        numero: _numberController.text.trim().isNotEmpty ? _numberController.text.trim() : 'S/N',
        complemento: _complementController.text.trim().isNotEmpty ? _complementController.text.trim() : null,
        bairro: _neighborhoodController.text.trim().isNotEmpty ? _neighborhoodController.text.trim() : 'Geral',
        cidade: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Não informada',
        estado: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : 'SP',
        cep: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : '00000000',
      );
    }

    final supplierToSave = Supplier(
      id: widget.supplier?.id ?? '',
      tradeName: _tradeNameController.text.trim(),
      legalName: _legalNameController.text.trim().isNotEmpty
          ? _legalNameController.text.trim()
          : _tradeNameController.text.trim(),
      cnpj: _cnpjController.text.trim().isNotEmpty ? _cnpjController.text.trim() : null,
      contactPerson: _contactController.text.trim().isNotEmpty ? _contactController.text.trim() : null,
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      endereco: supplierAddress,
      deliveryLeadTimeDays: int.tryParse(_leadTimeController.text) ?? 2,
      paymentTerms: _paymentTermsController.text.trim().isNotEmpty ? _paymentTermsController.text.trim() : null,
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
                'Contatos',
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
              const SizedBox(height: 24),

              // Seção de Endereço Opcional com CEP e Botão de Limpar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Endereço (Opcional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpar Endereço'),
                    onPressed: _clearAddress,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              CustomTextField(
                controller: _zipCodeController,
                label: 'CEP',
                hint: '00000-000',
                prefixIcon: Icons.map_outlined,
                keyboardType: TextInputType.number,
                suffixIcon: IconButton(
                  icon: _isLoadingCep
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search, color: AppColors.primary),
                  tooltip: 'Buscar CEP',
                  onPressed: () => _fetchCep(_zipCodeController.text),
                ),
              ),
              const SizedBox(height: 14),

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

              CustomTextField(
                controller: _complementController,
                label: 'Complemento',
                hint: 'Galpão 2, Sala 4...',
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _neighborhoodController,
                label: 'Bairro',
                hint: 'Centro...',
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
                      hint: 'Ex: 2',
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
