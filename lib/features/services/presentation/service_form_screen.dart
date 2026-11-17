import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/service_item.dart';
import 'services_controller.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final ServiceItem? service;

  const ServiceFormScreen({super.key, this.service});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _category;
  late TextEditingController _priceController;
  late TextEditingController _timeController;
  late bool _isActive;
  bool _isSaving = false;

  final List<String> _categories = [
    'Troca de Peça',
    'Reparo em Placa',
    'Limpeza/Banho',
    'Software/Reset',
    'Diagnóstico Técnico',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _category = s?.category ?? 'Troca de Peça';
    _priceController = TextEditingController(text: s != null ? s.defaultPrice.toStringAsFixed(2) : '');
    _timeController = TextEditingController(text: s?.estimatedTimeMinutes.toString() ?? '60');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final serviceToSave = ServiceItem(
      id: widget.service?.id ?? '',
      tenantId: widget.service?.tenantId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      category: _category,
      defaultPrice: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      estimatedTimeMinutes: int.tryParse(_timeController.text) ?? 60,
      isActive: _isActive,
      createdAt: widget.service?.createdAt ?? DateTime.now(),
    );

    final success = await ref
        .read(servicesControllerProvider.notifier)
        .saveService(serviceToSave);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.service == null
                ? 'Serviço adicionado ao catálogo com sucesso!'
                : 'Serviço atualizado com sucesso!',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço no Catálogo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identificação do Serviço',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: 'Nome do Serviço *',
                hint: 'Ex: Troca de Tela Frontal',
                prefixIcon: Icons.build_outlined,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 14),
              Column(
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
              const SizedBox(height: 14),
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição dos Procedimentos',
                hint: 'Descreva os testes executados, garantia padrão...',
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),

              const Text(
                'Valores & Prazos Estimados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Preço Padrão de Mão de Obra (R\$) *',
                      hint: '150.00',
                      prefixIcon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Preço é obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _timeController,
                      label: 'Tempo Estimado (Minutos)',
                      hint: '60',
                      prefixIcon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Serviço Ativo para Orçamentos', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Serviço',
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
