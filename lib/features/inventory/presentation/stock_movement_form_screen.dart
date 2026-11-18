import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../suppliers/data/models/supplier.dart';
import '../../suppliers/presentation/suppliers_controller.dart';
import '../data/models/product.dart';
import '../data/models/stock_movement.dart';
import 'products_controller.dart';
import 'stock_controller.dart';

class StockMovementFormScreen extends ConsumerStatefulWidget {
  final Product? initialProduct;

  const StockMovementFormScreen({super.key, this.initialProduct});

  @override
  ConsumerState<StockMovementFormScreen> createState() => _StockMovementFormScreenState();
}

class _StockMovementFormScreenState extends ConsumerState<StockMovementFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Product? _selectedProduct;
  StockMovementType _selectedType = StockMovementType.entrada;
  Supplier? _selectedSupplier;

  late TextEditingController _quantityController;
  late TextEditingController _unitCostController;
  late TextEditingController _reasonController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.initialProduct;
    _quantityController = TextEditingController(text: '1');
    _unitCostController = TextEditingController(
      text: widget.initialProduct != null ? widget.initialProduct!.costPrice.toStringAsFixed(2) : '0,00',
    );
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitMovement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma peça / produto.')),
      );
      return;
    }

    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A quantidade deve ser maior que zero.')),
      );
      return;
    }

    if (!_selectedType.isEntry && _selectedType != StockMovementType.ajuste) {
      if (_selectedProduct!.currentStock < qty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estoque insuficiente! Saldo atual: ${_selectedProduct!.currentStock}')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    final cost = double.tryParse(_unitCostController.text.replaceAll('.', '').replaceAll(',', '.')) ??
        _selectedProduct!.costPrice;

    final mov = StockMovement(
      id: const Uuid().v4(),
      tenantId: '11111111-1111-1111-1111-111111111111',
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      productSku: _selectedProduct!.sku,
      type: _selectedType,
      quantity: qty,
      unitCost: cost,
      totalValue: qty * cost,
      previousStock: _selectedProduct!.currentStock,
      newStock: _selectedType.isEntry
          ? _selectedProduct!.currentStock + qty
          : _selectedProduct!.currentStock - qty,
      reason: _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : _selectedType.label,
      supplierId: _selectedSupplier?.id,
      supplierName: _selectedSupplier?.tradeName,
      createdBy: 'Técnico Responsável',
      createdAt: DateTime.now(),
    );

    final success = await ref.read(stockControllerProvider.notifier).recordMovement(mov);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movimentação de ${_selectedType.label} registrada com sucesso!')),
      );
      context.pop();
    } else {
      final err = ref.read(stockControllerProvider).errorMessage ?? 'Erro ao salvar movimentação.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsControllerProvider);
    final suppliersState = ref.watch(suppliersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Movimentação'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Peça / Componente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<Product>(
              initialValue: _selectedProduct,
              decoration: const InputDecoration(
                hintText: 'Selecione o produto',
                prefixIcon: Icon(Icons.extension_outlined),
              ),
              items: productsState.products.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text('${p.name} (Atual: ${p.currentStock})'),
                );
              }).toList(),
              onChanged: (p) {
                setState(() {
                  _selectedProduct = p;
                  if (p != null) {
                    _unitCostController.text = p.costPrice.toStringAsFixed(2);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            const Text('Tipo de Movimento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<StockMovementType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.swap_vert),
              ),
              items: const [
                DropdownMenuItem(value: StockMovementType.entrada, child: Text('Entrada Manual (Estoque +)')),
                DropdownMenuItem(value: StockMovementType.saida, child: Text('Saída / Descarte (Estoque -)')),
                DropdownMenuItem(value: StockMovementType.devolucao, child: Text('Devolução a Fornecedor (Estoque -)')),
                DropdownMenuItem(value: StockMovementType.ajuste, child: Text('Ajuste de Inventário')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _quantityController,
                    label: 'Quantidade *',
                    hint: '1',
                    prefixIcon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe a quantidade';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _unitCostController,
                    label: 'Custo Unitário (R\$)',
                    hint: '0,00',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_selectedType.isEntry || _selectedType == StockMovementType.devolucao) ...[
              const Text('Fornecedor (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<Supplier>(
                initialValue: _selectedSupplier,
                decoration: const InputDecoration(
                  hintText: 'Selecione o fornecedor',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
                items: [
                  const DropdownMenuItem<Supplier>(value: null, child: Text('Nenhum / Não informado')),
                  ...suppliersState.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.tradeName))),
                ],
                onChanged: (s) => setState(() => _selectedSupplier = s),
              ),
              const SizedBox(height: 16),
            ],

            CustomTextField(
              controller: _reasonController,
              label: 'Motivo / Justificativa *',
              hint: 'Ex: Reposição avulsa, teste falho em bancada, quebra...',
              maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Informe o motivo da movimentação' : null,
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Confirmar e Atualizar Estoque',
              isLoading: _isSaving,
              onPressed: _submitMovement,
            ),
          ],
        ),
      ),
    );
  }
}
