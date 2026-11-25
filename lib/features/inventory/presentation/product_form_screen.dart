import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../suppliers/presentation/suppliers_controller.dart';
import '../data/models/category.dart';
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
  late TextEditingController _barcodeController;
  late TextEditingController _salePriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;

  String? _selectedCategoryId;
  String? _selectedSupplierId;
  String _unit = 'UN';
  late bool _isActive;
  bool _isSaving = false;

  final List<String> _units = ['UN', 'PC', 'KT', 'CX', 'MT'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _skuController = TextEditingController(text: p?.sku ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _salePriceController = TextEditingController(text: p != null ? p.salePrice.toStringAsFixed(2) : '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p?.currentStock.toString() ?? '10');
    _minStockController = TextEditingController(text: p?.minStock.toString() ?? '2');
    _selectedCategoryId = p?.categoryId;
    _selectedSupplierId = p?.supplierId;
    _unit = p?.unit ?? 'UN';
    _isActive = p?.isActive ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsControllerProvider.notifier).loadAll();
      ref.read(suppliersControllerProvider.notifier).loadSuppliers();
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _barcodeController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria para o produto.')),
      );
      return;
    }
    if (_selectedSupplierId == null || _selectedSupplierId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um fornecedor para o produto.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final productToSave = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().toUpperCase(),
      barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : null,
      categoryId: _selectedCategoryId!,
      supplierId: _selectedSupplierId!,
      costPrice: double.tryParse(_costPriceController.text.replaceAll(',', '.')) ?? 0.0,
      salePrice: double.tryParse(_salePriceController.text.replaceAll(',', '.')) ?? 0.0,
      currentStock: int.tryParse(_stockController.text) ?? 0,
      minStock: int.tryParse(_minStockController.text) ?? 2,
      unit: _unit,
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
                ? 'Produto cadastrado com sucesso!'
                : 'Produto atualizado com sucesso!',
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
        title: const Text('Excluir Peça / Produto'),
        content: Text('Deseja realmente excluir ${widget.product?.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.product != null) {
                await ref.read(productsControllerProvider.notifier).deleteProduct(widget.product!.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Peça excluída com sucesso.')),
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
    final isEditing = widget.product != null;
    final prodState = ref.watch(productsControllerProvider);
    final supState = ref.watch(suppliersControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final userRole = (authState.userRole ?? '').toLowerCase();
    final isAdminOrManager = userRole.contains('admin') || userRole.contains('gerente') || userRole.contains('administrador');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Peça / Produto' : 'Nova Peça / Produto'),
        actions: [
          if (isEditing && isAdminOrManager)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Excluir Peça',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  label: 'Nome do Produto / Peça *',
                  hint: 'Ex: Tela OLED iPhone 13',
                  prefixIcon: Icons.inventory_2_outlined,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _skuController,
                        label: 'SKU (Código Interno) *',
                        hint: 'TEL-IP13',
                        prefixIcon: Icons.qr_code,
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'SKU obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _barcodeController,
                        label: 'Código de Barras',
                        hint: '789...',
                        prefixIcon: Icons.qr_code_2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Categorização & Fornecedor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 12),

                // Categoria Dropdown
                DropdownButtonFormField<String>(
                  value: prodState.categories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: prodState.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (val) => (val == null || val.isEmpty) ? 'Selecione uma categoria' : null,
                ),
                const SizedBox(height: 14),

                // Fornecedor Dropdown
                DropdownButtonFormField<String>(
                  value: supState.suppliers.any((s) => s.id == _selectedSupplierId) ? _selectedSupplierId : null,
                  decoration: const InputDecoration(
                    labelText: 'Fornecedor Principal *',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  items: supState.suppliers.map((sup) {
                    return DropdownMenuItem(
                      value: sup.id,
                      child: Text(sup.tradeName),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSupplierId = val),
                  validator: (val) => (val == null || val.isEmpty) ? 'Selecione um fornecedor' : null,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Precificação & Estoque',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _costPriceController,
                        label: 'Preço Custo (R\$) *',
                        hint: '0.00',
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _salePriceController,
                        label: 'Preço Venda (R\$) *',
                        hint: '0.00',
                        prefixIcon: Icons.monetization_on_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _stockController,
                        label: 'Estoque Atual *',
                        hint: '10',
                        prefixIcon: Icons.inventory_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _minStockController,
                        label: 'Estoque Mín. *',
                        hint: '2',
                        prefixIcon: Icons.warning_amber_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _units.contains(_unit) ? _unit : 'UN',
                        decoration: const InputDecoration(
                          labelText: 'Unidade de Medida',
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (val) => setState(() => _unit = val ?? 'UN'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Produto Ativo', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Produtos inativos não aparecem na abertura de ordens de serviço'),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: isEditing ? 'Salvar Alterações' : 'Cadastrar Produto',
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
                      label: const Text('Excluir Peça / Produto', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _confirmDelete,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
