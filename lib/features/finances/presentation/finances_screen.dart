import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';

class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'title': 'Pagamento OS-0101 (Rodrigo M.)', 'type': 'Entrada', 'method': 'PIX', 'value': '+ R\$ 150,00', 'date': 'Hoje, 16:45'},
      {'title': 'Adiantamento OS-0104 (Mariana S.)', 'type': 'Entrada', 'method': 'Cartão Crédito', 'value': '+ R\$ 300,00', 'date': 'Hoje, 14:35'},
      {'title': 'Compra de Peças - Fornecedor TotalCell', 'type': 'Saída', 'method': 'Boleto', 'value': '- R\$ 1.250,00', 'date': 'Ontem, 11:20'},
      {'title': 'Pagamento OS-0099 (Ana Paula)', 'type': 'Entrada', 'method': 'Dinheiro', 'value': '+ R\$ 280,00', 'date': '15/11/2026'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card Balanço
          Card(
            color: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo em Caixa (Mês Vigente)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 6),
                  Text(
                    'R\$ 8.360,00',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Entradas', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text('R\$ 12.480,00', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saídas / Peças', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text('R\$ 4.120,00', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Últimas Movimentações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...transactions.map((t) {
            final isIncome = t['type'] == 'Entrada';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ),
                title: Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('${t['method']} • ${t['date']}', style: const TextStyle(fontSize: 11)),
                trailing: Text(
                  t['value']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isIncome ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
