import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class NewWorkOrderScreen extends ConsumerStatefulWidget {
  const NewWorkOrderScreen({super.key});

  @override
  ConsumerState<NewWorkOrderScreen> createState() => _NewWorkOrderScreenState();
}

class _NewWorkOrderScreenState extends ConsumerState<NewWorkOrderScreen> {
  int _currentStep = 0;

  // 1. Cliente
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientCpfController = TextEditingController();

  // 2. Aparelho
  String _selectedBrand = 'Apple';
  final _modelController = TextEditingController(text: 'iPhone 13');
  final _imeiController = TextEditingController();
  final _serialController = TextEditingController();
  final _colorController = TextEditingController(text: 'Azul');

  // 3. Recebimento & Fotos
  final List<XFile> _devicePhotos = [];
  final ImagePicker _picker = ImagePicker();
  final _accessoriesController = TextEditingController(text: 'Capa de proteção');
  final _physicalConditionController = TextEditingController(
    text: 'Tela frontal com trincado no canto superior direito. Carcaça em bom estado.',
  );

  // 4. Defeito Informado
  final _reportedDefectController = TextEditingController(
    text: 'Aparelho não responde ao toque em certas regiões e bateria descarrega rápido.',
  );
  String _priority = 'Normal';

  // 5. Diagnóstico Preliminar
  final _diagnosisController = TextEditingController(
    text: 'Necessária substituição do módulo frontal (display/touch) e troca da bateria com calibração.',
  );
  final _estimatedHoursController = TextEditingController(text: '2');

  // 6. Orçamento Preliminar
  final _partsCostController = TextEditingController(text: '450,00');
  final _servicePriceController = TextEditingController(text: '180,00');

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

  void _finishWorkOrder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Ordem Aberta!'),
          ],
        ),
        content: const Text(
          'Ordem de Serviço OS-0105 gerada com sucesso!\nO cliente receberá o comprovante de recebimento.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/work-orders');
            },
            child: const Text('Ver Ordens'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/dashboard');
            },
            child: const Text('Ir para o Início', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abertura de OS Guiada'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/work-orders'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rascunho de OS salvo localmente.')),
              );
            },
            child: const Text(
              'Salvar Rascunho',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        elevation: 1,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 6) {
            setState(() => _currentStep += 1);
          } else {
            _finishWorkOrder();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 6;
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: isLastStep ? 'Concluir Abertura de OS' : 'Próximo Passo',
                    onPressed: details.onStepContinue,
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Voltar'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // 1. Cliente
          Step(
            title: const Text('Cliente'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dados do Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _clientNameController,
                  label: 'Nome Completo',
                  hint: 'Ex: João Carlos da Silva',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _clientPhoneController,
                  label: 'Telefone / WhatsApp',
                  hint: '(11) 98765-4321',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _clientCpfController,
                  label: 'CPF (opcional para OS)',
                  hint: '123.456.789-00',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),

          // 2. Aparelho
          Step(
            title: const Text('Aparelho'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Identificação do Aparelho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Marca', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBrand,
                  decoration: const InputDecoration(),
                  items: ['Apple', 'Samsung', 'Motorola', 'Xiaomi', 'Redmi', 'Poco', 'Asus', 'Outros']
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBrand = val);
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _modelController,
                  label: 'Modelo',
                  hint: 'Ex: Galaxy S23, iPhone 14 Pro',
                  prefixIcon: Icons.smartphone,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _colorController,
                        label: 'Cor',
                        hint: 'Preto, Branco...',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _imeiController,
                        label: 'IMEI 1 (Opcional)',
                        hint: '15 dígitos',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Recebimento & Fotos
          Step(
            title: const Text('Condições'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado de Conservação & Fotos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _physicalConditionController,
                  label: 'Estado Físico no Recebimento',
                  hint: 'Riscos, trincos, marcas de queda, botões ausentes...',
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _accessoriesController,
                  label: 'Acessórios Deixados',
                  hint: 'Capa, película, chip SIM, carregador...',
                ),
                const SizedBox(height: 16),
                const Text('Fotografias do Aparelho (Recebimento)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Câmera'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeria'),
                    ),
                  ],
                ),
                if (_devicePhotos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _devicePhotos
                        .map(
                          (photo) => Chip(
                            avatar: const Icon(Icons.image, size: 16),
                            label: Text(photo.name, style: const TextStyle(fontSize: 12)),
                            onDeleted: () {
                              setState(() => _devicePhotos.remove(photo));
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // 4. Defeito Informado
          Step(
            title: const Text('Defeito'),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Relato do Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _reportedDefectController,
                  label: 'Defeito Relatado',
                  hint: 'Descreva detalhadamente o problema informado pelo cliente...',
                ),
                const SizedBox(height: 14),
                const Text('Prioridade de Atendimento', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(),
                  items: ['Baixa', 'Normal', 'Alta', 'Urgente']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _priority = val);
                  },
                ),
              ],
            ),
          ),

          // 5. Diagnóstico Técnico
          Step(
            title: const Text('Diagnóstico'),
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Diagnóstico Técnico Inicial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _diagnosisController,
                  label: 'Laudo / Procedimento Indicado',
                  hint: 'Resultados de testes em bancada, peças necessárias...',
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _estimatedHoursController,
                  label: 'Tempo Estimado de Reparo (horas)',
                  hint: 'Ex: 2',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),

          // 6. Orçamento
          Step(
            title: const Text('Orçamento'),
            isActive: _currentStep >= 5,
            state: _currentStep > 5 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(r'Valores Previstos (R$)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _partsCostController,
                        label: 'Peças / Componentes',
                        hint: '0,00',
                        prefixIcon: Icons.extension_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _servicePriceController,
                        label: 'Mão de Obra',
                        hint: '0,00',
                        prefixIcon: Icons.build_circle_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 7. Confirmação
          Step(
            title: const Text('Confirmação'),
            isActive: _currentStep >= 6,
            state: StepState.indexed,
            content: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumo da Abertura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    _SummaryRow(label: 'Cliente', value: _clientNameController.text.isNotEmpty ? _clientNameController.text : 'Cliente Balcão'),
                    _SummaryRow(label: 'Telefone', value: _clientPhoneController.text.isNotEmpty ? _clientPhoneController.text : 'Não informado'),
                    _SummaryRow(label: 'Aparelho', value: '$_selectedBrand ${_modelController.text}'),
                    _SummaryRow(label: 'Defeito', value: _reportedDefectController.text),
                    _SummaryRow(label: 'Prioridade', value: _priority),
                    _SummaryRow(label: 'Fotos Anexadas', value: '${_devicePhotos.length} foto(s)'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
