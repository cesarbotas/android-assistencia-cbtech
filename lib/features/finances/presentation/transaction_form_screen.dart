import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/financial_transaction.dart';
import 'finances_controller.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.income;
  TransactionCategory _category = TransactionCategory.service;
  PaymentMethod _paymentMethod = PaymentMethod.pix;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido maior que zero.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(financesControllerProvider.notifier).addTransaction(
          title: _titleController.text.trim(),
          type: _type,
          category: _category,
          paymentMethod: _paymentMethod,
          amount: amount,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lançamento financeiro registrado com sucesso!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar lançamento. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lançamento de Caixa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor Tipo (Entrada / Saída)
              const Text('Tipo de Movimento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Entrada (Receita)'),
                    icon: Icon(Icons.arrow_downward, color: Colors.green),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Saída (Despesa)'),
                    icon: Icon(Icons.arrow_upward, color: Colors.red),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (val) => setState(() => _type = val.first),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _titleController,
                label: 'Descrição / Título',
                hint: 'Ex: Pagamento de Serviços, Conta de Energia, etc.',
                validator: (val) => val == null || val.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _amountController,
                label: 'Valor (R\$)',
                hint: '0,00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Informe o valor';
                  final num = double.tryParse(val.replaceAll(',', '.'));
                  if (num == null || num <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoria
              DropdownButtonFormField<TransactionCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: TransactionCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _category = val ?? TransactionCategory.other),
              ),
              const SizedBox(height: 16),

              // Forma de Pagamento
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Forma de Pagamento'),
                items: PaymentMethod.values.map((meth) {
                  return DropdownMenuItem(
                    value: meth,
                    child: Text(meth.label),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _paymentMethod = val ?? PaymentMethod.pix),
              ),
              const SizedBox(height: 16),

              const Text('Observações (Opcional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Detalhes adicionais sobre o lançamento...',
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Salvar Lançamento',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
