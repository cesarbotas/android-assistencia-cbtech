import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../suppliers/data/models/supplier.dart';
import '../../suppliers/presentation/suppliers_controller.dart';
import '../data/models/product.dart';
import '../data/models/purchase_order.dart';
import 'products_controller.dart';
import 'stock_controller.dart';

class PurchaseOrderFormScreen extends ConsumerStatefulWidget {
  const PurchaseOrderFormScreen({super.key});

  @override
  ConsumerState<PurchaseOrderFormScreen> createState() => _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState extends ConsumerState<PurchaseOrderFormScreen> {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  Supplier? _selectedSupplier;
  final List<PurchaseOrderItem> _items = [];
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final products = ref.read(productsControllerProvider).products;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum produto cadastrado.')),
      );
      return;
    }

    Product selectedProduct = products.first;
    final qtyCtrl = TextEditingController(text: '5');
    final costCtrl = TextEditingController(text: selectedProduct.costPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Item ao Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                initialValue: selectedProduct,
                decoration: const InputDecoration(labelText: 'Produto'),
                items: products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (p) {
                  if (p != null) {
                    setDialogState(() {
                      selectedProduct = p;
                      costCtrl.text = p.costPrice.toStringAsFixed(2);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Custo Negociado (R\$)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
                final cost = double.tryParse(costCtrl.text.replaceAll('.', '').replaceAll(',', '.')) ??
                    selectedProduct.costPrice;

                setState(() {
                  _items.add(
                    PurchaseOrderItem(
                      id: const Uuid().v4(),
                      productId: selectedProduct.id,
                      productName: selectedProduct.name,
                      productSku: selectedProduct.sku,
                      quantity: qty,
                      unitCost: cost,
                    ),
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um fornecedor.')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um item ao pedido.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final order = PurchaseOrder(
      id: const Uuid().v4(),
      tenantId: '11111111-1111-1111-1111-111111111111',
      orderNumber: '',
      supplierId: _selectedSupplier!.id,
      supplierName: _selectedSupplier!.tradeName,
      status: PurchaseOrderStatus.emitido,
      items: _items,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: DateTime.now(),
    );

    final success = await ref.read(stockControllerProvider.notifier).createPurchaseOrder(order);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido de compra emitido com sucesso!')),
      );
      context.pop();
    } else {
      final err = ref.read(stockControllerProvider).errorMessage ?? 'Erro ao salvar pedido de compra.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersState = ref.watch(suppliersControllerProvider);
    final total = _items.fold(0.0, (acc, item) => acc + item.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido de Compra'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Fornecedor de Peças *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DropdownButtonFormField<Supplier>(
            initialValue: _selectedSupplier,
            decoration: const InputDecoration(
              hintText: 'Selecione o fornecedor',
              prefixIcon: Icon(Icons.local_shipping_outlined),
            ),
            items: suppliersState.suppliers.map((s) {
              return DropdownMenuItem(value: s, child: Text(s.tradeName));
            }).toList(),
            onChanged: (s) => setState(() => _selectedSupplier = s),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _notesController,
            label: 'Observações do Pedido',
            hint: 'Ex: Prazo de entrega combinado, frete CIF, condições de pagamento...',
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Peças no Pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar Item'),
                onPressed: _showAddItemDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Nenhum item adicionado ao pedido ainda.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ..._items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.extension, color: AppColors.primary),
                  title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${item.quantity} un x ${_currency.format(item.unitCost)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currency.format(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: () {
                          setState(() => _items.remove(item));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Valor Total do Pedido:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                _currency.format(total),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 28),

          PrimaryButton(
            text: 'Emitir Pedido de Compra',
            isLoading: _isSaving,
            onPressed: _submitOrder,
          ),
        ],
      ),
    );
  }
}
