import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../customers/data/models/customer.dart';
import '../../customers/presentation/customers_controller.dart';
import '../data/models/budget.dart';
import '../data/models/budget_item.dart';
import '../data/models/work_order.dart';
import '../data/models/work_order_status.dart';
import 'work_orders_controller.dart';

class NewWorkOrderScreen extends ConsumerStatefulWidget {
  final WorkOrder? workOrder;

  const NewWorkOrderScreen({super.key, this.workOrder});

  @override
  ConsumerState<NewWorkOrderScreen> createState() => _NewWorkOrderScreenState();
}

class _NewWorkOrderScreenState extends ConsumerState<NewWorkOrderScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  Customer? _selectedCustomer;
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientPhoneController;
  late final TextEditingController _clientCpfController;

  late String _selectedBrand;
  late final TextEditingController _modelController;
  late final TextEditingController _imeiController;
  late final TextEditingController _serialController;
  late final TextEditingController _colorController;

  final List<XFile> _devicePhotos = [];
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _accessoriesController;
  late final TextEditingController _physicalConditionController;

  late final TextEditingController _reportedDefectController;
  late String _priority;

  late final TextEditingController _diagnosisController;
  late final TextEditingController _estimatedHoursController;

  late final TextEditingController _partsCostController;
  late final TextEditingController _servicePriceController;

  @override
  void initState() {
    super.initState();
    final wo = widget.workOrder;
    _clientNameController = TextEditingController(text: wo?.customerName ?? '');
    _clientPhoneController = TextEditingController(text: wo?.customerPhone ?? '');
    _clientCpfController = TextEditingController(text: '');

    _selectedBrand = wo?.deviceBrand.isNotEmpty == true ? wo!.deviceBrand : 'Apple';
    _modelController = TextEditingController(text: wo?.deviceModel ?? 'iPhone 13');
    _imeiController = TextEditingController(text: wo?.deviceImei ?? '');
    _serialController = TextEditingController(text: '');
    _colorController = TextEditingController(text: wo?.deviceColor ?? 'Azul');

    _accessoriesController = TextEditingController(text: wo?.accessoriesLeft ?? 'Capa de proteção');
    _physicalConditionController = TextEditingController(text: wo?.physicalCondition ?? 'Bom estado');

    _reportedDefectController = TextEditingController(text: wo?.defectReported ?? '');
    _priority = wo?.priority ?? 'Normal';

    _diagnosisController = TextEditingController(text: wo?.diagnosis ?? '');
    _estimatedHoursController = TextEditingController(text: '2');

    final partsTotal = wo?.currentBudget?.productsTotal ?? 0.0;
    final servTotal = wo?.currentBudget?.servicesTotal ?? 0.0;
    _partsCostController = TextEditingController(text: partsTotal > 0 ? partsTotal.toStringAsFixed(2).replaceAll('.', ',') : '0,00');
    _servicePriceController = TextEditingController(text: servTotal > 0 ? servTotal.toStringAsFixed(2).replaceAll('.', ',') : '0,00');
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientCpfController.dispose();
    _modelController.dispose();
    _imeiController.dispose();
    _serialController.dispose();
    _colorController.dispose();
    _accessoriesController.dispose();
    _physicalConditionController.dispose();
    _reportedDefectController.dispose();
    _diagnosisController.dispose();
    _estimatedHoursController.dispose();
    _partsCostController.dispose();
    _servicePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _devicePhotos.add(image);
      });
    }
  }

  Future<void> _finishWorkOrder() async {
    final clientName = _clientNameController.text.trim();
    if (clientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o nome do cliente.')),
      );
      setState(() => _currentStep = 0);
      return;
    }

    final defect = _reportedDefectController.text.trim();
    if (defect.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o defeito do aparelho.')),
      );
      setState(() => _currentStep = 3);
      return;
    }

    setState(() => _isSubmitting = true);

    const uuid = Uuid();
    final partsVal = double.tryParse(_partsCostController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    final serviceVal = double.tryParse(_servicePriceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;

    Budget? initialBudget;
    if (partsVal > 0 || serviceVal > 0) {
      final items = <BudgetItem>[];
      if (partsVal > 0) {
        items.add(BudgetItem(
          id: uuid.v4(),
          type: BudgetItemType.product,
          description: 'Peças / Componentes Diversos',
          quantity: 1,
          costSnapshot: partsVal * 0.5,
          salePriceSnapshot: partsVal,
        ));
      }
      if (serviceVal > 0) {
        items.add(BudgetItem(
          id: uuid.v4(),
          type: BudgetItemType.service,
          description: 'Mão de Obra Técnica',
          quantity: 1,
          costSnapshot: 0.0,
          salePriceSnapshot: serviceVal,
        ));
      }

      initialBudget = Budget(
        id: uuid.v4(),
        workOrderId: widget.workOrder?.id ?? '',
        revision: 1,
        status: BudgetStatus.pendente,
        items: items,
        createdAt: DateTime.now(),
      );
    }

    final woToSave = WorkOrder(
      id: widget.workOrder?.id ?? '',
      tenantId: widget.workOrder?.tenantId ?? '',
      sequentialNumber: widget.workOrder?.sequentialNumber ?? 'OS-0105',
      customerId: widget.workOrder?.customerId ?? (_selectedCustomer?.id ?? 'c1111111-1111-1111-1111-111111111111'),
      customerName: clientName,
      customerPhone: _clientPhoneController.text.trim(),
      deviceBrand: _selectedBrand,
      deviceModel: _modelController.text.trim(),
      deviceImei: _imeiController.text.trim().isNotEmpty ? _imeiController.text.trim() : null,
      deviceColor: _colorController.text.trim(),
      defectReported: defect,
      physicalCondition: _physicalConditionController.text.trim(),
      accessoriesLeft: _accessoriesController.text.trim(),
      priority: _priority,
      status: widget.workOrder?.status ?? WorkOrderStatus.aberta,
      diagnosis: _diagnosisController.text.trim(),
      currentBudget: initialBudget ?? widget.workOrder?.currentBudget,
      history: widget.workOrder?.history ?? [],
      createdAt: widget.workOrder?.createdAt ?? DateTime.now(),
    );

    final success = widget.workOrder == null
        ? await ref.read(workOrdersControllerProvider.notifier).createWorkOrder(woToSave)
        : await ref.read(workOrdersControllerProvider.notifier).updateWorkOrder(woToSave);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.workOrder == null
                ? 'Ordem de Serviço criada com sucesso!'
                : 'Ordem de Serviço atualizada com sucesso!',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final custState = ref.watch(customersControllerProvider);
    final isEditing = widget.workOrder != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço (OS)'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          } else {
            _finishWorkOrder();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: _currentStep == 5 ? (isEditing ? 'Salvar Alterações' : 'Finalizar & Abrir OS') : 'Próximo Passo',
                    isLoading: _isSubmitting,
                    onPressed: details.onStepContinue,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Cancelar' : 'Voltar'),
                ),
              ],
            ),
          );
        },
        steps: [
          // Passo 1: Cliente
          Step(
            title: const Text('Identificação do Cliente'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Customer>(
                  value: custState.customers.any((c) => c.id == _selectedCustomer?.id) ? _selectedCustomer : null,
                  decoration: const InputDecoration(
                    labelText: 'Selecione Cliente Cadastrado',
                    prefixIcon: Icon(Icons.person_search),
                  ),
                  items: custState.customers.map((c) {
                    return DropdownMenuItem(value: c, child: Text('${c.name} (${c.phone})'));
                  }).toList(),
                  onChanged: (cust) {
                    if (cust != null) {
                      setState(() {
                        _selectedCustomer = cust;
                        _clientNameController.text = cust.name;
                        _clientPhoneController.text = cust.phone;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _clientNameController,
                  label: 'Nome Completo do Cliente *',
                  hint: 'Ex: Roberto de Oliveira',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _clientPhoneController,
                  label: 'Telefone / WhatsApp *',
                  hint: '(11) 98765-4321',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),

          // Passo 2: Aparelho
          Step(
            title: const Text('Dados do Aparelho'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: ['Apple', 'Samsung', 'Motorola', 'Xiaomi', 'Redmi', 'Poco', 'Outros'].contains(_selectedBrand) ? _selectedBrand : 'Apple',
                  decoration: const InputDecoration(
                    labelText: 'Fabricante / Marca',
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: ['Apple', 'Samsung', 'Motorola', 'Xiaomi', 'Redmi', 'Poco', 'Outros']
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBrand = val ?? 'Apple'),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _modelController,
                  label: 'Modelo do Aparelho *',
                  hint: 'Ex: iPhone 13 Pro ou Galaxy S22',
                  prefixIcon: Icons.smartphone,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _imeiController,
                        label: 'IMEI / Nº de Série',
                        hint: '354...',
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _colorController,
                        label: 'Cor',
                        hint: 'Ex: Azul, Preto',
                        prefixIcon: Icons.palette_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Passo 3: Condição & Fotos
          Step(
            title: const Text('Estado de Recebimento & Fotos'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _physicalConditionController,
                  label: 'Estado Físico / Condição de Entrada',
                  hint: 'Arranhões, marcas de uso, amassados...',
                  prefixIcon: Icons.security_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _accessoriesController,
                  label: 'Acessórios Deixados com o Aparelho',
                  hint: 'Capa, chip, cartão SD, cabo...',
                  prefixIcon: Icons.card_giftcard,
                ),
                const SizedBox(height: 16),
                const Text('Fotografias do Aparelho:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('Tirar Foto', style: TextStyle(color: Colors.white)),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeria'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                if (_devicePhotos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _devicePhotos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade300,
                                ),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => setState(() => _devicePhotos.removeAt(index)),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Passo 4: Defeito Relatado
          Step(
            title: const Text('Defeito & Prioridade'),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _reportedDefectController,
                  label: 'Defeito Relatado pelo Cliente *',
                  hint: 'Descreva o problema relatado...',
                  prefixIcon: Icons.report_problem_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Prioridade de Atendimento:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ['Baixa', 'Normal', 'Alta', 'Urgente']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => _priority = val ?? 'Normal'),
                ),
              ],
            ),
          ),

          // Passo 5: Diagnóstico
          Step(
            title: const Text('Laudo Técnico (Opcional)'),
            isActive: _currentStep >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _diagnosisController,
                  label: 'Diagnóstico Preliminar',
                  hint: 'Análise inicial do técnico...',
                  prefixIcon: Icons.biotech_outlined,
                  maxLines: 3,
                ),
              ],
            ),
          ),

          // Passo 6: Orçamento Preliminar
          Step(
            title: const Text('Orçamento Preliminar'),
            isActive: _currentStep >= 5,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _partsCostController,
                        label: 'Valor Peças (R\$)',
                        hint: '0,00',
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _servicePriceController,
                        label: 'Mão de Obra (R\$)',
                        hint: '0,00',
                        prefixIcon: Icons.monetization_on_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
