import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parts = [
      {'name': 'Tela Display OLED iPhone 13', 'sku': 'TEL-IP13-OLED', 'stock': 2, 'min': 3, 'price': 'R\$ 450,00'},
      {'name': 'Bateria Original iPhone 13', 'sku': 'BAT-IP13-ORIG', 'stock': 1, 'min': 2, 'price': 'R\$ 180,00'},
      {'name': 'Conector de Carga Galaxy S22 Ultra', 'sku': 'SUB-S22U-USBC', 'stock': 5, 'min': 2, 'price': 'R\$ 120,00'},
      {'name': 'Bateria Motorola Edge 30 Fusion', 'sku': 'BAT-MOT-E30F', 'stock': 4, 'min': 2, 'price': 'R\$ 130,00'},
      {'name': 'Módulo Frontal Redmi Note 12', 'sku': 'TEL-RED-N12', 'stock': 6, 'min': 3, 'price': 'R\$ 210,00'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Peças & Estoque'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: parts.length,
        itemBuilder: (context, index) {
          final p = parts[index];
          final isLow = (p['stock'] as int) < (p['min'] as int);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isLow ? Colors.amber.shade100 : Colors.blue.shade50,
                child: Icon(
                  isLow ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                  color: isLow ? Colors.amber.shade800 : AppColors.primary,
                ),
              ),
              title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('SKU: ${p['sku']} • Venda: ${p['price']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${p['stock']} un',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isLow ? Colors.red : Colors.green.shade800,
                    ),
                  ),
                  if (isLow)
                    const Text('Estoque baixo!', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
