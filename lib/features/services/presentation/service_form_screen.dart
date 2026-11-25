import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/service_item.dart';
import '../data/services_repository.dart';
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
  late TextEditingController _priceController;
  late TextEditingController _timeController;

  String? _selectedCategoryServiceId;
  List<Map<String, String>> _categories = [];
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _selectedCategoryServiceId = s?.categoryServiceId.isNotEmpty == true
        ? s?.categoryServiceId
        : '11111111-1111-1111-1111-111111111111';
    _priceController = TextEditingController(text: s != null ? s.defaultPrice.toStringAsFixed(2) : '');
    _timeController = TextEditingController(text: s?.estimatedTimeMinutes.toString() ?? '60');
    _isActive = s?.isActive ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final repo = ref.read(servicesRepositoryProvider);
    final cats = await repo.getServiceCategories();
    setState(() {
      _categories = cats;
      if (_selectedCategoryServiceId == null && cats.isNotEmpty) {
        _selectedCategoryServiceId = cats.first['id'];
      }
    });
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
    if (_selectedCategoryServiceId == null || _selectedCategoryServiceId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria de serviço.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final serviceToSave = ServiceItem(
      id: widget.service?.id ?? '',
      name: _nameController.text.trim(),
      categoryServiceId: _selectedCategoryServiceId!,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Deseja realmente excluir ${widget.service?.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.service != null) {
                await ref.read(servicesControllerProvider.notifier).deleteService(widget.service!.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Serviço excluído com sucesso.')),
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
    final isEditing = widget.service != null;
    final authState = ref.watch(authControllerProvider);
    final userRole = (authState.userRole ?? '').toLowerCase();
    final isAdminOrManager = userRole.contains('admin') || userRole.contains('gerente') || userRole.contains('administrador');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço no Catálogo'),
        actions: [
          if (isEditing && isAdminOrManager)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Excluir Serviço',
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
                  const Text('Categoria de Serviço *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _categories.any((c) => c['id'] == _selectedCategoryServiceId) ? _selectedCategoryServiceId : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']!))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategoryServiceId = val);
                    },
                    validator: (val) => (val == null || val.isEmpty) ? 'Selecione uma categoria' : null,
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
                      label: 'Preço Padrão (R\$) *',
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
                      label: 'Tempo (Minutos)',
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
                    label: const Text('Excluir Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _confirmDelete,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
