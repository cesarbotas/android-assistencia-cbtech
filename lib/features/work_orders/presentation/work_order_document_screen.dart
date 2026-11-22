import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/work_order.dart';

class WorkOrderDocumentScreen extends StatelessWidget {
  final WorkOrder workOrder;

  const WorkOrderDocumentScreen({super.key, required this.workOrder});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    void shareCheckIn() {
      final text = '''
*CB Tech Assistência Técnica*
*COMPROVANTE DE ENTRADA DE APARELHO*
------------------------------------
Nº OS: ${workOrder.sequentialNumber}
Data de Abertura: ${dateFormat.format(workOrder.createdAt)}
Cliente: ${workOrder.customerName}
Aparelho: ${workOrder.deviceBrand} ${workOrder.deviceModel} (IMEI: ${workOrder.deviceImei ?? 'Não informado'})
Defeito Relatado: ${workOrder.defectReported}
Prioridade: ${workOrder.priority}
------------------------------------
*Termo de Entrada:*
O cliente deixa o aparelho acima descrito para diagnóstico e orçamento técnico. A CB Tech não se responsabiliza por dados não salvos previamente.
''';
      Share.share(text);
    }

    void shareWarranty() {
      final text = '''
*CB Tech Assistência Técnica*
*TERMO DE GARANTIA E CONDIÇÕES*
------------------------------------
Referente à OS: ${workOrder.sequentialNumber}
Cliente: ${workOrder.customerName}
Aparelho: ${workOrder.deviceBrand} ${workOrder.deviceModel}
------------------------------------
1. A garantia cobre exclusivamente os serviços executados e as peças substituídas descritas nesta OS.
2. Prazo de garantia: 90 (noventa) dias corridos a partir da data de retirada.
3. A garantia perde a validade em caso de danos por queda, exposição a líquidos, violação de selos ou mau uso.
''';
      Share.share(text);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Documentos - ${workOrder.sequentialNumber}'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Comprovante de Entrada', icon: Icon(Icons.assignment_outlined, size: 18)),
              Tab(text: 'Termo de Garantia', icon: Icon(Icons.verified_outlined, size: 18)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: COMPROVANTE DE ENTRADA
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'CB Tech Assistência Técnica',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ),
                          const Center(child: Text('Comprovante de Entrada / Check-in', style: TextStyle(fontSize: 12, color: Colors.grey))),
                          const Divider(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('OS: ${workOrder.sequentialNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(dateFormat.format(workOrder.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Text('Cliente: ${workOrder.customerName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Aparelho: ${workOrder.deviceBrand} ${workOrder.deviceModel}', style: const TextStyle(fontSize: 13)),
                          if (workOrder.deviceImei != null && workOrder.deviceImei!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('IMEI / Serial: ${workOrder.deviceImei}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                          const Divider(height: 24),

                          const Text('Defeito Relatado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(workOrder.defectReported, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 16),

                          const Text('Termos e Condições de Entrada:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text(
                            '1. O equipamento é deixado para fins de orçamento e/ou reparo técnico.\n'
                            '2. A assistência não se responsabiliza por perda de dados; recomenda-se backup prévio.\n'
                            '3. Equipamentos não retirados no prazo de 90 dias estarão sujeitos a cobrança de taxa de guarda.',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Compartilhar Comprovante',
                    icon: Icons.share,
                    onPressed: shareCheckIn,
                  ),
                ],
              ),
            ),

            // TAB 2: TERMO DE GARANTIA
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'CB Tech Assistência Técnica',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ),
                          const Center(child: Text('Termo de Garantia e Condições', style: TextStyle(fontSize: 12, color: Colors.grey))),
                          const Divider(height: 30),

                          Text('Referente à OS: ${workOrder.sequentialNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Cliente: ${workOrder.customerName}', style: const TextStyle(fontSize: 13)),
                          Text('Aparelho: ${workOrder.deviceBrand} ${workOrder.deviceModel}', style: const TextStyle(fontSize: 13)),
                          const Divider(height: 24),

                          const Text(
                            'Cobertura e Validade da Garantia:\n\n'
                            '• Prazo: 90 (noventa) dias corridos contados a partir da data de retirada do aparelho.\n'
                            '• Escopo: A garantia cobre exclusivamente os componentes substituídos e os serviços de mão de obra descritos nesta Ordem de Serviço.\n'
                            '• Exclusões: A garantia fica automaticamente invalidada em casos de:\n'
                            '  1. Quedas, impactos ou novos danos físicos;\n'
                            '  2. Contato com líquidos ou umidade após o reparo;\n'
                            '  3. Violação de lacres de segurança ou intervenção por terceiros;\n'
                            '  4. Oscilação elétrica ou uso de carregadores inadequados.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Compartilhar Termo de Garantia',
                    icon: Icons.share,
                    onPressed: shareWarranty,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
