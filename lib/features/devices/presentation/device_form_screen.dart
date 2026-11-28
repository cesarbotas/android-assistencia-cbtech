import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../customers/data/models/customer.dart';
import '../../customers/presentation/customers_controller.dart';
import '../data/models/brand.dart';
import '../data/models/customer_device.dart';
import '../data/models/device_model.dart';
import 'devices_controller.dart';

class DeviceFormScreen extends ConsumerStatefulWidget {
  final CustomerDevice? device;

  const DeviceFormScreen({super.key, this.device});

  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  String? _selectedCustomerName;
  Brand? _selectedBrand;
  DeviceModel? _selectedModel;
  List<DeviceModel> _availableModels = [];

  late TextEditingController _customModelController;
  late TextEditingController _imei1Controller;
  late TextEditingController _imei2Controller;
  late TextEditingController _serialController;
  late TextEditingController _colorController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.device;
    _selectedCustomerId = d?.customerId;
    _selectedCustomerName = d?.customerName;
    _customModelController = TextEditingController(text: d?.modelName ?? '');
    _imei1Controller = TextEditingController(text: d?.imei1 ?? '');
    _imei2Controller = TextEditingController(text: d?.imei2 ?? '');
    _serialController = TextEditingController(text: d?.serialNumber ?? '');
    _colorController = TextEditingController(text: d?.color ?? 'Preto');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBrandsAndCascade();
    });
  }

  Future<void> _loadBrandsAndCascade() async {
    final devState = ref.read(devicesControllerProvider);
    if (devState.brands.isNotEmpty) {
      if (widget.device != null) {
        final matchBrand = devState.brands.firstWhere(
          (b) => b.id == widget.device!.brandId || b.name == widget.device!.brandName,
          orElse: () => devState.brands.first,
        );
        setState(() => _selectedBrand = matchBrand);
        await _loadModelsForBrand(matchBrand);
      } else {
        setState(() => _selectedBrand = devState.brands.first);
        await _loadModelsForBrand(devState.brands.first);
      }
    }
  }

  Future<void> _loadModelsForBrand(Brand brand) async {
    final models = await ref.read(devicesControllerProvider.notifier).getModelsForBrand(brand.id);
    setState(() {
      _availableModels = models;
      if (models.isNotEmpty) {
        _selectedModel = models.first;
        _customModelController.text = models.first.name;
      }
    });
  }

  @override
  void dispose() {
    _customModelController.dispose();
    _imei1Controller.dispose();
    _imei2Controller.dispose();
    _serialController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um cliente para vincular o aparelho.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final deviceToSave = CustomerDevice(
      id: widget.device?.id ?? '',
      customerId: _selectedCustomerId!,
      customerName: _selectedCustomerName ?? 'Cliente',
      brandId: _selectedBrand?.id ?? '',
      brandName: _selectedBrand?.name ?? 'Outro',
      modelName: _customModelController.text.trim().isNotEmpty
          ? _customModelController.text.trim()
          : (_selectedModel?.name ?? 'Modelo Desconhecido'),
      imei1: _imei1Controller.text.trim().isNotEmpty ? _imei1Controller.text.trim() : null,
      imei2: _imei2Controller.text.trim().isNotEmpty ? _imei2Controller.text.trim() : null,
      serialNumber: _serialController.text.trim().isNotEmpty ? _serialController.text.trim() : null,
      color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
      isActive: true,
      createdAt: widget.device?.createdAt ?? DateTime.now(),
    );

    final success = await ref.read(devicesControllerProvider.notifier).saveDevice(deviceToSave);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.device == null
                ? 'Aparelho vinculado ao cliente com sucesso!'
                : 'Aparelho atualizado com sucesso!',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.device != null;
    final devState = ref.watch(devicesControllerProvider);
    final custState = ref.watch(customersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Aparelho' : 'Cadastrar Aparelho'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Proprietário do Aparelho',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              SearchableDropdown<Customer>(
                label: 'Selecione o Cliente *',
                prefixIcon: Icons.person_outline,
                value: custState.customers.where((c) => c.id == _selectedCustomerId).firstOrNull,
                items: custState.customers,
                itemLabelBuilder: (c) => '${c.name} (${c.phone})',
                onChanged: (c) {
                  if (c != null) {
                    setState(() {
                      _selectedCustomerId = c.id;
                      _selectedCustomerName = c.name;
                    });
                  }
                },
                validator: (_) => _selectedCustomerId == null ? 'Selecione um cliente' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Marca & Modelo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              SearchableDropdown<Brand>(
                label: 'Fabricante / Marca *',
                prefixIcon: Icons.business_outlined,
                value: devState.brands.where((b) => b.id == _selectedBrand?.id).firstOrNull ?? _selectedBrand,
                items: devState.brands,
                itemLabelBuilder: (b) => b.name,
                onChanged: (brand) {
                  if (brand != null) {
                    setState(() => _selectedBrand = brand);
                    _loadModelsForBrand(brand);
                  }
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _customModelController,
                label: 'Nome do Modelo (Customizável) *',
                hint: 'Ex: iPhone 13 Pro Max ou Galaxy S23',
                prefixIcon: Icons.edit_outlined,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Informe o modelo' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Identificadores & Especificações',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _imei1Controller,
                      label: 'IMEI 1',
                      hint: '354...',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _imei2Controller,
                      label: 'IMEI 2 (Opcional)',
                      hint: '354...',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _serialController,
                      label: 'Número de Série',
                      hint: 'SN...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _colorController,
                      label: 'Cor',
                      hint: 'Ex: Preto, Azul...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: isEditing ? 'Salvar Alterações' : 'Cadastrar Aparelho',
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
