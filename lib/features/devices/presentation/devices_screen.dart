import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = [
      {'brand': 'Apple', 'model': 'iPhone 13', 'owner': 'Mariana Souza', 'imei': '356891092384712'},
      {'brand': 'Samsung', 'model': 'Galaxy S22 Ultra', 'owner': 'Carlos Eduardo Silva', 'imei': '354910293817462'},
      {'brand': 'Motorola', 'model': 'Edge 30 Fusion', 'owner': 'Fernanda Lima', 'imei': '351928374650192'},
      {'brand': 'Xiaomi', 'model': 'Redmi Note 12', 'owner': 'Rodrigo Menezes', 'imei': '358291048273615'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Catálogo de Aparelhos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final d = devices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smartphone, color: AppColors.primary),
              ),
              title: Text('${d['brand']} ${d['model']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Cliente: ${d['owner']}\nIMEI: ${d['imei']}', style: const TextStyle(fontSize: 12)),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
