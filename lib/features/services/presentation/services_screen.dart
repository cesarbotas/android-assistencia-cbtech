import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Troca de Módulo Frontal / Display', 'time': '1h 30m', 'price': 'R\$ 150,00'},
      {'name': 'Substituição de Bateria', 'time': '45m', 'price': 'R\$ 90,00'},
      {'name': 'Desoxidação em Banho Ultrassônico', 'time': '4h 00m', 'price': 'R\$ 180,00'},
      {'name': 'Reparo Avançado em Placa / Micro solda', 'time': '6h 00m', 'price': 'R\$ 320,00'},
      {'name': 'Troca de Conector de Carga (Sub-placa)', 'time': '1h 00m', 'price': 'R\$ 110,00'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Catálogo de Serviços'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final s = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.build, color: Colors.white, size: 20),
              ),
              title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Tempo médio: ${s['time']}'),
              trailing: Text(
                s['price']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}
