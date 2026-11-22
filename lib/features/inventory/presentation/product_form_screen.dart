import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../suppliers/presentation/suppliers_controller.dart';
import '../data/models/product.dart';
import 'products_controller.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _skuController;
  late TextEditingController _nameController;
  late String _category;
  late TextEditingController _descriptionController;
  late TextEditingController _compatibleModelsController;
  late TextEditingController _salePriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _supplierPartCodeController;
  String? _selectedSupplierId;
  String? _selectedSupplierName;
  late bool _isActive;
  bool _isSaving = false;

  final List<String> _categories = [
    'Telas',
    'Baterias',
    'Conectores',
    'Câmeras',
    'Placas',
    'Tampas Traseiras',
    'Alto-falantes',
    'Acessórios',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _skuController = TextEditingController(text: p?.sku ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _category = p?.category ?? 'Telas';
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _compatibleModelsController = TextEditingController(text: p?.compatibleModels ?? '');
    _salePriceController = TextEditingController(text: p != null ? p.salePrice.toStringAsFixed(2) : '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p?.currentStock.toString() ?? '1');
    _minStockController = TextEditingController(text: p?.minStock.toString() ?? '2');
    _supplierPartCodeController = TextEditingController(text: p?.supplierPartCode ?? '');
    _selectedSupplierId = p?.supplierId;
    _selectedSupplierName = p?.supplierName;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _compatibleModelsController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _supplierPartCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final productToSave = Product(
      id: widget.product?.id ?? '',
      tenantId: widget.product?.tenantId ?? '',
      sku: _skuController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      category: _category,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      compatibleModels: _compatibleModelsController.text.trim(),
      salePrice: double.tryParse(_salePriceController.text.replaceAll(',', '.')) ?? 0.0,
      costPrice: double.tryParse(_costPriceController.text.replaceAll(',', '.')) ?? 0.0,
      currentStock: int.tryParse(_stockController.text) ?? 0,
      minStock: int.tryParse(_minStockController.text) ?? 2,
      supplierId: _selectedSupplierId,
      supplierName: _selectedSupplierName,
      supplierPartCode: _supplierPartCodeController.text.trim().isNotEmpty
          ? _supplierPartCodeController.text.trim()
          : null,
      isActive: _isActive,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    final success = await ref
        .read(productsControllerProvider.notifier)
        .saveProduct(productToSave);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Peça cadastrada no estoque com sucesso!'
                : 'Peça atualizada com sucesso!',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final supState = ref.watch(suppliersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Peça / Produto' : 'Nova Peça no Estoque'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identificação da Peça',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _skuController,
                      label: 'Código SKU *',
                      hint: 'TEL-IP14-OLED',
                      prefixIcon: Icons.qr_code,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'SKU é obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Categoria *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _nameController,
                label: 'Descrição / Nome da Peça *',
                hint: 'Ex: Tela Display OLED iPhone 14 com Aro',
                prefixIcon: Icons.extension_outlined,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _compatibleModelsController,
                label: 'Modelos de Aparelhos Compatíveis *',
                hint: 'Ex: iPhone 14 / iPhone 14 Plus',
                prefixIcon: Icons.phone_android,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Informe modelos compatíveis' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Precificação & Custos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _costPriceController,
                      label: 'Preço de Compra / Custo (R\$)',
                      hint: '0.00',
                      prefixIcon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _salePriceController,
                      label: 'Preço de Venda Sugerido (R\$) *',
                      hint: '0.00',
                      prefixIcon: Icons.price_check,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Preço de venda é obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Controle de Estoque',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Quantidade em Estoque',
                      hint: '1',
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _minStockController,
                      label: 'Estoque Mínimo para Alerta',
                      hint: '2',
                      prefixIcon: Icons.warning_amber_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Fornecedor Preferencial',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSupplierId,
                decoration: const InputDecoration(
                  labelText: 'Fornecedor de Cotação',
                  prefixIcon: Icon(Icons.store),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nenhum fornecedor vinculado')),
                  ...supState.suppliers.map((s) {
                    return DropdownMenuItem(value: s.id, child: Text(s.tradeName));
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSupplierId = val;
                    if (val != null) {
                      _selectedSupplierName = supState.suppliers.firstWhere((s) => s.id == val).tradeName;
                    } else {
                      _selectedSupplierName = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _supplierPartCodeController,
                label: 'Código da Peça no Fornecedor',
                hint: 'Ex: TC-OLED-IP14',
                prefixIcon: Icons.tag,
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Peça Ativa no Catálogo', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Peça',
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
